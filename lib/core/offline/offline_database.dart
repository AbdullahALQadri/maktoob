import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The app's offline database (SQLite): door packs, door check-ins waiting
/// to upload, and the generic queue of writes made with no connection.
///
/// SQLite, not Hive: the background sync task opens the same file from
/// another isolate, and SQLite locks between connections (Hive does not).
class OfflineDatabase {
  OfflineDatabase._();

  static const String fileName = 'maktoob_offline.db';
  static const int version = 1;

  static Database? _shared;

  /// The app-wide connection (main isolate).
  static Future<Database> shared() async => _shared ??= await open();

  /// Opens (and creates) the database. Tests pass an ffi [factory] and
  /// `inMemoryDatabasePath`.
  static Future<Database> open({DatabaseFactory? factory, String? path, bool singleInstance = true}) async {
    final f = factory ?? databaseFactory;
    final location = path ?? p.join(await f.getDatabasesPath(), fileName);
    return f.openDatabase(
      location,
      options: OpenDatabaseOptions(
        version: version,
        singleInstance: singleInstance,
        onConfigure: (db) async {
          // The background task and the app may write at the same time.
          await db.rawQuery('PRAGMA busy_timeout = 5000');
          if (location != inMemoryDatabasePath) {
            await db.rawQuery('PRAGMA journal_mode = WAL');
          }
        },
        onCreate: (db, _) => _create(db),
      ),
    );
  }

  static Future<void> _create(Database db) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE kv (
        key TEXT PRIMARY KEY,
        value TEXT
      )''');
    batch.execute('''
      CREATE TABLE door_sessions (
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        event_id INTEGER NOT NULL,
        event_title TEXT NOT NULL,
        device_name TEXT NOT NULL,
        gate_id INTEGER,
        lan_join TEXT,
        needs_auth INTEGER NOT NULL DEFAULT 0,
        revoked INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        last_used_at INTEGER NOT NULL
      )''');
    batch.execute('''
      CREATE TABLE door_packs (
        event_id INTEGER PRIMARY KEY,
        format INTEGER NOT NULL,
        event_json TEXT NOT NULL,
        gates_json TEXT NOT NULL,
        salt TEXT NOT NULL,
        sign TEXT NOT NULL,
        cursor INTEGER NOT NULL DEFAULT 0,
        roster_version TEXT,
        downloaded_at INTEGER NOT NULL,
        last_sync_at INTEGER,
        clock_offset_ms INTEGER NOT NULL DEFAULT 0,
        -- Unused: double admissions are gone (a second scan is a return).
        -- Kept because older Android SQLite cannot drop a column.
        open_conflicts INTEGER NOT NULL DEFAULT 0
      )''');
    batch.execute('''
      CREATE TABLE door_guests (
        event_id INTEGER NOT NULL,
        invitation_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        name_en TEXT,
        gender TEXT,
        phone_tail TEXT,
        companions INTEGER NOT NULL DEFAULT 0,
        max_companions INTEGER,
        rsvp TEXT NOT NULL DEFAULT 'no_response',
        search TEXT NOT NULL DEFAULT '',
        PRIMARY KEY (event_id, invitation_id)
      )''');
    batch.execute('''
      CREATE TABLE door_keys (
        event_id INTEGER NOT NULL,
        hash TEXT NOT NULL,
        invitation_id INTEGER NOT NULL,
        PRIMARY KEY (event_id, hash)
      )''');
    batch.execute('''
      CREATE TABLE door_check_ins (
        uuid TEXT PRIMARY KEY,
        event_id INTEGER NOT NULL,
        invitation_id INTEGER NOT NULL,
        checked_in_at INTEGER NOT NULL,
        companions INTEGER NOT NULL DEFAULT 0,
        gate_id INTEGER,
        device_uuid TEXT,
        device_name TEXT,
        source TEXT,
        origin TEXT NOT NULL,
        sync_state TEXT NOT NULL,
        sync_code TEXT,
        notes TEXT,
        attempts INTEGER NOT NULL DEFAULT 0,
        lan_seq INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )''');
    batch.execute('CREATE INDEX door_check_ins_invitation ON door_check_ins (event_id, invitation_id)');
    batch.execute('CREATE INDEX door_check_ins_sync ON door_check_ins (event_id, sync_state)');
    batch.execute('CREATE INDEX door_check_ins_seq ON door_check_ins (event_id, lan_seq)');
    batch.execute('''
      CREATE TABLE pending_actions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner TEXT NOT NULL,
        label TEXT NOT NULL,
        label_args TEXT,
        method TEXT NOT NULL,
        path TEXT NOT NULL,
        body TEXT,
        idempotency_key TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )''');
    await batch.commit(noResult: true);
  }
}
