part of '../sqlite_door_store.dart';

/// The event's pack (rules, gates, keys) and its guest list.
mixin _PackAndGuests on _SqliteStoreBase {
  @override
  Future<void> savePack(DoorPackModel pack, {required DateTime downloadedAt, required int clockOffsetMs}) async {
    final eventId = pack.event.id;
    await db.transaction((txn) async {
      final previous = await txn.query(
        'door_packs',
        columns: ['last_sync_at'],
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      await txn.insert('door_packs', {
        'event_id': eventId,
        'format': pack.format,
        'event_json': jsonEncode(DoorJson.eventToJson(pack.event)),
        'gates_json': jsonEncode(pack.gates.map(DoorJson.gateToJson).toList()),
        'salt': pack.salt,
        'sign': pack.sign,
        'cursor': pack.cursor,
        'roster_version': pack.rosterVersion,
        'downloaded_at': _ms(downloadedAt),
        'last_sync_at': previous.isEmpty ? _ms(downloadedAt) : (previous.first['last_sync_at'] ?? _ms(downloadedAt)),
        'clock_offset_ms': clockOffsetMs,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.delete('door_guests', where: 'event_id = ?', whereArgs: [eventId]);
      await txn.delete('door_keys', where: 'event_id = ?', whereArgs: [eventId]);

      final batch = txn.batch();
      for (final entry in pack.guests) {
        _guestRow(batch, eventId, entry);
      }
      await batch.commit(noResult: true);

      final checkIns = pack.guests.map((g) => g.guest.checkIn).whereType<DoorCheckIn>().toList();
      await _merge(txn, eventId, checkIns, origin: 'server', synced: true);
    });
  }

  @override
  Future<DoorPackMeta?> packMeta(int eventId) async {
    final rows = await db.query('door_packs', where: 'event_id = ?', whereArgs: [eventId]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    final salt = '${r['salt']}';
    final sign = '${r['sign']}';
    return DoorPackMeta(
      eventId: eventId,
      event: DoorJson.event(Map<String, dynamic>.from(jsonDecode('${r['event_json']}') as Map)),
      gates: (jsonDecode('${r['gates_json']}') as List)
          .map((g) => DoorJson.gate(Map<String, dynamic>.from(g as Map)))
          .toList(),
      salt: DoorCrypto.decodeKey(salt),
      sign: DoorCrypto.decodeKey(sign),
      saltEncoded: salt,
      signEncoded: sign,
      cursor: r['cursor'] as int,
      rosterVersion: r['roster_version'] as String?,
      downloadedAt: _at(r['downloaded_at'] as int),
      lastSyncAt: r['last_sync_at'] == null ? null : _at(r['last_sync_at'] as int),
      clockOffsetMs: r['clock_offset_ms'] as int,
    );
  }

  @override
  Future<void> updatePackMeta(
    int eventId, {
    int? cursor,
    String? eventStatus,
    int? clockOffsetMs,
    DateTime? lastSyncAt,
  }) async {
    final values = <String, Object?>{
      'cursor': ?cursor,
      'clock_offset_ms': ?clockOffsetMs,
      if (lastSyncAt != null) 'last_sync_at': _ms(lastSyncAt),
    };
    if (eventStatus != null) {
      final meta = await packMeta(eventId);
      if (meta != null && meta.event.status != eventStatus) {
        values['event_json'] = jsonEncode(DoorJson.eventToJson(meta.event.copyWith(status: eventStatus)));
      }
    }
    if (values.isEmpty) return;
    await db.update('door_packs', values, where: 'event_id = ?', whereArgs: [eventId]);
  }

  @override
  Future<void> upsertGuest(int eventId, DoorPackGuest guest) async {
    final batch = db.batch();
    _guestRow(batch, eventId, guest);
    await batch.commit(noResult: true);
    final checkIn = guest.guest.checkIn;
    if (checkIn != null) await mergeCheckIns(eventId, [checkIn], origin: 'server');
  }

  @override
  Future<DoorGuest?> guestByHash(int eventId, String hash) async {
    final rows = await db.rawQuery(
      'SELECT g.* FROM door_keys k JOIN door_guests g ON g.event_id = k.event_id AND g.invitation_id = k.invitation_id '
      'WHERE k.event_id = ? AND k.hash = ? LIMIT 1',
      [eventId, hash],
    );
    return rows.isEmpty ? null : _guest(rows.first);
  }

  @override
  Future<DoorGuest?> guest(int eventId, int invitationId) async {
    final rows = await db.query(
      'door_guests',
      where: 'event_id = ? AND invitation_id = ?',
      whereArgs: [eventId, invitationId],
      limit: 1,
    );
    return rows.isEmpty ? null : _guest(rows.first);
  }

  @override
  Future<List<DoorGuest>> guests(int eventId, {String query = '', int limit = 500, DoorDay? day}) async {
    final q = _normalize(query);
    final rows = await db.query(
      'door_guests',
      where: q.isEmpty ? 'event_id = ?' : 'event_id = ? AND search LIKE ?',
      whereArgs: q.isEmpty ? [eventId] : [eventId, '%$q%'],
      orderBy: 'name COLLATE NOCASE',
      limit: limit,
    );
    if (rows.isEmpty) return const [];
    final firsts = await _firstCheckIns(eventId, rows.map((r) => r['invitation_id'] as int).toList(), day: day);
    return rows.map((r) {
      final g = _guest(r);
      return g.withCheckIn(firsts[g.id]);
    }).toList();
  }
}
