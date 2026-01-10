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
