part of '../door_engine.dart';

/// What every part of the door engine shares: its settings, the open
/// session and pack, the links (server, venue hub), and the status.
abstract class _DoorEngineBase implements DoorControls {
  final DoorStore store;
  final DoorRemoteDataSource? remote;
  final Duration? syncEvery;
  final Duration liveTimeout;

  /// The hub's live claim for a joined door: short, so its answer reaches
  /// that door before it gives up (LanPeerClient.claim).
  final Duration peerLiveTimeout;

  /// Emits true when the device's connection comes back.
  final Stream<bool>? connectivity;

  /// A check-in was queued while offline: schedule a background upload.
  final void Function()? onQueued;

  /// Keeps the venue hub serving in the background (Android foreground service).
  final HubKeepAlive? keepAlive;

  _DoorEngineBase({
    required this.store,
    required this.remote,
    this.syncEvery = const Duration(seconds: 20),
    this.liveTimeout = const Duration(milliseconds: 3500),
    this.peerLiveTimeout = const Duration(milliseconds: 1500),
    this.connectivity,
    this.onQueued,
    this.keepAlive,
  });

  final DoorClock clock = DoorClock();
  final StreamController<DoorStatus> _statusController = StreamController<DoorStatus>.broadcast();
  DoorStatus _status = const DoorStatus();

  DoorSession? _session;
  DoorPackMeta? _meta;
  String? _deviceUuid;
  bool _syncing = false;
  DateTime? _serverOkAt;
  String? _problem;

  LanHubServer? _hub;
  List<String> _hubAddresses = const [];
  LanPeerClient? _peer;
  bool _hubReachable = false;
  int _hubPeers = 0;
  int _peerSeq = 0;
  int _pushedSeq = 0;

  final Map<int, Future<void>> _guestLocks = {};

  @override
  DoorStatus get status => _status;
  @override
  Stream<DoorStatus> get statusStream => _statusController.stream;

  // Implemented by the other parts.
  Future<DoorAdmission?> _claimOnServer(
    DoorSession s,
    DoorCheckInRecord record,
    DoorGuest guest,
    int? max,
    List<String> warnings, {
    Duration? timeout,
  });
  Future<void> _pushToHub();

  /// Admissions of one guest (at this phone or at a door joined to its hub)
  /// run one at a time: two scans of the same QR a second apart must not
  /// both get in. Different guests never wait for each other's live claim,
  /// so four doors scanning at once stay as fast as one.
  Future<T> _serialFor<T>(int invitationId, Future<T> Function() task) {
    final done = Completer<T>();
    final turn = (_guestLocks[invitationId] ?? Future<void>.value()).then((_) async {
      try {
        done.complete(await task());
      } catch (e, s) {
        done.completeError(e, s);
      }
    });
    _guestLocks[invitationId] = turn;
    unawaited(
      turn.then((_) {
        if (identical(_guestLocks[invitationId], turn)) _guestLocks.remove(invitationId);
      }),
    );
    return done.future;
  }

  bool get _serverLikely {
    final s = _session;
    final ok = _serverOkAt;
    return remote != null &&
        s != null &&
        s.hasServer &&
        !s.needsAuth &&
        !s.revoked &&
        ok != null &&
        DateTime.now().difference(ok) < DoorEngine.serverFreshness;
  }

  /// Today, for an event of several days (each day counts its own
  /// attendance); null for a one-day event.
  DoorDay? get _today => _meta?.event.dayAt(clock.nowUtc());

  /// The event day [atUtc] falls in (a check-in another door decided).
  DoorDay? _dayAt(DateTime atUtc) => _meta?.event.dayAt(atUtc);

  DoorGate? get _gate {
    final id = _session?.gateId;
    if (id == null) return null;
    for (final g in _meta?.gates ?? const <DoorGate>[]) {
      if (g.id == id) return g;
    }
    return null;
  }

  DoorDeviceInfo _deviceInfo(DoorSession s, {int pending = 0}) =>
      DoorDeviceInfo(uuid: _deviceUuid ?? '', name: s.deviceName, gateId: s.gateId, pending: pending);

  Future<void> _markAuth(DoorErrorKind kind) async {
    final s = _session;
    if (s == null) return;
    _session = s.copyWith(needsAuth: kind == DoorErrorKind.auth, revoked: kind == DoorErrorKind.revoked);
    _problem = kind == DoorErrorKind.revoked ? 'device_revoked' : 'needs_auth';
    await store.saveSession(_session!);
  }

  // ── Status ──────────────────────────────────────────────────────

  @override
  Future<void> refreshStatus() => _refresh();

  Future<void> _refresh() async {
    final s = _session;
    if (s == null) return;
    final meta = _meta;
    final link = _serverLikely
        ? DoorLink.online
        : (_hubReachable || ((_hub?.running ?? false) && (_hub?.peerCount ?? 0) > 0))
        ? DoorLink.hub
        : DoorLink.offline;
    _emit(
      DoorStatus(
        session: s,
        event: meta?.event,
        gates: meta?.gates ?? const [],
        link: link,
        hasPack: meta != null,
        guests: meta == null ? 0 : await store.guestCount(s.eventId),
        checkedIn: meta == null ? 0 : await store.checkedInCount(s.eventId, day: _today),
        pending: await store.pendingCount(s.eventId),
        refused: await store.refusedCount(s.eventId),
        packDownloadedAt: meta?.downloadedAt,
        lastSyncAt: meta?.lastSyncAt,
        syncing: _syncing,
        hubRunning: _hub?.running ?? false,
        hubAddresses: _hubAddresses,
        peers: (_hub?.running ?? false) ? _hub!.peerCount : (_hubReachable ? _hubPeers : 0),
        problem: _problem,
      ),
    );
  }

  void _emit(DoorStatus status) {
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }
}
