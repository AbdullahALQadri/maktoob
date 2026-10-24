import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/offline/offline_database.dart';
import 'package:maktoob/features/scanner/data/datasources/door_remote_data_source.dart';
import 'package:maktoob/features/scanner/data/datasources/door_store.dart';
import 'package:maktoob/features/scanner/data/door_engine.dart';
import 'package:maktoob/features/scanner/data/lan/hub_keep_alive.dart';
import 'package:maktoob/features/scanner/data/lan/lan_protocol.dart';
import 'package:maktoob/features/scanner/data/models/door_models.dart';
import 'package:maktoob/features/scanner/domain/entities/door_entities.dart';
import 'package:maktoob/features/scanner/domain/logic/door_crypto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// What the door engine tests share: one event's pack, its QR codes, a fake
/// server, and phones on an in-memory database.

const testEventId = 7;
final _salt = List<int>.generate(32, (i) => i + 1);
final _sign = List<int>.generate(32, (i) => 200 - i);
String _b64(List<int> b) => base64Url.encode(b).replaceAll('=', '');

/// Guests: 1 Sara (code AAAA1111 / link sara00000001), 2 Ahmad, 3 Lina.
Map<String, dynamic> testPack({String status = 'active', int maxCompanions = 2}) {
  Map<String, dynamic> guest(int id, String name, String code, String link, {String? gender}) => {
    'id': id,
    'hashes': [DoorCrypto.lookupHash(_salt, code), DoorCrypto.lookupHash(_salt, link)],
    'name': name,
    'gender': gender,
    'companions': 1,
    'max_companions': maxCompanions,
    'rsvp': 'attending',
    'check_in': null,
  };
  final now = DateTime.now().toUtc();
  return {
    'format': 1,
    'event': {
      'id': testEventId,
      'title': 'عرس',
      'status': status,
      'valid_from': now.subtract(const Duration(hours: 6)).toIso8601String(),
      'valid_until': now.add(const Duration(hours: 6)).toIso8601String(),
    },
    'gates': [
      {'id': 1, 'name': 'رجال ١', 'audience': 'men'},
      {'id': 2, 'name': 'نساء ١', 'audience': 'women'},
    ],
    'keys': {'salt': _b64(_salt), 'sign': _b64(_sign)},
    'server_time': now.toIso8601String(),
    'cursor': 0,
    'roster_version': 'v1',
    'invitations': [
      guest(1, 'سارة', 'AAAA1111', 'sara00000001', gender: 'female'),
      guest(2, 'أحمد', 'BBBB2222', 'ahmad0000002', gender: 'male'),
      guest(3, 'لينا', 'CCCC3333', 'lina00000003'),
    ],
  };
}

/// An invitation's QR text; with [invitation] it carries a signed door token.
String testQr(String link, {int invitation = 0, String max = '2', int event = testEventId}) {
  final token = invitation == 0
      ? ''
      : '?k=$event.$invitation.$max.${DoorCrypto.signature(_sign, event, invitation, max, link)}';
  return 'https://maktoob.social/i/$link$token';
}

/// A server that behaves like App\Services\Door\DoorSyncService.
class FakeServer extends DoorRemoteDataSource {
  FakeServer() : super(DoorHttp(tokenFor: (_) async => 'token'));

  bool online = true;
  Map<String, dynamic> packJson = testPack();
  final List<List<Map<String, dynamic>>> uploads = [];
  final List<DoorCheckIn> checkIns = [];

  /// Items answered `returned` (the invitation had already come in).
  final List<String> returns = [];
  int packDownloads = 0;

  /// A slow uplink: past the caller's timeout the check-in is still
  /// recorded, only the answer is lost (as with a real server).
  Duration uploadDelay = Duration.zero;

  void _net() {
    if (!online) throw const DoorHttpException(DoorErrorKind.network);
  }

  @override
  Future<DoorPackModel> pack(DoorSession s, DoorDeviceInfo device) async {
    _net();
    packDownloads++;
    return DoorPackModel.fromJson(packJson);
  }

  @override
  Future<DoorChangesModel> changes(DoorSession s, int since, DoorDeviceInfo device) async {
    _net();
    final newer = <DoorCheckIn>[];
    for (var i = since; i < checkIns.length; i++) {
      newer.add(checkIns[i]);
    }
    return DoorChangesModel(
      cursor: checkIns.length,
      hasMore: false,
      checkIns: newer,
      eventStatus: (packJson['event'] as Map)['status'] as String,
      rosterVersion: packJson['roster_version'] as String,
      serverTime: DateTime.now().toUtc(),
    );
  }

