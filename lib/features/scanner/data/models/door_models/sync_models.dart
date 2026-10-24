part of '../door_models.dart';

/// `GET .../door/pack` (also what the venue hub serves to its phones).
class DoorPackModel {
  final int format;
  final DoorEventInfo event;
  final List<DoorGate> gates;
  final String salt;
  final String sign;
  final DateTime? serverTime;
  final int cursor;
  final String? rosterVersion;
  final List<DoorPackGuest> guests;

  const DoorPackModel({
    required this.format,
    required this.event,
    required this.gates,
    required this.salt,
    required this.sign,
    required this.serverTime,
    required this.cursor,
    required this.rosterVersion,
    required this.guests,
  });

  factory DoorPackModel.fromJson(Map<String, dynamic> j) {
    final keys = _map(j['keys']);
    return DoorPackModel(
      format: _int(j['format'], 1),
      event: DoorJson.event(_map(j['event'])),
      gates: _list(j['gates']).map(DoorJson.gate).toList(),
      salt: '${keys['salt'] ?? ''}',
      sign: '${keys['sign'] ?? ''}',
      serverTime: _date(j['server_time']),
      cursor: _int(j['cursor']),
      rosterVersion: _str(j['roster_version']),
      guests: _list(j['invitations']).map(DoorPackGuest.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'format': format,
    'event': DoorJson.eventToJson(event),
    'gates': gates.map(DoorJson.gateToJson).toList(),
    'keys': {'salt': salt, 'sign': sign},
    'server_time': serverTime?.toIso8601String(),
    'cursor': cursor,
    'roster_version': rosterVersion,
    'invitations': guests.map((g) => g.toJson()).toList(),
  };
}

/// `GET .../door/changes`.
class DoorChangesModel {
  final int cursor;
  final bool hasMore;
  final List<DoorCheckIn> checkIns;
  final String? eventStatus;
  final String? rosterVersion;
  final DateTime? serverTime;

  const DoorChangesModel({
    required this.cursor,
    required this.hasMore,
    required this.checkIns,
    this.eventStatus,
    this.rosterVersion,
    this.serverTime,
  });

  factory DoorChangesModel.fromJson(Map<String, dynamic> j) => DoorChangesModel(
    cursor: _int(j['cursor']),
    hasMore: j['has_more'] == true,
    checkIns: (j['check_ins'] is List)
        ? (j['check_ins'] as List).map(DoorJson.checkIn).whereType<DoorCheckIn>().toList()
        : const [],
    eventStatus: _str(j['event_status']),
    rosterVersion: _str(j['roster_version']),
    serverTime: _date(j['server_time']),
  );
}

/// One item of `POST .../door/check-ins`.
class DoorUploadResult {
  /// recorded | replayed | returned (already came in: let back in, nothing
  /// kept) | refused
  final String status;
  final String uuid;
  final String? code;
  final String? message;
  final String? flag;
  final int? maxCompanions;
  final DoorCheckIn? checkIn;

  const DoorUploadResult({
    required this.status,
    required this.uuid,
    this.code,
    this.message,
    this.flag,
    this.maxCompanions,
    this.checkIn,
  });

  bool get accepted => status == 'recorded' || status == 'replayed';

  bool get returned => status == 'returned';

  factory DoorUploadResult.fromJson(Map<String, dynamic> j) => DoorUploadResult(
    status: '${j['status'] ?? 'refused'}',
    uuid: '${j['uuid'] ?? ''}',
    code: _str(j['code']),
    message: _str(j['message']),
    flag: _str(j['flag']),
    maxCompanions: _intOrNull(j['max_companions']),
    checkIn: DoorJson.checkIn(j['check_in']),
  );
}
