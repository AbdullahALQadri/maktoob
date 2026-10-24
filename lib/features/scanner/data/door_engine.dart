import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../../../core/utils/uuid.dart';
import '../domain/entities/door_entities.dart';
import '../domain/logic/door_clock.dart';
import '../domain/logic/door_crypto.dart';
import '../domain/logic/door_rules.dart';
import '../domain/logic/scan_key.dart';
import '../domain/repositories/door_controls.dart';
import 'datasources/door_remote_data_source.dart';
import 'datasources/door_store.dart';
import 'lan/hub_keep_alive.dart';
import 'lan/lan_hub_server.dart';
import 'lan/lan_peer_client.dart';
import 'lan/lan_protocol.dart';
import 'models/door_models.dart';

part 'door_engine/door_outcomes.dart';
part 'door_engine/door_scan.dart';
part 'door_engine/engine_base.dart';
part 'door_engine/hub_host.dart';
part 'door_engine/hub_peer.dart';
part 'door_engine/server_sync.dart';

/// The offline door.
///
/// One phone, one event. The phone always knows the whole guest list (the
/// door pack) and decides in this order:
///   1. the server, when it answered in the last two minutes (one live claim,
///      3.5 s at most: the guest is waiting);
///   2. the venue hub, when this phone joined one (4 s at most; the hub gives
///      the server [peerLiveTimeout] of it, then decides itself);
///   3. on its own.
/// Every admission is stored first and uploaded later; uploads carry the
/// check-in's uuid, so sending twice never counts twice. While the screen is
/// open it syncs every [syncEvery]; the background task does the rest
/// (lib/core/offline/background_sync.dart).
///
/// The parts: door_engine/engine_base.dart (shared state, status),
/// door_scan.dart (scan, admit), server_sync.dart (live claim, sync),
/// hub_host.dart (this phone serves the others), hub_peer.dart (joined to a
/// hub).
class DoorEngine extends _DoorEngineBase with _DoorServerSync, _DoorScan, _DoorHubHost, _DoorHubPeer {
  DoorEngine({
    required super.store,
    required super.remote,
    super.syncEvery,
    super.liveTimeout,
    super.peerLiveTimeout,
    super.connectivity,
    super.onQueued,
    super.keepAlive,
  });

  static const Duration serverFreshness = Duration(minutes: 2);
  static const Duration packMaxAge = Duration(hours: 6);

  Timer? _timer;
  StreamSubscription<bool>? _connectivitySub;

  DoorSession? get session => _session;
  DoorPackMeta? get packMeta => _meta;

  /// The venue hub's port while it runs.
  int? get hubPort => (_hub?.running ?? false) ? _hub!.port : null;

  /// Opens the door for [session]. With [live] false (background task) no
  /// timer and no hub are started.
  Future<DoorStatus> open(DoorSession session, {bool live = true}) async {
    if (_session != null && _session!.id != session.id) await close(force: true);
    session = await _restore(session);
    _session = session;
    _deviceUuid ??= await store.deviceUuid();
    await store.saveSession(session);
    _meta = await store.packMeta(session.eventId);
    if (_meta != null) clock.offsetMs = _meta!.clockOffsetMs;
    _problem = session.revoked ? 'device_revoked' : (session.needsAuth ? 'needs_auth' : null);

    if (live) {
      final join = LanJoinInfo.fromStorage(session.lanJoin);
      if (join != null && join.eventId == session.eventId) _startPeer(join);
      _timer?.cancel();
      if (syncEvery != null) _timer = Timer.periodic(syncEvery!, (_) => unawaited(syncNow()));
      _connectivitySub?.cancel();
      _connectivitySub = connectivity?.listen((up) {
        if (up) unawaited(syncNow());
      });
    }

    await _refresh();
    final stale = _meta == null || DateTime.now().toUtc().difference(_meta!.downloadedAt) > packMaxAge;
    final first = syncNow(refreshPack: stale);
    if (live) {
      unawaited(first);
    } else {
      await first;
    }
    return _status;
  }

  /// The host opens a fresh session from the events list each time: keep
  /// what this phone remembers about it (its name, gate, joined hub).
  Future<DoorSession> _restore(DoorSession session) async {
    final saved = await store.session(session.id);
    var name = session.deviceName.isNotEmpty ? session.deviceName : (saved?.deviceName ?? '');
    if (name.isEmpty) {
      name = await store.value('device_name') ?? '';
      if (name.isEmpty) name = 'Door ${(await store.deviceUuid()).substring(0, 4).toUpperCase()}';
    }
    return DoorSession(
      id: session.id,
      kind: session.kind,
      eventId: session.eventId,
      eventTitle: session.eventTitle.isNotEmpty ? session.eventTitle : (saved?.eventTitle ?? ''),
      deviceName: name,
      gateId: session.gateId ?? saved?.gateId,
      lanJoin: session.lanJoin ?? saved?.lanJoin,
      // A host who signed in again has a new token: let it try.
      needsAuth: session.kind == DoorSessionKind.client ? false : (saved?.needsAuth ?? session.needsAuth),
      revoked: saved?.revoked ?? session.revoked,
    );
  }

  /// Leaves the door. A running venue hub keeps the session open (other
  /// doors depend on it) until it is stopped or [force]d (another event).
  Future<void> close({bool force = false}) async {
    if (!force && (_hub?.running ?? false)) return;
    _timer?.cancel();
    _timer = null;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    await stopHub();
    _peer = null;
    _hubReachable = false;
    _session = null;
    _meta = null;
    _serverOkAt = null;
    _emit(const DoorStatus());
  }

  @override
  Future<void> setGate(int? gateId) async {
    final s = _session;
    if (s == null) return;
    _session = s.copyWith(gateId: gateId, clearGate: gateId == null);
    await store.saveSession(_session!);
    if (s.kind == DoorSessionKind.paired && remote != null) {
      try {
        await remote!.setPairedGate(_session!, gateId);
      } catch (_) {
        // Sent again with the next sync (device info carries the gate).
      }
    }
    await _refresh();
  }

  /// One pass for the background task: every session with check-ins to
  /// upload (or a pack to fetch before the event), then old packs dropped.
  static Future<int> syncAll(DoorStore store, DoorRemoteDataSource remote, {String? skip}) async {
    var synced = 0;
    for (final s in await store.sessions()) {
      // [skip]: the session open on screen syncs itself.
      if (s.id == skip || !s.hasServer || s.revoked || s.needsAuth) continue;
      final pending = await store.pendingCount(s.eventId);
      final meta = await store.packMeta(s.eventId);
      final fresh =
          meta != null &&
          DateTime.now().toUtc().difference(meta.lastSyncAt ?? meta.downloadedAt) < const Duration(hours: 1);
      if (pending == 0 && fresh) continue;
      final engine = DoorEngine(store: store, remote: remote, syncEvery: null);
      try {
        await engine.open(s, live: false);
        synced++;
      } finally {
        await engine.close();
      }
    }
    await store.purge(DateTime.now().toUtc());
    return synced;
  }
}
