import '../../domain/entities/door_entities.dart';

part 'door_models/management_models.dart';
part 'door_models/report_models.dart';
part 'door_models/sync_models.dart';

/// JSON for the offline door API (`maktoob-backend/app/Services/Door`).
/// Hand-written and tolerant, like every model in the app.
///
/// The parts: sync_models.dart (pack, changes, upload results),
/// report_models.dart (the host's summary, devices),
/// management_models.dart (door codes, pairing).

int _int(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

int? _intOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

String? _str(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString())?.toUtc();

Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> _list(dynamic v) =>
    v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];

class DoorJson {
  DoorJson._();

  static DoorEventInfo event(Map<String, dynamic> j) => DoorEventInfo(
    id: _int(j['id']),
    title: '${j['title'] ?? ''}',
    status: '${j['status'] ?? 'draft'}',
    eventDate: _date(j['event_date']),
    validFrom: _date(j['valid_from']),
    validUntil: _date(j['valid_until']),
    validOn: _str(j['valid_on']),
    allowCompanions: j['allow_companions'] != false,
    companionLimit: _intOrNull(j['companion_limit']),
    venueName: _str(j['venue_name']),
  );

  static Map<String, dynamic> eventToJson(DoorEventInfo e) => {
    'id': e.id,
    'title': e.title,
    'status': e.status,
    'event_date': e.eventDate?.toIso8601String(),
    'valid_from': e.validFrom?.toIso8601String(),
    'valid_until': e.validUntil?.toIso8601String(),
    'valid_on': e.validOn,
    'allow_companions': e.allowCompanions,
    'companion_limit': e.companionLimit,
    'venue_name': e.venueName,
  };

  static DoorGate gate(Map<String, dynamic> j) => DoorGate(
    id: _int(j['id']),
    name: '${j['name'] ?? ''}',
    audience: _str(j['audience']) ?? 'all',
    isActive: j['is_active'] != false,
  );

  static Map<String, dynamic> gateToJson(DoorGate g) => {
    'id': g.id,
    'name': g.name,
    'audience': g.audience,
    'is_active': g.isActive,
  };

  static DoorCheckIn? checkIn(dynamic raw) {
    if (raw is! Map) return null;
    final j = Map<String, dynamic>.from(raw);
    final at = _date(j['checked_in_at']);
    final invitationId = _intOrNull(j['invitation_id']);
    if (at == null || invitationId == null) return null;
    return DoorCheckIn(
      // Check-ins made before the offline door have no device uuid.
      uuid: _str(j['uuid']) ?? 'srv-${_int(j['id'])}',
      invitationId: invitationId,
      checkedInAt: at,
      companions: _int(j['companions']),
      gateId: _intOrNull(j['gate_id']),
      deviceName: _str(j['device_name']),
      source: _str(j['source']),
    );
  }

  static Map<String, dynamic> checkInToJson(DoorCheckIn c) => {
    'uuid': c.uuid,
    'invitation_id': c.invitationId,
    'checked_in_at': c.checkedInAt.toUtc().toIso8601String(),
    'companions': c.companions,
    'gate_id': c.gateId,
    'device_name': c.deviceName,
    'source': c.source,
  };
}

/// A pack entry: the guest and the hashes that find them.
class DoorPackGuest {
  final DoorGuest guest;
  final List<String> hashes;

  const DoorPackGuest(this.guest, this.hashes);

  factory DoorPackGuest.fromJson(Map<String, dynamic> j) => DoorPackGuest(
    DoorGuest(
      id: _int(j['id']),
      name: '${j['name'] ?? ''}',
      nameEn: _str(j['name_en']),
      gender: _str(j['gender']),
      phoneTail: _str(j['phone_tail']),
      companions: _int(j['companions']),
      maxCompanions: _intOrNull(j['max_companions']),
      rsvp: _str(j['rsvp']) ?? 'no_response',
      checkIn: DoorJson.checkIn(j['check_in']),
    ),
    (j['hashes'] is List) ? (j['hashes'] as List).map((h) => '$h').toList() : const [],
  );

  Map<String, dynamic> toJson() => {
    'id': guest.id,
    'hashes': hashes,
    'name': guest.name,
    'name_en': guest.nameEn,
    'gender': guest.gender,
    'phone_tail': guest.phoneTail,
    'companions': guest.companions,
    'max_companions': guest.maxCompanions,
    'rsvp': guest.rsvp,
    'check_in': guest.checkIn == null ? null : DoorJson.checkInToJson(guest.checkIn!),
  };
}
