import '../../../core/utils/storage/secure_storage_service.dart';
import '../domain/entities/door_entities.dart';
import 'datasources/door_remote_data_source.dart';
import 'datasources/door_store.dart';
import 'lan/lan_protocol.dart';

/// Signs a phone in as a door, with or without a Maktoob account:
///  - the host / an institution member: their client account (no extra step);
///  - staff with a door code from the host (paired phone, own token);
///  - a scanner account assigned to the venue;
///  - a phone that only joins the venue hub (no internet at all).
///
/// Door tokens are kept under SecureStorageKeys.doorPrefix, which a host
/// logout or a 401 never clears.
class DoorSessionManager {
  static const String _activeStaffKey = 'active_staff_session';

  final DoorStore store;
  final DoorRemoteDataSource remote;
  final SecureStorageService secure;

  DoorSessionManager({required this.store, required this.remote, required this.secure});

  static String tokenKey(String sessionId) => 'token_$sessionId';

  /// The token a door call sends for [session] (for DoorHttp).
  static Future<String?> tokenFor(SecureStorageService secure, DoorSession session) => switch (session.kind) {
    DoorSessionKind.client => secure.getToken(),
    DoorSessionKind.paired || DoorSessionKind.scanner => secure.readDoorSecret(tokenKey(session.id)),
    DoorSessionKind.lan => Future.value(null),
  };

  /// The host's own door session for one of their events.
  Future<DoorSession> clientSession({required int eventId, required String eventTitle, String? deviceName}) async {
    final id = DoorSession.idFor(DoorSessionKind.client, eventId);
    final existing = await store.session(id);
    return existing?.copyWith(eventTitle: eventTitle) ??
        DoorSession(
          id: id,
          kind: DoorSessionKind.client,
          eventId: eventId,
          eventTitle: eventTitle,
          deviceName: deviceName ?? await defaultDeviceName(),
        );
  }

  /// Gets the host's active events ready for the door while there is a
  /// connection: their packs download in the next sync pass, so the door
  /// works at a venue with no internet even if the scanner was never opened.
  Future<void> prepareClientEvents(Iterable<(int, String)> events) async {
    for (final (eventId, title) in events) {
      if (eventId <= 0) continue;
      final id = DoorSession.idFor(DoorSessionKind.client, eventId);
      if (await store.session(id) != null) continue;
      await store.saveSession(await clientSession(eventId: eventId, eventTitle: title));
    }
  }

  Future<String> defaultDeviceName() async {
    final saved = await store.value('device_name');
    if (saved != null && saved.isNotEmpty) return saved;
    final uuid = await store.deviceUuid();
    return 'Door ${uuid.substring(0, 4).toUpperCase()}';
  }

  Future<void> rememberDeviceName(String name) => store.setValue('device_name', name.trim());

  Future<DoorSession> pairWithCode(String code, String deviceName) async {
    final pairing = await remote.pair(code: code, deviceUuid: await store.deviceUuid(), deviceName: deviceName);
    final session = DoorSession(
      id: DoorSession.idFor(DoorSessionKind.paired, pairing.event.id),
      kind: DoorSessionKind.paired,
      eventId: pairing.event.id,
      eventTitle: pairing.event.title,
      deviceName: pairing.deviceName.isEmpty ? deviceName : pairing.deviceName,
      gateId: pairing.gateId,
    );
    await secure.writeDoorSecret(tokenKey(session.id), pairing.token);
    await store.saveSession(session);
    await rememberDeviceName(deviceName);
    await store.setValue(_activeStaffKey, session.id);
    return session;
  }

  Future<(String token, List<DoorEventInfo> events)> scannerLogin(String email, String password) async {
    final token = await remote.scannerLogin(email, password);
    return (token, await remote.scannerEvents(token));
  }

  Future<DoorSession> scannerSession(String token, DoorEventInfo event, String deviceName) async {
    final session = DoorSession(
      id: DoorSession.idFor(DoorSessionKind.scanner, event.id),
      kind: DoorSessionKind.scanner,
      eventId: event.id,
      eventTitle: event.title,
      deviceName: deviceName,
    );
    await secure.writeDoorSecret(tokenKey(session.id), token);
    await store.saveSession(session);
    await rememberDeviceName(deviceName);
    await store.setValue(_activeStaffKey, session.id);
    return session;
  }

  /// Joins the venue hub only: no account and no internet needed.
  Future<DoorSession> joinHub(LanJoinInfo join, String deviceName) async {
    final session = DoorSession(
      id: DoorSession.idFor(DoorSessionKind.lan, join.eventId),
      kind: DoorSessionKind.lan,
      eventId: join.eventId,
      eventTitle: join.eventTitle,
      deviceName: deviceName,
      lanJoin: join.toStorage(),
    );
    await store.saveSession(session);
    await rememberDeviceName(deviceName);
    await store.setValue(_activeStaffKey, session.id);
    return session;
  }

  /// The staff session to reopen on launch (door-only mode).
  Future<DoorSession?> activeStaffSession() async {
    final id = await store.value(_activeStaffKey);
    return id == null ? null : store.session(id);
  }

  /// Leaves door-only mode. Check-ins not uploaded yet keep their session
  /// and token: the background task still uploads them.
  Future<void> leaveStaffMode(DoorSession session) async {
    await store.setValue(_activeStaffKey, null);
    if (await store.pendingCount(session.eventId) > 0) return;
    if (session.kind == DoorSessionKind.paired) {
      try {
        await remote.logoutPaired(session);
      } catch (_) {}
    }
    await secure.deleteDoorSecret(tokenKey(session.id));
    await store.deleteSession(session.id);
  }

  /// Check-ins on this phone not uploaded yet, across every event.
  Future<int> pendingEverywhere() async {
    var total = 0;
    for (final eventId in await store.eventsWithPending()) {
      total += await store.pendingCount(eventId);
    }
    return total;
  }
}
