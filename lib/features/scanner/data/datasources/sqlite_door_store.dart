import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/uuid.dart';
import '../../domain/entities/door_entities.dart';
import '../../domain/logic/door_crypto.dart';
import '../models/door_models.dart';
import 'door_store.dart';

part 'sqlite_door_store/check_ins.dart';
part 'sqlite_door_store/pack_guests.dart';
part 'sqlite_door_store/reports.dart';
part 'sqlite_door_store/rows.dart';
part 'sqlite_door_store/settings_sessions.dart';

/// The door's data in SQLite (`maktoob_offline.db`, opened by
/// core/offline/offline_database.dart), shared by the app and the
/// background upload task.
///
/// The parts: rows.dart (row mapping shared by all), settings_sessions.dart,
/// pack_guests.dart, check_ins.dart, reports.dart (counts, the hub's pack
/// export, purge).
class SqliteDoorStore extends _SqliteStoreBase with _SettingsAndSessions, _PackAndGuests, _CheckIns, _Reports {
  SqliteDoorStore(super.db);
}
