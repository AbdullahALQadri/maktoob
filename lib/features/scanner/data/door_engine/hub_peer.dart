part of '../door_engine.dart';

/// This phone joined to a venue hub: it takes the list from the hub, sends
/// its check-ins there and learns the other doors' check-ins from it.
mixin _DoorHubPeer on _DoorEngineBase {
  @override
  Future<bool> joinHubFromCode(String qrText) async {
    final join = LanJoinInfo.decode(qrText);
    if (join == null || join.eventId != _session?.eventId) return false;
    await attachHub(join);
    return true;
  }

  /// Join a hub (scanned its QR). The session keeps it for next time.
  Future<void> attachHub(LanJoinInfo join) async {
    final s = _session;
    if (s == null || join.eventId != s.eventId) return;
    _session = s.copyWith(lanJoin: join.toStorage());
    await store.saveSession(_session!);
    _startPeer(join);
    await _refresh();
  }

  @override
  Future<void> detachHub() async {
    final s = _session;
    _peer = null;
    _hubReachable = false;
    if (s != null && s.kind != DoorSessionKind.lan) {
      _session = DoorSession(
        id: s.id,
        kind: s.kind,
        eventId: s.eventId,
        eventTitle: s.eventTitle,
        deviceName: s.deviceName,
        gateId: s.gateId,
        needsAuth: s.needsAuth,
        revoked: s.revoked,
      );
      await store.saveSession(_session!);
    }
    await _refresh();
  }

  void _startPeer(LanJoinInfo join) {
    final s = _session;
    if (s == null) return;
    final peer = LanPeerClient(
      join: join,
      deviceUuid: _deviceUuid ?? '',
      deviceName: s.deviceName,
      gateId: () => _session?.gateId,
    );
    _peer = peer;
    _peerSeq = 0;
    _pushedSeq = 0;
    unawaited(_peerLoop(peer));
  }

  Future<void> _peerLoop(LanPeerClient peer) async {
    var backoff = 2;
    while (identical(_peer, peer) && _session != null) {
      final s = _session!;
      try {
        if (_meta == null) {
          final raw = await peer.pack();
          final model = DoorPackModel.fromJson(raw);
          clock.observe(model.serverTime);
          await store.savePack(model, downloadedAt: DateTime.now().toUtc(), clockOffsetMs: clock.offsetMs);
          _meta = await store.packMeta(s.eventId);
          _peerSeq = (raw['hub_seq'] as num?)?.toInt() ?? 0;
        }
        // Say we are here before the long wait for changes.
        if (!_hubReachable) {
          await peer.hello();
          _hubReachable = true;
          if (_problem == 'hub_refused') _problem = null;
          await _refresh();
        }
        await _pushToHub();
        final res = await peer.changes(_peerSeq);
        if (!identical(_peer, peer)) return;
        final records = (res['records'] as List? ?? const [])
            .whereType<Map>()
            .map((j) => DoorCheckInRecord.fromLanJson(s.eventId, Map<String, dynamic>.from(j), origin: 'peer'))
            .toList();
        if (records.isNotEmpty) await store.mergeLanRecords(s.eventId, records);
        _peerSeq = (res['seq'] as num?)?.toInt() ?? _peerSeq;
        _hubPeers = (res['peers'] as num?)?.toInt() ?? _hubPeers;
        final status = res['event_status'];
        if (status is String) await store.updatePackMeta(s.eventId, eventStatus: status);
        _hubReachable = true;
        if (_problem == 'hub_refused') _problem = null;
        backoff = 2;
        await _refresh();
      } on LanAuthException {
        _hubReachable = false;
        _problem = 'hub_refused';
        await _refresh();
        return;
      } catch (_) {
        if (!identical(_peer, peer)) return;
        _hubReachable = false;
        await _refresh();
        await Future<void>.delayed(Duration(seconds: backoff));
        backoff = min(backoff * 2, 15);
      }
    }
  }

  @override
  Future<void> _pushToHub() async {
    final peer = _peer;
    final s = _session;
    if (peer == null || s == null) return;
    final rows = await store.lanRecordsSince(s.eventId, _pushedSeq);
    if (rows.isEmpty) return;
    final mine = rows.where((r) => r.origin == 'local').toList();
    if (mine.isNotEmpty) await peer.push(mine.map((r) => r.toLanJson()).toList());
    _pushedSeq = rows.map((r) => r.lanSeq).reduce(max);
  }
}
