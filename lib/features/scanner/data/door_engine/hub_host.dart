part of '../door_engine.dart';

/// This phone as the venue hub: it serves the list to the other door
/// phones on the local network and decides their claims.
mixin _DoorHubHost on _DoorEngineBase implements LanHubHandlers {
  Future<LanJoinInfo?> startHub({String? notificationTitle, String? notificationText}) async {
    final s = _session;
    if (s == null || _meta == null) return null;
    final secretKey = 'hub_secret:${s.eventId}';
    var encoded = await store.value(secretKey);
    var secret = encoded == null ? null : DoorCrypto.decodeKey(encoded);
    if (secret == null || secret.length != 32) {
      secret = LanJoinInfo.newSecret();
      // Kept so a restarted hub keeps its joined phones.
      await store.setValue(secretKey, base64Url.encode(secret).replaceAll('=', ''));
    }
    _hub ??= LanHubServer(eventId: s.eventId, cipher: LanCipher(secret), handlers: this);
    await _hub!.start();
    _hubAddresses = await _hub!.addresses();
    if (notificationTitle != null) {
      await keepAlive?.start(title: notificationTitle, text: notificationText ?? '');
    }
    await _refresh();
    return LanJoinInfo(
      hosts: _hubAddresses,
      eventId: s.eventId,
      eventTitle: _meta?.event.title ?? s.eventTitle,
      hubName: s.deviceName,
      secret: secret,
    );
  }

  @override
  Future<String?> startHubJoinCode({String? notificationTitle, String? notificationText}) async =>
      (await startHub(notificationTitle: notificationTitle, notificationText: notificationText))?.encode();

  @override
  Future<void> stopHub() async {
    final hub = _hub;
    _hub = null;
    _hubAddresses = const [];
    await hub?.stop();
    if (hub != null) await keepAlive?.stop();
    if (_session != null) await _refresh();
  }

  @override
  Future<Map<String, dynamic>> hello(Map<String, dynamic> payload) async => {
    'hub_name': _session?.deviceName,
    'event_id': _session?.eventId,
    'has_pack': _meta != null,
    'seq': _session == null ? 0 : await store.maxLanSeq(_session!.eventId),
    'hub_time': clock.nowUtc().toIso8601String(),
  };

  @override
  Future<Map<String, dynamic>> pack() async {
    final s = _session;
    if (s == null) return const {};
    // The seq is read first: anything newer comes through the changes feed.
    final seq = await store.maxLanSeq(s.eventId);
    return {...await store.exportPack(s.eventId), 'hub_seq': seq};
  }

  @override
  Future<Map<String, dynamic>> claim(Map<String, dynamic> item) async {
    final invitationId = item['invitation_id'];
    if (invitationId is! num) return {'result': 'refused', 'code': 'invalid'};
    return _serialFor(invitationId.toInt(), () async {
      final s = _session;
      final meta = _meta;
      if (s == null || meta == null) return {'result': 'refused', 'code': 'no_pack'};
      final record = DoorCheckInRecord.fromLanJson(s.eventId, item, origin: 'peer');

      final first = await store.firstCheckIn(s.eventId, record.invitationId);
      // The same claim sent again after a timeout: it is in.
      if (first != null && first.uuid == record.uuid) return {'result': 'admitted', 'synced': false};

      final eventBlocker = DoorRules.eventBlocker(meta.event, clock.nowUtc());
      if (eventBlocker != null) return {'result': 'refused', 'code': eventBlocker};
      // Already came in through another door: let back in, nothing kept.
      if (first != null) return {'result': 'returned', 'check_in': _lanJson(s.eventId, first)};

      final guest = await store.guest(s.eventId, record.invitationId);
      final blocker = DoorRules.companionsBlocker(record.companions, guest?.maxCompanions);
      if (blocker != null) return {'result': 'refused', 'code': blocker};

      final viaServer = await _claimOnServer(
        s,
        record.copyWith(origin: 'peer'),
        guest ?? DoorGuest(id: record.invitationId, name: ''),
        guest?.maxCompanions,
        const [],
        timeout: peerLiveTimeout,
      );
      if (viaServer != null) {
        if (viaServer.returning) {
          return {
            'result': 'returned',
            if (viaServer.checkIn != null) 'check_in': _lanJson(s.eventId, viaServer.checkIn!),
          };
        }
        return viaServer.admitted
            ? {'result': 'admitted', 'synced': true}
            : {
                'result': 'refused',
                'code': viaServer.code,
                if (viaServer.checkIn != null) 'check_in': _lanJson(s.eventId, viaServer.checkIn!),
              };
      }

      await store.addCheckIn(record.copyWith(source: 'lan', syncState: 'pending'));
      _hub?.notifyChanged();
      onQueued?.call();
      await _refresh();
      return {'result': 'admitted', 'synced': false};
    });
  }

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> items) async {
    final s = _session;
    if (s == null) return const {'accepted': 0};
    final records = items.map((j) => DoorCheckInRecord.fromLanJson(s.eventId, j, origin: 'peer')).toList();
    // Decided while the hub was out of reach: keep them all, the server
    // flags a double admission.
    await store.mergeLanRecords(s.eventId, records);
    _hub?.notifyChanged();
    if (records.any((r) => r.syncState == 'pending')) onQueued?.call();
    await _refresh();
    return {'accepted': records.length};
  }

  @override
  Future<Map<String, dynamic>> changes(int since) async {
    final s = _session;
    if (s == null) return const {'seq': 0, 'records': []};
    final rows = await store.lanRecordsSince(s.eventId, since);
    return {
      'seq': rows.isEmpty ? since : rows.map((r) => r.lanSeq).reduce(max),
      'records': rows.map((r) => r.toLanJson()).toList(),
      'event_status': _meta?.event.status,
    };
  }

  Map<String, dynamic> _lanJson(int eventId, DoorCheckIn c) =>
      (c is DoorCheckInRecord
              ? c
              : DoorCheckInRecord(
                  uuid: c.uuid,
                  eventId: eventId,
                  invitationId: c.invitationId,
                  checkedInAt: c.checkedInAt,
                  companions: c.companions,
                  gateId: c.gateId,
                  deviceName: c.deviceName,
                  source: c.source,
                  origin: 'server',
                  syncState: 'synced',
                ))
          .toLanJson();
}
