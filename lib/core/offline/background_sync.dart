import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/scanner/data/datasources/door_remote_data_source.dart';
import '../../features/scanner/data/datasources/door_store.dart';
import '../../features/scanner/data/door_engine.dart';
import '../../features/scanner/data/door_session_manager.dart';
import '../../features/scanner/domain/entities/door_entities.dart';
import '../utils/storage/secure_storage_service.dart';
import 'offline_database.dart';
import 'pending_actions_queue.dart';

/// Uploads what was recorded offline even when the app is closed: door
/// check-ins first, then the queued writes.
///
/// Android (WorkManager): a periodic task every 15 minutes with a "network
/// connected" constraint, plus a one-off task each time something is queued,
/// so the upload runs by itself as soon as the phone gets a connection.
/// iOS (BGTaskScheduler): best effort, iOS decides when; the app also syncs
/// whenever it is opened.
class BackgroundSync {
  BackgroundSync._();

  static const String taskName = 'maktoob.offline.sync';

  /// Also the BGTaskSchedulerPermittedIdentifiers entry in ios/Runner/Info.plist.
  static const String periodicId = 'com.maktoob.maktoob.offlineSync';
  static const String oneOffId = 'maktoob-offline-sync-now';

  static bool _ready = false;

  static Future<void> initialize() async {
    if (kIsWeb || _ready) return;
    try {
      await Workmanager().initialize(offlineSyncDispatcher);
      await Workmanager().registerPeriodicTask(
        periodicId,
        taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      _ready = true;
    } catch (e) {
      debugPrint('Background sync unavailable: $e');
    }
  }

  /// Something waits to upload: run as soon as there is a connection.
  static Future<void> scheduleSoon() async {
    if (kIsWeb || !_ready) return;
    try {
      await Workmanager().registerOneOffTask(
        oneOffId,
        taskName,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );
    } catch (_) {}
  }

  /// One pass, in whatever isolate runs it (background task or app).
  static Future<void> runOnce() async {
    // Its own connection: on Android sqflite shares one native connection
    // per path inside the process, so closing a shared one below would also
    // close the app's (found on a device: "database_closed" at the door).
    final db = await OfflineDatabase.open(singleInstance: false);
    try {
      const secure = SecureStorageService.storage;
      Future<String?> tokenFor(DoorSession s) => switch (s.kind) {
            DoorSessionKind.client => secure.read(key: SecureStorageKeys.token),
            DoorSessionKind.paired || DoorSessionKind.scanner => secure.read(
                key: '${SecureStorageKeys.doorPrefix}${DoorSessionManager.tokenKey(s.id)}',
              ),
            DoorSessionKind.lan => Future.value(null),
          };

      await DoorEngine.syncAll(SqliteDoorStore(db), DoorRemoteDataSource(DoorHttp(tokenFor: tokenFor)));
      await PendingActionsQueue(
        database: () async => db,
        token: () => secure.read(key: SecureStorageKeys.token),
      ).flush();
    } finally {
      await db.close();
    }
  }
}

/// While the app is open: one pass at launch and one each time the
/// connection comes back (every event's door, then the queued writes).
class ForegroundSync {
  ForegroundSync._();

  static StreamSubscription<bool>? _sub;
  static bool _running = false;

  static void start({
    required DoorStore store,
    required DoorRemoteDataSource remote,
    required DoorEngine engine,
    required PendingActionsQueue queue,
    required Stream<bool> connectivity,
  }) {
    Future<void> run() async {
      if (_running) return;
      _running = true;
      try {
        await DoorEngine.syncAll(store, remote, skip: engine.session?.id);
        await queue.flush();
      } catch (_) {
        // Offline again: the next connection (or the background task) retries.
      } finally {
        _running = false;
      }
    }

    unawaited(run());
    _sub ??= connectivity.listen((up) {
      if (up) unawaited(run());
    });
  }
}

/// Entry point of the background isolate (must be top level).
@pragma('vm:entry-point')
void offlineSyncDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    try {
      await BackgroundSync.runOnce();
      return true;
    } catch (e) {
      debugPrint('Background sync failed: $e');
      // false = retry later with backoff.
      return false;
    }
  });
}
