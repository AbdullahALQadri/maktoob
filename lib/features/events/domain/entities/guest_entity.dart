import 'package:equatable/equatable.dart';

enum GuestStatus { attending, pending, declined }

class GuestEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final GuestStatus status;
  final int companions;
  final bool isCheckedIn;

  const GuestEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.companions = 0,
    this.isCheckedIn = false,
  });

  bool get isValid => name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        status,
        companions,
        isCheckedIn,
      ];
}
