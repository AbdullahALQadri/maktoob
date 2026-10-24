import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maktoob/core/offline/background_sync.dart';
import 'package:maktoob/core/offline/offline_database.dart';
import 'package:maktoob/core/utils/storage/secure_storage_service.dart';
import 'package:maktoob/features/scanner/data/datasources/door_remote_data_source.dart';
import 'package:maktoob/features/scanner/data/datasources/door_store.dart';
import 'package:maktoob/features/scanner/data/door_engine.dart';
import 'package:maktoob/features/scanner/data/door_session_manager.dart';
import 'package:maktoob/features/scanner/data/lan/lan_protocol.dart';
import 'package:maktoob/features/scanner/domain/entities/door_entities.dart';
import 'package:maktoob/injection_container.dart' as di;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The offline door on a real Android device, against a real backend:
/// SQLite, secure storage, HTTP, the venue hub's server, the foreground
/// service and WorkManager are the real ones. Nothing is faked except the
/// "no internet" leg (a door API address that does not answer).
///
/// Run (backend seeded by the e2e seed script, served on the host):
///   flutter test integration_test/offline_door_e2e_test.dart -d DEVICE
///     --dart-define=API_BASE_URL=http://10.0.2.2:8010/api/v1
///     --dart-define=E2E_SEED=BASE64_OF_SEED_JSON
///     [--dart-define=E2E_HOLD_SECONDS=75]   (hold the hub up for host checks)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final seed = jsonDecode(utf8.decode(base64.decode(const String.fromEnvironment('E2E_SEED')))) as Map;
  final eventId = seed['event_id'] as int;
  final code = seed['code'] as String;
  final qr = (seed['qr'] as List).cast<String>();
  const holdSeconds = int.fromEnvironment('E2E_HOLD_SECONDS');

  void step(String text) => debugPrint('E2E_STEP $text');

  Future<void> until(Future<bool> Function() ok, {Duration timeout = const Duration(seconds: 30)}) async {
    final end = DateTime.now().add(timeout);
    while (!await ok()) {
      if (DateTime.now().isAfter(end)) fail('timed out');
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
  }

  testWidgets('offline door on a real device', (tester) async {
    await di.init(pushAvailable: false);
    final manager = di.sl<DoorSessionManager>();
    final engine = di.sl<DoorEngine>();
    final store = di.sl<DoorStore>();

    step('1 pair this phone with the door code');
    final session = await manager.pairWithCode(code, 'هاتف التجربة');
    expect(session.kind, DoorSessionKind.paired);
    expect(session.eventId, eventId);

    step('2 download the door pack');
    await engine.open(session);
    await until(() async => engine.status.hasPack && engine.status.link == DoorLink.online);
    expect(engine.status.guests, 4);
    expect(engine.status.gates, hasLength(2));
    expect(engine.status.gate?.name, 'رجال ١', reason: 'the code was made for the men\'s gate');

    step('3 online: the server decides');
    final first = await engine.lookup(qr[0]);
    expect(first.canAdmit, isTrue);
    final admitted = await engine.admit(first.guest!.id, companions: 1);
    expect(admitted.admitted, isTrue);
    expect(admitted.decidedBy, DoorDecidedBy.server);
    // Steps out to the bathroom and comes back with the same QR.
    expect((await engine.lookup(qr[0])).returning, isTrue);
    final back = await engine.admit(first.guest!.id);
    expect(back.admitted && back.returning, isTrue);

    step('4 no internet: the phone decides alone');
    await engine.close(force: true);
    final deadApi = DoorRemoteDataSource(
      DoorHttp(
        tokenFor: (s) => DoorSessionManager.tokenFor(di.sl<SecureStorageService>(), s),
        dio: Dio(BaseOptions(baseUrl: 'http://10.0.2.2:9/api/v1', connectTimeout: const Duration(seconds: 2))),
      ),
    );
    final offline = DoorEngine(store: store, remote: deadApi, syncEvery: null);
    await offline.open(session, live: false);
    expect(offline.status.link, DoorLink.offline);
    final second = await offline.lookup(qr[1]);
    expect(second.canAdmit, isTrue);
    final offlineAdmit = await offline.admit(second.guest!.id);
    expect(offlineAdmit.admitted, isTrue);
    expect(offlineAdmit.decidedBy, DoorDecidedBy.device);
    expect(await store.pendingCount(eventId), 1);
    await offline.close(force: true);

    step('5 WorkManager uploads it in the background isolate');
    await BackgroundSync.initialize();
    await BackgroundSync.scheduleSoon();
    await until(() async => await store.pendingCount(eventId) == 0, timeout: const Duration(minutes: 4));

    step('6 venue hub + a phone that only joins it');
    await engine.open(session);
    await until(() async => engine.status.link == DoorLink.online);
    final joinText = await engine.startHubJoinCode(
      notificationTitle: 'الجهاز الرئيسي للقاعة يعمل',
      notificationText: 'تجربة',
    );
    expect(joinText, isNotNull);
    expect(
      await FlutterForegroundTask.isRunningService,
      isTrue,
      reason: 'the hub keeps the app alive in the background',
    );
    final join = LanJoinInfo.decode(joinText!)!;
    final local = LanJoinInfo(
      hosts: ['127.0.0.1:${engine.hubPort}'],
      eventId: join.eventId,
      eventTitle: join.eventTitle,
      hubName: join.hubName,
      secret: join.secret,
    );
    final peerPath = p.join(await getDatabasesPath(), 'e2e_peer.db');
    if (await File(peerPath).exists()) await deleteDatabase(peerPath);
    final peer = DoorEngine(
      store: SqliteDoorStore(await OfflineDatabase.open(path: peerPath, singleInstance: false)),
      remote: null,
      syncEvery: null,
    );
    await peer.open(
      DoorSession(
        id: DoorSession.idFor(DoorSessionKind.lan, eventId),
        kind: DoorSessionKind.lan,
        eventId: eventId,
        eventTitle: '',
        deviceName: 'باب النساء',
        lanJoin: local.toStorage(),
      ),
    );
    await until(() async => peer.status.hasPack && peer.status.link == DoorLink.hub);
    expect(peer.status.guests, 4, reason: 'the list came from the hub, not the internet');
    final third = await peer.lookup(qr[2]);
    final viaHub = await peer.admit(third.guest!.id);
    expect(viaHub.admitted, isTrue);
    expect(viaHub.decidedBy, DoorDecidedBy.hub);
    // The guest the men's door let in online comes back through the joined
    // door: let in, counted once.
    await until(() async => (await peer.lookup(qr[0])).returning);
    final backViaHub = await peer.admit(first.guest!.id);
    expect(backViaHub.admitted && backViaHub.returning, isTrue);

    if (holdSeconds > 0) {
      step('7 E2E_HUB_PORT=${engine.hubPort} holding ${holdSeconds}s for host checks');
      await Future<void>.delayed(const Duration(seconds: holdSeconds));
      expect(await FlutterForegroundTask.isRunningService, isTrue);
    }

    step('8 everything reached the server');
    await engine.syncNow();
    final summary = await di.sl<DoorRemoteDataSource>().summary(session);
    expect(summary.checkedIn, 3);
    expect(summary.companions, 1);

    await peer.close(force: true);
    await engine.stopHub();
    expect(await FlutterForegroundTask.isRunningService, isFalse);
    await engine.close(force: true);
    step('DONE');
  }, timeout: const Timeout(Duration(minutes: 12)));
}
