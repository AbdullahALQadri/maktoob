part of '../door_engine.dart';

/// Scanning a QR and letting the guest in: server, then venue hub, then
/// this phone alone.
mixin _DoorScan on _DoorEngineBase {
  Future<DoorVerdict> lookup(String raw) async {
    final s = _session;
    final meta = _meta;
    if (s == null || meta == null) return const DoorVerdict(blocker: 'no_pack');

    final scan = ScanKey.extract(raw);
    if (scan.isEmpty) return const DoorVerdict(blocker: DoorRules.notFound);

    var guest = await store.guestByHash(s.eventId, DoorCrypto.lookupHash(meta.salt, scan.key));
    var unlisted = false;
    int? tokenMax;

    if (guest == null && scan.token != null) {
      final token = DoorCrypto.verifyToken(meta.sign, scan.token!, scan.key);
      if (token == null) {
        // Signed for another event (its own key), or not ours at all.
        final eventPart = int.tryParse(scan.token!.split('.').first);
        if (eventPart != null && eventPart != s.eventId) return const DoorVerdict(blocker: DoorRules.otherEvent);
      } else if (token.eventId != s.eventId) {
        return const DoorVerdict(blocker: DoorRules.otherEvent);
      } else {
        guest = await store.guest(s.eventId, token.invitationId);
        if (guest == null) {
          unlisted = true;
          tokenMax = token.maxCompanions;
          guest = DoorGuest(id: token.invitationId, name: '', maxCompanions: token.maxCompanions);
        }
      }
    }

    // Still unknown and the server is reachable: a guest added at the venue.
    if ((guest == null || unlisted) && _serverLikely) {
      try {
        final found = await remote!.lookup(s, raw, timeout: liveTimeout);
        if (found != null) {
          await store.upsertGuest(s.eventId, found);
          guest = found.guest;
          unlisted = false;
        }
      } on DoorHttpException catch (e) {
        if (e.kind == DoorErrorKind.network) _serverOkAt = null;
      }
    }

    if (guest == null) return const DoorVerdict(blocker: DoorRules.notFound);

    // A guest who already came in (today, for an event of several days) is
    // let back in (see DoorVerdict.returning).
    final today = _today;
    final first = await store.firstCheckIn(s.eventId, guest.id, day: today);
    final known = guest.checkIn;
    guest = guest.withCheckIn(
      first ?? (today == null || (known != null && today.contains(known.checkedInAt)) ? known : null),
    );

    return DoorVerdict(
      guest: guest,
      blocker: DoorRules.eventBlocker(meta.event, clock.nowUtc()),
      unlisted: unlisted,
      maxCompanions: guest.maxCompanions ?? tokenMax,
      warnings: DoorRules.warnings(guest: guest, gate: _gate, unlisted: unlisted),
    );
  }

  /// The guests list (search is Arabic-tolerant), with who is inside.
  Future<List<DoorGuest>> guests({String query = ''}) async {
    final s = _session;
    if (s == null) return const [];
    return store.guests(s.eventId, query: query, day: _today);
  }

  Future<DoorAdmission> admit(
    int invitationId, {
    int companions = 0,
    bool manual = false,
    int? maxCompanions,
    String? notes,
  }) => _serialFor(invitationId, () async {
    final s = _session;
    final meta = _meta;
    if (s == null || meta == null) return const DoorAdmission(admitted: false, code: 'no_pack');

    final known = await store.guest(s.eventId, invitationId);
    final guest = known ?? DoorGuest(id: invitationId, name: '', maxCompanions: maxCompanions);
    final max = known?.maxCompanions ?? maxCompanions;
    final warnings = DoorRules.warnings(guest: guest, gate: _gate, unlisted: known == null);
    final now = clock.nowUtc();

    // The QR works on the event's day only, for a return too.
    final eventBlocker = DoorRules.eventBlocker(meta.event, now);
    if (eventBlocker != null) {
      return DoorAdmission(admitted: false, code: eventBlocker, guest: guest, maxCompanions: max, warnings: warnings);
    }
    final first = await store.firstCheckIn(s.eventId, invitationId, day: _today);
    if (first != null) {
      return DoorAdmission(
        admitted: true,
        returning: true,
        guest: guest.withCheckIn(first),
        checkIn: first,
        warnings: warnings,
      );
    }
    final blocker = DoorRules.companionsBlocker(companions, max);
    if (blocker != null) {
      return DoorAdmission(admitted: false, code: blocker, guest: guest, maxCompanions: max, warnings: warnings);
    }

    final record = DoorCheckInRecord(
      uuid: Uuid.v4(),
      eventId: s.eventId,
      invitationId: invitationId,
      checkedInAt: now,
      companions: companions,
      gateId: s.gateId,
      deviceUuid: _deviceUuid,
      deviceName: s.deviceName,
      source: manual ? 'manual' : 'offline',
      origin: 'local',
      syncState: 'pending',
      notes: notes,
    );

    // 1. The server, when it answered recently.
    final viaServer = await _claimOnServer(s, record, guest, max, warnings);
    if (viaServer != null) return viaServer;

    // 2. The venue hub this phone joined.
    final viaHub = await _claimOnHub(s, record, guest, max, warnings);
    if (viaHub != null) return viaHub;

    // 3. This phone decides (it is the hub, or it is alone).
    final kept = record.copyWith(source: (_hub?.running ?? false) ? 'lan' : record.source);
    await store.addCheckIn(kept);
    _hub?.notifyChanged();
    onQueued?.call();
    await _refresh();
    return DoorAdmission(admitted: true, guest: guest.withCheckIn(kept), checkIn: kept, warnings: warnings);
  });

  /// The joined hub's yes or no. Null when there is no hub or it did not
  /// answer in time (this phone then decides alone).
  Future<DoorAdmission?> _claimOnHub(
    DoorSession s,
    DoorCheckInRecord record,
    DoorGuest guest,
    int? max,
    List<String> warnings,
  ) async {
    final peer = _peer;
    if (peer == null || !_hubReachable) return null;
    try {
      final res = await peer.claim(record.toLanJson()..['source'] = 'lan');
      if (res['result'] == 'admitted') {
        final kept = record.copyWith(source: 'lan', syncState: res['synced'] == true ? 'synced' : 'pending');
        await store.addCheckIn(kept);
        await _refresh();
        return DoorAdmission(
          admitted: true,
          guest: guest.withCheckIn(kept),
          checkIn: kept,
          decidedBy: DoorDecidedBy.hub,
          warnings: warnings,
        );
      }
      final other = res['check_in'];
      DoorCheckInRecord? theirs;
      if (other is Map) {
        theirs = DoorCheckInRecord.fromLanJson(s.eventId, Map<String, dynamic>.from(other), origin: 'peer');
        await store.mergeLanRecords(s.eventId, [theirs]);
      }
      // Another door let them in first: they came back.
      if (res['result'] == 'returned') {
        await _refresh();
        return DoorAdmission(
          admitted: true,
          returning: true,
          guest: guest.withCheckIn(theirs),
          checkIn: theirs,
          decidedBy: DoorDecidedBy.hub,
          warnings: warnings,
        );
      }
      return DoorAdmission(
        admitted: false,
        code: '${res['code'] ?? 'refused'}',
        guest: guest.withCheckIn(theirs),
        checkIn: theirs,
        decidedBy: DoorDecidedBy.hub,
        maxCompanions: max,
      );
    } catch (_) {
      _hubReachable = false;
      return null;
    }
  }
}
