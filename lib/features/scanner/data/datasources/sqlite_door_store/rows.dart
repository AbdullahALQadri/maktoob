part of '../sqlite_door_store.dart';

int _ms(DateTime d) => d.toUtc().millisecondsSinceEpoch;
DateTime _at(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

/// Arabic-tolerant search text: no diacritics, one alef, ta marbuta → ha.
String _normalize(String input) => input
    .toLowerCase()
    .replaceAll(RegExp('[ً-ْٰـ]'), '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

/// The database and the row mapping every part shares.
abstract class _SqliteStoreBase implements DoorStore {
  final Database db;

  _SqliteStoreBase(this.db);

  DoorSession _session(Map<String, Object?> r) => DoorSession(
    id: '${r['id']}',
    kind: DoorSessionKind.values.firstWhere((k) => k.name == r['kind'], orElse: () => DoorSessionKind.client),
    eventId: r['event_id'] as int,
    eventTitle: '${r['event_title']}',
    deviceName: '${r['device_name']}',
    gateId: r['gate_id'] as int?,
    lanJoin: r['lan_join'] as String?,
    needsAuth: r['needs_auth'] == 1,
    revoked: r['revoked'] == 1,
  );

  void _guestRow(Batch batch, int eventId, DoorPackGuest entry) {
    final g = entry.guest;
    batch.insert('door_guests', {
      'event_id': eventId,
      'invitation_id': g.id,
      'name': g.name,
      'name_en': g.nameEn,
      'gender': g.gender,
      'phone_tail': g.phoneTail,
      'companions': g.companions,
      'max_companions': g.maxCompanions,
      'rsvp': g.rsvp,
      'search': _normalize('${g.name} ${g.nameEn ?? ''} ${g.phoneTail ?? ''}'),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    for (final hash in entry.hashes) {
      batch.insert('door_keys', {
        'event_id': eventId,
        'hash': hash,
        'invitation_id': g.id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  DoorGuest _guest(Map<String, Object?> r) => DoorGuest(
    id: r['invitation_id'] as int,
    name: '${r['name']}',
    nameEn: r['name_en'] as String?,
    gender: r['gender'] as String?,
    phoneTail: r['phone_tail'] as String?,
    companions: r['companions'] as int,
    maxCompanions: r['max_companions'] as int?,
    rsvp: '${r['rsvp']}',
  );

  Map<String, Object?> _checkInRow(DoorCheckInRecord r, int seq) => {
    'uuid': r.uuid,
    'event_id': r.eventId,
    'invitation_id': r.invitationId,
    'checked_in_at': _ms(r.checkedInAt),
    'companions': r.companions,
    'gate_id': r.gateId,
    'device_uuid': r.deviceUuid,
    'device_name': r.deviceName,
    'source': r.source,
    'origin': r.origin,
    'sync_state': r.syncState,
    'sync_code': r.syncCode,
    'notes': r.notes,
    'attempts': r.attempts,
    'lan_seq': seq,
    'created_at': DateTime.now().millisecondsSinceEpoch,
  };

  DoorCheckInRecord _record(Map<String, Object?> r) => DoorCheckInRecord(
    uuid: '${r['uuid']}',
    eventId: r['event_id'] as int,
    invitationId: r['invitation_id'] as int,
    checkedInAt: _at(r['checked_in_at'] as int),
    companions: r['companions'] as int,
    gateId: r['gate_id'] as int?,
    deviceUuid: r['device_uuid'] as String?,
    deviceName: r['device_name'] as String?,
    source: r['source'] as String?,
    origin: '${r['origin']}',
    syncState: '${r['sync_state']}',
    syncCode: r['sync_code'] as String?,
    notes: r['notes'] as String?,
    attempts: r['attempts'] as int,
    lanSeq: r['lan_seq'] as int,
  );

  /// Inside a transaction: SQLite runs one at a time, so no two rows share a seq.
  Future<int> _nextSeq(DatabaseExecutor ex, int eventId) async {
    final rows = await ex.rawQuery('SELECT MAX(lan_seq) AS m FROM door_check_ins WHERE event_id = ?', [eventId]);
    return ((rows.first['m'] as int?) ?? 0) + 1;
  }

  Future<int> _merge(
    Transaction txn,
    int eventId,
    List<DoorCheckIn> checkIns, {
    required String origin,
    required bool synced,
  }) async {
    var added = 0;
    var seq = await _nextSeq(txn, eventId);
    for (final c in checkIns) {
      final existing = await txn.query(
        'door_check_ins',
        columns: ['sync_state'],
        where: 'uuid = ?',
        whereArgs: [c.uuid],
      );
      if (existing.isNotEmpty) {
        // The server has it: our pending copy is uploaded.
        if (synced && existing.first['sync_state'] == 'pending') {
          await txn.update('door_check_ins', {'sync_state': 'synced'}, where: 'uuid = ?', whereArgs: [c.uuid]);
        }
        continue;
      }
      final record = DoorCheckInRecord(
        uuid: c.uuid,
        eventId: eventId,
        invitationId: c.invitationId,
        checkedInAt: c.checkedInAt,
        companions: c.companions,
        gateId: c.gateId,
        deviceName: c.deviceName,
        source: c.source,
        origin: origin,
        syncState: synced ? 'synced' : 'pending',
      );
      await txn.insert('door_check_ins', _checkInRow(record, seq++));
      added++;
    }
    return added;
  }

  Future<Map<int, DoorCheckIn>> _firstCheckIns(int eventId, List<int> invitationIds) async {
    final out = <int, DoorCheckIn>{};
    for (var i = 0; i < invitationIds.length; i += 500) {
      final chunk = invitationIds.sublist(i, i + 500 > invitationIds.length ? invitationIds.length : i + 500);
      final rows = await db.query(
        'door_check_ins',
        where: 'event_id = ? AND invitation_id IN (${List.filled(chunk.length, '?').join(',')}) AND sync_state != ?',
        whereArgs: [eventId, ...chunk, 'refused'],
        orderBy: 'checked_in_at ASC',
      );
      for (final r in rows) {
        out.putIfAbsent(r['invitation_id'] as int, () => _record(r));
      }
    }
    return out;
  }
}