  @override
  Future<DoorUploadResponse> upload(
    DoorSession s,
    List<Map<String, dynamic>> items,
    DoorDeviceInfo device,
    DateTime sentAtUtc, {
    Duration? timeout,
  }) async {
    _net();
    final tooLate = timeout != null && uploadDelay > timeout;
    if (uploadDelay > Duration.zero) await Future<void>.delayed(tooLate ? timeout : uploadDelay);
    final response = _record(items, device);
    if (tooLate) throw const DoorHttpException(DoorErrorKind.network);
    return response;
  }

  DoorUploadResponse _record(List<Map<String, dynamic>> items, DoorDeviceInfo device) {
    uploads.add(items);
    final results = <DoorUploadResult>[];
    for (final item in items) {
      final uuid = '${item['uuid']}';
      final invitation = item['invitation_id'] as int;
      final known = checkIns.where((c) => c.uuid == uuid).toList();
      if (known.isNotEmpty) {
        results.add(DoorUploadResult(status: 'replayed', uuid: uuid, checkIn: known.first));
        continue;
      }
      // Already came in (any door): a return, nothing kept.
      final first = checkIns.where((c) => c.invitationId == invitation).toList();
      if (first.isNotEmpty) {
        returns.add(uuid);
        results.add(DoorUploadResult(status: 'returned', uuid: uuid, checkIn: first.first));
        continue;
      }
      final c = DoorCheckIn(
        uuid: uuid,
        invitationId: invitation,
        checkedInAt: DateTime.parse('${item['scanned_at']}'),
        companions: item['companions'] as int,
        gateId: item['gate_id'] as int?,
        deviceName: item['device_name'] as String? ?? device.name,
        source: item['source'] as String?,
      );
      checkIns.add(c);
      results.add(DoorUploadResult(status: 'recorded', uuid: uuid, checkIn: c));
    }
    return DoorUploadResponse(results, DateTime.now().toUtc());
  }

  @override
  Future<DoorPackGuest?> lookup(DoorSession s, String raw, {Duration? timeout}) async {
    _net();
    return null;
  }
}

class FakeKeepAlive implements HubKeepAlive {
  final List<String> calls = [];

  @override
  Future<void> start({required String title, required String text}) async => calls.add('start:$title');

  @override
  Future<void> stop() async => calls.add('stop');
}

/// One phone's own database (call sqfliteFfiInit in setUpAll first).
Future<SqliteDoorStore> memoryStore() async => SqliteDoorStore(
  await OfflineDatabase.open(factory: databaseFactoryFfi, path: inMemoryDatabasePath, singleInstance: false),
);

DoorSession testSession({
  DoorSessionKind kind = DoorSessionKind.client,
  String name = 'Men door',
  int? gateId,
  String? lanJoin,
}) => DoorSession(
  id: DoorSession.idFor(kind, testEventId),
  kind: kind,
  eventId: testEventId,
  eventTitle: 'عرس',
  deviceName: name,
  gateId: gateId,
  lanJoin: lanJoin,
);

Future<void> waitUntil(bool Function() ok, {Duration timeout = const Duration(seconds: 10)}) async {
  final end = DateTime.now().add(timeout);
  while (!ok()) {
    if (DateTime.now().isAfter(end)) fail('Timed out waiting');
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

/// The hub's join code, pointed at this machine (a test has no Wi-Fi).
Future<LanJoinInfo> localJoin(DoorEngine hub) async {
  final join = LanJoinInfo.decode((await hub.startHubJoinCode())!)!;
  return LanJoinInfo(
    hosts: ['127.0.0.1:${hub.hubPort}'],
    eventId: join.eventId,
    eventTitle: join.eventTitle,
    hubName: join.hubName,
    secret: join.secret,
  );
}

/// A staff phone with no account and no internet, joined to the hub.
Future<DoorEngine> joinedDoor(LanJoinInfo join, String name) async {
  final door = DoorEngine(store: await memoryStore(), remote: null, syncEvery: null);
  await door.open(testSession(kind: DoorSessionKind.lan, name: name, lanJoin: join.toStorage()));
  await waitUntil(() => door.status.hasPack && door.status.link == DoorLink.hub);
  return door;
}
