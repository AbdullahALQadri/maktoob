part of '../sqlite_door_store.dart';

/// Counts for the status bar, the pack the venue hub serves, and clean-up.
mixin _Reports on _SqliteStoreBase {
  Future<int> _count(String sql, List<Object?> args) async => Sqflite.firstIntValue(await db.rawQuery(sql, args)) ?? 0;

  @override
  Future<int> guestCount(int eventId) => _count('SELECT COUNT(*) FROM door_guests WHERE event_id = ?', [eventId]);

  @override
  Future<int> checkedInCount(int eventId) => _count(
    'SELECT COUNT(DISTINCT invitation_id) FROM door_check_ins WHERE event_id = ? AND sync_state != ?',
    [eventId, 'refused'],
  );

  @override
  Future<int> pendingCount(int eventId) => _count(
    'SELECT COUNT(*) FROM door_check_ins WHERE event_id = ? AND sync_state = ? AND origin != ?',
    [eventId, 'pending', 'server'],
  );

  @override
  Future<int> refusedCount(int eventId) =>
      _count('SELECT COUNT(*) FROM door_check_ins WHERE event_id = ? AND sync_state = ?', [eventId, 'refused']);

  @override
  Future<Map<String, dynamic>> exportPack(int eventId) async {
    final meta = await packMeta(eventId);
    if (meta == null) return const {};
    final guestRows = await db.query('door_guests', where: 'event_id = ?', whereArgs: [eventId]);
    final keyRows = await db.query('door_keys', where: 'event_id = ?', whereArgs: [eventId]);
    final hashes = <int, List<String>>{};
    for (final k in keyRows) {
      hashes.putIfAbsent(k['invitation_id'] as int, () => []).add('${k['hash']}');
    }
    final firsts = await _firstCheckIns(eventId, guestRows.map((r) => r['invitation_id'] as int).toList());

    return DoorPackModel(
      format: 1,
      event: meta.event,
      gates: meta.gates,
      salt: meta.saltEncoded,
      sign: meta.signEncoded,
      serverTime: DateTime.now().toUtc().add(Duration(milliseconds: meta.clockOffsetMs)),
      cursor: meta.cursor,
      rosterVersion: meta.rosterVersion,
      guests: guestRows.map((r) {
        final g = _guest(r);
        return DoorPackGuest(g.withCheckIn(firsts[g.id]), hashes[g.id] ?? const []);
      }).toList(),
    ).toJson();
  }

  @override
  Future<List<int>> eventsWithPending() async => (await db.rawQuery(
    'SELECT DISTINCT event_id FROM door_check_ins WHERE sync_state = ? AND origin != ?',
    ['pending', 'server'],
  )).map((r) => r['event_id'] as int).toList();

  @override
  Future<int> purge(DateTime nowUtc, {Duration retention = const Duration(days: 3)}) async {
    var dropped = 0;
    for (final row in await db.query('door_packs', columns: ['event_id'])) {
      final eventId = row['event_id'] as int;
      final meta = await packMeta(eventId);
      final end = meta?.event.validUntil ?? meta?.event.eventDate;
      if (end == null || nowUtc.isBefore(end.add(retention))) continue;
      if (await pendingCount(eventId) > 0) continue;
      await db.transaction((txn) async {
        for (final table in ['door_packs', 'door_guests', 'door_keys', 'door_check_ins']) {
          await txn.delete(table, where: 'event_id = ?', whereArgs: [eventId]);
        }
        await txn.delete('door_sessions', where: 'event_id = ?', whereArgs: [eventId]);
      });
      dropped++;
    }
    return dropped;
  }
}
