import '../../domain/entities/door_entities.dart';
import '../models/door_models.dart';
import 'door_check_in_record.dart';

export 'door_check_in_record.dart';
export 'sqlite_door_store.dart';

/// What the phone remembers about an event's pack.
class DoorPackMeta {
  final int eventId;
  final DoorEventInfo event;
  final List<DoorGate> gates;
  final List<int> salt;
  final List<int> sign;
  final String saltEncoded;
  final String signEncoded;
  final int cursor;
  final String? rosterVersion;
  final DateTime downloadedAt;
  final DateTime? lastSyncAt;
  final int clockOffsetMs;

  const DoorPackMeta({
    required this.eventId,
    required this.event,
    required this.gates,
    required this.salt,
    required this.sign,
    required this.saltEncoded,
    required this.signEncoded,
    required this.cursor,
    required this.rosterVersion,
    required this.downloadedAt,
    required this.lastSyncAt,
    required this.clockOffsetMs,
  });
}

/// Everything the door keeps on the phone (SQLite: sqlite_door_store.dart).
abstract class DoorStore {
  Future<String> deviceUuid();

  /// Small settings (the active staff session, the hub secret).
  Future<String?> value(String key);
  Future<void> setValue(String key, String? value);

  Future<void> saveSession(DoorSession session);
  Future<DoorSession?> session(String id);
  Future<List<DoorSession>> sessions();
  Future<void> deleteSession(String id);

  /// Replaces the event's guests and keys; keeps every check-in.
  Future<void> savePack(DoorPackModel pack, {required DateTime downloadedAt, required int clockOffsetMs});
  Future<DoorPackMeta?> packMeta(int eventId);
  Future<void> updatePackMeta(
    int eventId, {
    int? cursor,
    String? eventStatus,
    int? clockOffsetMs,
    DateTime? lastSyncAt,
  });

  /// Adds one guest (a lookup result for a guest added after the download).
  Future<void> upsertGuest(int eventId, DoorPackGuest guest);
  Future<DoorGuest?> guestByHash(int eventId, String hash);
  Future<DoorGuest?> guest(int eventId, int invitationId);
  Future<List<DoorGuest>> guests(int eventId, {String query = '', int limit = 500});

  /// False when the uuid is already known (a re-received record).
  Future<bool> addCheckIn(DoorCheckInRecord record);

  /// Check-ins from the server / the hub: insert unknown, update the state of known.
  Future<int> mergeCheckIns(int eventId, List<DoorCheckIn> checkIns, {required String origin, bool synced = true});
  Future<void> mergeLanRecords(int eventId, List<DoorCheckInRecord> records);
  Future<DoorCheckIn?> firstCheckIn(int eventId, int invitationId);
  Future<List<DoorCheckInRecord>> pendingUploads(int eventId, {int limit = 200});
  Future<void> markUpload(String uuid, String state, {String? code});
  Future<void> bumpAttempts(List<String> uuids);
  Future<List<DoorCheckInRecord>> lanRecordsSince(int eventId, int seq, {int limit = 500});
  Future<int> maxLanSeq(int eventId);

  Future<int> guestCount(int eventId);
  Future<int> checkedInCount(int eventId);
  Future<int> pendingCount(int eventId);
  Future<int> refusedCount(int eventId);

  /// The pack as the server shapes it, with every check-in this phone knows
  /// (what the venue hub serves to phones that join it).
  Future<Map<String, dynamic>> exportPack(int eventId);

  /// Events whose packs hold check-ins not uploaded yet.
  Future<List<int>> eventsWithPending();

  /// Drop packs of events that ended [retention] ago, never with pending check-ins.
  Future<int> purge(DateTime nowUtc, {Duration retention = const Duration(days: 3)});
}
