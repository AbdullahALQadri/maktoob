import '../../domain/entities/check_in_guest_entity.dart';

class CheckInGuestModel extends CheckInGuestEntity {
  const CheckInGuestModel({
    required super.id,
    required super.name,
    required super.status,
    required super.companions,
    required super.checkedIn,
    required super.qrCode,
    super.canCheckIn,
    super.blockerMessage,
    super.maxCompanions,
    super.declinedRsvp,
    super.warning,
    super.checkedInAt,
  });

  factory CheckInGuestModel.fromJson(Map<String, dynamic> json) {
    return CheckInGuestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      companions: json['companions'] as int,
      checkedIn: json['checked_in'] as bool,
      qrCode: json['qr_code'] as String,
    );
  }

  /// Maps the backend `data.invitation` object returned by
  /// POST /scanner/check-in/scan into a guest row.
  factory CheckInGuestModel.fromInvitationJson(
    Map<String, dynamic> json, {
    String qrCode = '',
  }) {
    return CheckInGuestModel(
      id: '${json['id'] ?? ''}',
      name: (json['guest_name'] ?? json['guest_name_en'] ?? '') as String,
      status: (json['response_status'] ?? 'no_response') as String,
      companions: _toInt(json['expected_companions']),
      checkedIn: (json['already_checked_in'] as bool?) ?? false,
      qrCode: qrCode,
      // Absent on older backends: allow, as before.
      canCheckIn: json['can_check_in'] is bool ? json['can_check_in'] as bool : true,
      blockerMessage: _str(json['blocker_message']),
      maxCompanions: json['max_companions'] == null ? null : _toInt(json['max_companions']),
      declinedRsvp: json['declined_rsvp'] == true,
      warning: _str(json['warning']),
      checkedInAt: json['last_check_in'] is Map
          ? DateTime.tryParse('${json['last_check_in']['checked_in_at'] ?? ''}')
          : null,
    );
  }

  /// Maps an item from the backend `data.attendance` list returned by
  /// GET /scanner/attendance/{venue} (these are already checked in).
  factory CheckInGuestModel.fromAttendanceJson(Map<String, dynamic> json) {
    return CheckInGuestModel(
      id: '${json['invitation_id'] ?? ''}',
      name: (json['guest_name'] ?? '') as String,
      status: 'checked_in',
      companions: _toInt(json['actual_companions']),
      checkedIn: true,
      qrCode: '',
    );
  }

  /// Maps an item from `data.guests` returned by
  /// GET /events/{event}/guests/check-in-list (every invitee).
  factory CheckInGuestModel.fromRosterJson(Map<String, dynamic> json) {
    final checkedIn = json['is_checked_in'] == true;
    return CheckInGuestModel(
      id: '${json['invitation_id'] ?? ''}',
      name: '${json['guest_name'] ?? ''}',
      status: checkedIn ? 'checked_in' : '${json['response_status'] ?? 'no_response'}',
      companions: _toInt(json['companions']),
      checkedIn: checkedIn,
      qrCode: '',
      checkedInAt: DateTime.tryParse('${json['checked_in_at'] ?? ''}'),
    );
  }

  static String? _str(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'companions': companions,
      'checked_in': checkedIn,
      'qr_code': qrCode,
    };
  }

  factory CheckInGuestModel.fromEntity(CheckInGuestEntity entity) {
    return CheckInGuestModel(
      id: entity.id,
      name: entity.name,
      status: entity.status,
      companions: entity.companions,
      checkedIn: entity.checkedIn,
      qrCode: entity.qrCode,
    );
  }

  /// Maps a successful `POST .../check-in` response.
  factory CheckInGuestModel.fromCheckInResponse(
    dynamic response, {
    required String invitationId,
    int? requestedCompanions,
  }) {
    final body = response is Map ? response : const {};
    final data = body['data'] ?? body;
    final log = data is Map ? data['attendance_log'] : null;
    // The owner endpoint returns `invitation` instead of `attendance_log`.
    final inv = body['invitation'];
    return CheckInGuestModel(
      id: invitationId,
      name: (log is Map ? log['guest_name'] as String? : null) ??
          (inv is Map ? inv['display_name'] as String? : null) ??
          '',
      status: 'checked_in',
      companions: log is Map && log['actual_companions'] != null
          ? _toInt(log['actual_companions'])
          : (requestedCompanions ?? 0),
      checkedIn: true,
      qrCode: '',
      declinedRsvp: body['declined_rsvp'] == true,
      warning: _str(body['warning']),
      checkedInAt: log is Map ? DateTime.tryParse('${log['checked_in_at'] ?? ''}') : null,
    );
  }
}
