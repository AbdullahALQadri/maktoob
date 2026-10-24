part of '../sqlite_door_store.dart';

/// This phone's id, small settings, and the door sessions it opened.
mixin _SettingsAndSessions on _SqliteStoreBase {
  @override
  Future<String> deviceUuid() async {
    final rows = await db.query('kv', where: 'key = ?', whereArgs: ['device_uuid']);
    if (rows.isNotEmpty) return '${rows.first['value']}';
    await db.insert('kv', {'key': 'device_uuid', 'value': Uuid.v4()}, conflictAlgorithm: ConflictAlgorithm.ignore);
    final again = await db.query('kv', where: 'key = ?', whereArgs: ['device_uuid']);
    return '${again.first['value']}';
  }

  @override
  Future<String?> value(String key) async {
    final rows = await db.query('kv', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  @override
  Future<void> setValue(String key, String? value) async {
    if (value == null) {
      await db.delete('kv', where: 'key = ?', whereArgs: [key]);
    } else {
      await db.insert('kv', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  @override
  Future<void> saveSession(DoorSession s) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await db.query('door_sessions', columns: ['created_at'], where: 'id = ?', whereArgs: [s.id]);
    await db.insert('door_sessions', {
      'id': s.id,
      'kind': s.kind.name,
      'event_id': s.eventId,
      'event_title': s.eventTitle,
      'device_name': s.deviceName,
      'gate_id': s.gateId,
      'lan_join': s.lanJoin,
      'needs_auth': s.needsAuth ? 1 : 0,
      'revoked': s.revoked ? 1 : 0,
      'created_at': existing.isEmpty ? now : existing.first['created_at'],
      'last_used_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<DoorSession?> session(String id) async {
    final rows = await db.query('door_sessions', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _session(rows.first);
  }

  @override
  Future<List<DoorSession>> sessions() async =>
      (await db.query('door_sessions', orderBy: 'last_used_at DESC')).map(_session).toList();

  @override
  Future<void> deleteSession(String id) => db.delete('door_sessions', where: 'id = ?', whereArgs: [id]);
}
