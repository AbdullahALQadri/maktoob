import '../../domain/entities/check_in_guest_entity.dart';

class CheckInGuestModel extends CheckInGuestEntity {
  const CheckInGuestModel({
    required super.id,
    required super.name,
    required super.status,
    required super.companions,
    required super.checkedIn,
    required super.qrCode,
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

  @override
  CheckInGuestModel copyWith({
    String? id,
    String? name,
    String? status,
    int? companions,
    bool? checkedIn,
    String? qrCode,
  }) {
    return CheckInGuestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      companions: companions ?? this.companions,
      checkedIn: checkedIn ?? this.checkedIn,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
