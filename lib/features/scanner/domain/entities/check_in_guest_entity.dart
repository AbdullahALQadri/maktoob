import 'package:equatable/equatable.dart';

class CheckInGuestEntity extends Equatable {
  final String id;
  final String name;
  final String status;
  final int companions;
  final bool checkedIn;
  final String qrCode;

  const CheckInGuestEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.companions,
    required this.checkedIn,
    required this.qrCode,
  });

  bool get isVip => status == 'VIP';

  CheckInGuestEntity copyWith({
    String? id,
    String? name,
    String? status,
    int? companions,
    bool? checkedIn,
    String? qrCode,
  }) {
    return CheckInGuestEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      companions: companions ?? this.companions,
      checkedIn: checkedIn ?? this.checkedIn,
      qrCode: qrCode ?? this.qrCode,
    );
  }

  @override
  List<Object?> get props => [id, name, status, companions, checkedIn, qrCode];
}
