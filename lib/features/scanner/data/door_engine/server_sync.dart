part of '../door_engine.dart';

/// Talking to the server: the live claim at the door, and the sync (the
/// pack, this phone's check-ins up, the other doors' check-ins down).
mixin _DoorServerSync on _DoorEngineBase {
  /// A live claim. Null when the server could not be asked in time (the
  /// caller decides another way); otherwise the server's yes or no.
  @override
  Future<DoorAdmission?> _claimOnServer(
    DoorSession s,
    DoorCheckInRecord record,
    DoorGuest guest,
    int? max,
    List<String> warnings, {
    Duration? timeout,
  }) async {
    if (!_serverLikely) return null;
    try {
      final res = await remote!.upload(
        s,
        [record.toUploadJson(sourceOverride: 'online')],
        _deviceInfo(s, pending: _status.pending),
        clock.nowUtc(),
        timeout: timeout ?? liveTimeout,
      );
      clock.observe(res.serverTime);
      _serverOkAt = DateTime.now();
      if (res.results.isEmpty) return null;
      final r = res.results.first;
      if (r.accepted) {
        final kept = record.copyWith(syncState: 'synced', source: 'online');
        await store.addCheckIn(kept);
        _hub?.notifyChanged();
        unawaited(_pushToHub());
        await _refresh();
        return DoorAdmission(
          admitted: true,
          guest: guest.withCheckIn(kept),
          checkIn: kept,
          decidedBy: DoorDecidedBy.server,
          warnings: warnings,
        );
      }
      if (r.checkIn != null) await store.mergeCheckIns(s.eventId, [r.checkIn!], origin: 'server');
      // Another door let them in first: they came back (nothing kept here).
      if (r.returned) {
        await _refresh();
        return DoorAdmission(
          admitted: true,
          returning: true,
          guest: guest.withCheckIn(r.checkIn),
          checkIn: r.checkIn,
          decidedBy: DoorDecidedBy.server,
          warnings: warnings,
        );
      }
      return DoorAdmission(
        admitted: false,
        code: r.code ?? 'refused',
        message: r.message,
        guest: guest.withCheckIn(r.checkIn),
        checkIn: r.checkIn,
        decidedBy: DoorDecidedBy.server,
        maxCompanions: r.maxCompanions ?? max,
      );
    } on DoorHttpException catch (e) {
      if (e.kind == DoorErrorKind.auth || e.kind == DoorErrorKind.revoked) await _markAuth(e.kind);
      _serverOkAt = null;
      return null;
    } catch (_) {
      _serverOkAt = null;
      return null;
    }
  }

  @override
  Future<void> syncNow({bool refreshPack = false}) async {
    final s = _session;
    if (s == null || _syncing) return;

    if (!s.hasServer || remote == null || s.revoked || s.needsAuth) {
      if (_peer != null) {
        try {
          await _pushToHub();
        } catch (_) {}
      }
      return;
    }

    _syncing = true;
    await _refresh();
    try {
      if (_meta == null || refreshPack) await _downloadPack(s);
      await _uploadPending(s);
      await _pullChanges(s);
      _serverOkAt = DateTime.now();
      _problem = null;
      await store.updatePackMeta(s.eventId, lastSyncAt: DateTime.now().toUtc(), clockOffsetMs: clock.offsetMs);
    } on DoorHttpException catch (e) {
      switch (e.kind) {
        case DoorErrorKind.auth:
        case DoorErrorKind.revoked:
          await _markAuth(e.kind);
        case DoorErrorKind.refused:
          _problem = e.status == 403 ? 'forbidden' : 'sync_failed';
          _serverOkAt = null;
        case DoorErrorKind.network:
        case DoorErrorKind.server:
          _serverOkAt = null;
      }
    } catch (_) {
      _serverOkAt = null;
    } finally {
      _syncing = false;
      if (_session?.id == s.id) {
        _meta = await store.packMeta(s.eventId);
        await _refresh();
      }
    }
  }

  /// After signing in again: the session may sync again.
  @override
  Future<void> clearAuthProblem() async {
    final s = _session;
    if (s == null) return;
    _session = s.copyWith(needsAuth: false);
    _problem = null;
    await store.saveSession(_session!);
    await syncNow();
  }

  Future<void> _downloadPack(DoorSession s) async {
    final pack = await remote!.pack(s, _deviceInfo(s, pending: await store.pendingCount(s.eventId)));
    clock.observe(pack.serverTime);
    await store.savePack(pack, downloadedAt: DateTime.now().toUtc(), clockOffsetMs: clock.offsetMs);
    _meta = await store.packMeta(s.eventId);
    if (pack.event.title.isNotEmpty && pack.event.title != s.eventTitle && _session?.id == s.id) {
      _session = s.copyWith(eventTitle: pack.event.title);
      await store.saveSession(_session!);
    }
    _hub?.notifyChanged();
  }

  Future<void> _uploadPending(DoorSession s) async {
    for (var round = 0; round < 25; round++) {
      final batch = await store.pendingUploads(s.eventId, limit: 200);
      if (batch.isEmpty) return;
      try {
        final res = await remote!.upload(
          s,
          batch.map((r) => r.toUploadJson()).toList(),
          _deviceInfo(s, pending: await store.pendingCount(s.eventId)),
          clock.nowUtc(),
        );
        clock.observe(res.serverTime);
        final byUuid = {for (final r in res.results) r.uuid: r};
        final unanswered = <String>[];
        for (final item in batch) {
          final r = byUuid[item.uuid];
          if (r == null) {
            unanswered.add(item.uuid);
          } else if (r.accepted) {
            await store.markUpload(item.uuid, 'synced', code: r.flag);
          } else if (r.returned) {
            // Another door had let them in first: settled, nothing to retry.
            await store.markUpload(item.uuid, 'returned');
          } else {
            await store.markUpload(item.uuid, 'refused', code: r.code);
          }
        }
        await store.bumpAttempts(unanswered);
        if (unanswered.length == batch.length) return;
      } on DoorHttpException catch (e) {
        // The batch itself was rejected (malformed): never retry it forever.
        if (e.kind == DoorErrorKind.refused && e.status == 422) {
          for (final item in batch) {
            await store.markUpload(item.uuid, 'refused', code: 'invalid');
          }
          continue;
        }
        rethrow;
      }
    }
  }

  Future<void> _pullChanges(DoorSession s) async {
    var meta = _meta ?? await store.packMeta(s.eventId);
    if (meta == null) return;
    var since = meta.cursor;
    for (var page = 0; page < 40; page++) {
      final ch = await remote!.changes(s, since, _deviceInfo(s, pending: await store.pendingCount(s.eventId)));
      clock.observe(ch.serverTime);
      if (await store.mergeCheckIns(s.eventId, ch.checkIns, origin: 'server') > 0) _hub?.notifyChanged();
      since = ch.cursor;
      await store.updatePackMeta(s.eventId, cursor: since, eventStatus: ch.eventStatus);
      if (ch.rosterVersion != null && ch.rosterVersion != meta?.rosterVersion) {
        // A guest added / removed, an RSVP, the event's rules: take the new list.
        await _downloadPack(s);
        meta = _meta;
      }
      if (!ch.hasMore) return;
    }
  }
}
