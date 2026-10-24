import '../../domain/entities/door_entities.dart';

/// A check-in as this phone keeps it, with its upload state.
///
/// origin: `local` (decided here), `peer` (received from the venue hub or a
/// phone joined to it), `server` (came down from the server).
/// sync_state: `pending` (to upload), `synced`, `duplicate` (the server kept
/// it as a double admission), `refused` (the server could not take it).
class DoorCheckInRecord extends DoorCheckIn {
  final int eventId;
  final String? deviceUuid;
  final String origin;
  final String syncState;
  final String? syncCode;
  final String? notes;
  final int attempts;
  final int lanSeq;

  const DoorCheckInRecord({
    required super.uuid,
    required this.eventId,
    required super.invitationId,
    required super.checkedInAt,
    super.companions,
    super.gateId,
    super.deviceName,
    super.source,
    this.deviceUuid,
    required this.origin,
    required this.syncState,
    this.syncCode,
    this.notes,
    this.attempts = 0,
    this.lanSeq = 0,
  });

  DoorCheckInRecord copyWith({String? syncState, String? origin, String? source}) => DoorCheckInRecord(
    uuid: uuid,
    eventId: eventId,
    invitationId: invitationId,
    checkedInAt: checkedInAt,
    companions: companions,
    gateId: gateId,
    deviceName: deviceName,
    source: source ?? this.source,
    deviceUuid: deviceUuid,
    origin: origin ?? this.origin,
    syncState: syncState ?? this.syncState,
    syncCode: syncCode,
    notes: notes,
    attempts: attempts,
    lanSeq: lanSeq,
  );

  /// One item of the upload API (the server's `check-ins` contract).
  Map<String, dynamic> toUploadJson({String? sourceOverride}) => {
    'uuid': uuid,
    'invitation_id': invitationId,
    'companions': companions,
    'scanned_at': checkedInAt.toUtc().toIso8601String(),
    'source': sourceOverride ?? source ?? 'offline',
    'gate_id': gateId,
    if (deviceUuid != null) 'device_uuid': deviceUuid,
    if (deviceName != null) 'device_name': deviceName,
    if (notes != null) 'notes': notes,
  };

  /// What phones on the venue hub exchange.
  Map<String, dynamic> toLanJson() => {...toUploadJson(), 'synced': syncState != 'pending', 'seq': lanSeq};

  static DoorCheckInRecord fromLanJson(int eventId, Map<String, dynamic> j, {required String origin}) =>
      DoorCheckInRecord(
        uuid: '${j['uuid']}',
        eventId: eventId,
        invitationId: (j['invitation_id'] as num).toInt(),
        checkedInAt: DateTime.parse('${j['scanned_at']}').toUtc(),
        companions: (j['companions'] as num?)?.toInt() ?? 0,
        gateId: (j['gate_id'] as num?)?.toInt(),
        deviceName: j['device_name']?.toString(),
        deviceUuid: j['device_uuid']?.toString(),
        source: j['source']?.toString(),
        notes: j['notes']?.toString(),
        origin: origin,
        syncState: j['synced'] == true ? 'synced' : 'pending',
        lanSeq: (j['seq'] as num?)?.toInt() ?? 0,
      );
}
