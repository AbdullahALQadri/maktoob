part of '../sqlite_door_store.dart';

/// Check-ins: recorded here, received from the server or the venue hub,
/// and their upload state.
mixin _CheckIns on _SqliteStoreBase {
  @override
  Future<bool> addCheckIn(DoorCheckInRecord record) => db.transaction((txn) async {
    final exists = await txn.query('door_check_ins', columns: ['uuid'], where: 'uuid = ?', whereArgs: [record.uuid]);
    if (exists.isNotEmpty) return false;
    await txn.insert('door_check_ins', _checkInRow(record, await _nextSeq(txn, record.eventId)));
    return true;
  });

  @override
  Future<int> mergeCheckIns(int eventId, List<DoorCheckIn> checkIns, {required String origin, bool synced = true}) =>
      db.transaction((txn) => _merge(txn, eventId, checkIns, origin: origin, synced: synced));

  @override
  Future<void> mergeLanRecords(int eventId, List<DoorCheckInRecord> records) => db.transaction((txn) async {
    var seq = await _nextSeq(txn, eventId);
    for (final r in records) {
      final existing = await txn.query(
        'door_check_ins',
        columns: ['sync_state'],
        where: 'uuid = ?',
        whereArgs: [r.uuid],
      );
      if (existing.isNotEmpty) {
        if (r.syncState == 'synced' && existing.first['sync_state'] == 'pending') {
          await txn.update('door_check_ins', {'sync_state': 'synced'}, where: 'uuid = ?', whereArgs: [r.uuid]);
        }
        continue;
      }
      await txn.insert('door_check_ins', _checkInRow(r.copyWith(origin: 'peer'), seq++));
    }
  });

  @override
  Future<DoorCheckIn?> firstCheckIn(int eventId, int invitationId, {DoorDay? day}) async {
    final (onDay, dayArgs) = _onDay(day);
    final rows = await db.query(
      'door_check_ins',
      where: 'event_id = ? AND invitation_id = ? AND sync_state != ?$onDay',
      whereArgs: [eventId, invitationId, 'refused', ...dayArgs],
      orderBy: 'checked_in_at ASC',
      limit: 1,
    );
    return rows.isEmpty ? null : _record(rows.first);
  }

  @override
  Future<List<DoorCheckInRecord>> pendingUploads(int eventId, {int limit = 200}) async => (await db.query(
    'door_check_ins',
    where: 'event_id = ? AND sync_state = ? AND origin != ?',
    whereArgs: [eventId, 'pending', 'server'],
    orderBy: 'checked_in_at ASC',
    limit: limit,
  )).map(_record).toList();

  @override
  Future<void> markUpload(String uuid, String state, {String? code}) =>
      db.update('door_check_ins', {'sync_state': state, 'sync_code': code}, where: 'uuid = ?', whereArgs: [uuid]);

  @override
  Future<void> bumpAttempts(List<String> uuids) async {
    if (uuids.isEmpty) return;
    await db.rawUpdate(
      'UPDATE door_check_ins SET attempts = attempts + 1 WHERE uuid IN (${List.filled(uuids.length, '?').join(',')})',
      uuids,
    );
  }

  @override
  Future<List<DoorCheckInRecord>> lanRecordsSince(int eventId, int seq, {int limit = 500}) async => (await db.query(
    'door_check_ins',
    where: 'event_id = ? AND lan_seq > ? AND sync_state != ?',
    whereArgs: [eventId, seq, 'refused'],
    orderBy: 'lan_seq ASC',
    limit: limit,
  )).map(_record).toList();

  @override
  Future<int> maxLanSeq(int eventId) async {
    final rows = await db.rawQuery('SELECT MAX(lan_seq) AS m FROM door_check_ins WHERE event_id = ?', [eventId]);
    return (rows.first['m'] as int?) ?? 0;
  }
}
