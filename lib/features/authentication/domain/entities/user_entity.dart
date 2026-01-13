import 'package:equatable/equatable.dart';

/// Base user entity for authentication
class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? companyName;
  final bool isVerified;
  final String? locale;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.companyName,
    this.isVerified = false,
    this.locale,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatar,
        companyName,
        isVerified,
        locale,
      ];
}
