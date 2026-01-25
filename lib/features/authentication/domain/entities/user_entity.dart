import 'package:equatable/equatable.dart';

/// User type enum for distinguishing between normal users and organizations
enum UserType {
  normal,
  organization;

  String get displayName {
    switch (this) {
      case UserType.normal:
        return 'Normal User';
      case UserType.organization:
        return 'Organization';
    }
  }

  String get displayNameAr {
    switch (this) {
      case UserType.normal:
        return 'مستخدم عادي';
      case UserType.organization:
        return 'منظمة';
    }
  }

  String get apiValue {
    switch (this) {
      case UserType.normal:
        return 'normal';
      case UserType.organization:
        return 'organization';
    }
  }

  static UserType fromString(String? value) {
    if (value == 'organization') return UserType.organization;
    return UserType.normal;
  }
}

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
  final UserType userType;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.companyName,
    this.isVerified = false,
    this.locale,
    this.userType = UserType.normal,
  });

  /// Check if user is an organization based on companyName or userType
  bool get isOrganization => userType == UserType.organization || companyName != null;

  /// Get initials from name
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Copy with method for updating fields
  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? companyName,
    bool? isVerified,
    String? locale,
    UserType? userType,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      companyName: companyName ?? this.companyName,
      isVerified: isVerified ?? this.isVerified,
      locale: locale ?? this.locale,
      userType: userType ?? this.userType,
    );
  }

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
        userType,
      ];
}
