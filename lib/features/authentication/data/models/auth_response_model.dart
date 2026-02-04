import 'package:equatable/equatable.dart';

/// Base response model for API authentication responses
class AuthResponseModel extends Equatable {
  final bool success;
  final String message;
  final String? token;
  final dynamic data;

  const AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ?? json['data']?['token'];
    // Infer success when the API doesn't return a 'success' field:
    // - has a token (login/verify), OR
    // - has a client/user object (register/update)
    final inferredSuccess = token != null ||
        json.containsKey('client') ||
        json.containsKey('user');
    return AuthResponseModel(
      success: json['success'] ?? inferredSuccess,
      message: json['message'] ?? '',
      token: token,
      data: json['data'] ?? json,
    );
  }

  @override
  List<Object?> get props => [success, message, token, data];
}

/// Client user model
class ClientModel extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String phone;
  final String? avatar;
  final String? companyName;
  final bool isVerified;
  final String? locale;

  const ClientModel({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.avatar,
    this.companyName,
    this.isVerified = false,
    this.locale,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      companyName: json['company_name'],
      isVerified: json['is_verified'] ?? false,
      locale: json['locale'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'company_name': companyName,
      'is_verified': isVerified,
      'locale': locale,
    };
  }

  @override
  List<Object?> get props => [id, name, email, phone, avatar, companyName, isVerified, locale];
}

/// Guest user model (OTP-based authentication)
class GuestUserModel extends Equatable {
  final int id;
  final String? name;
  final String phone;
  final String? email;
  final String? gender;
  final String? locale;

  const GuestUserModel({
    required this.id,
    this.name,
    required this.phone,
    this.email,
    this.gender,
    this.locale,
  });

  factory GuestUserModel.fromJson(Map<String, dynamic> json) {
    return GuestUserModel(
      id: json['id'] ?? 0,
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'],
      gender: json['gender'],
      locale: json['locale'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'locale': locale,
    };
  }

  @override
  List<Object?> get props => [id, name, phone, email, gender, locale];
}

/// Scanner user model
class ScannerUserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final int activeAssignmentsCount;

  const ScannerUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.activeAssignmentsCount = 0,
  });

  factory ScannerUserModel.fromJson(Map<String, dynamic> json) {
    return ScannerUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      activeAssignmentsCount: json['active_assignments_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'active_assignments_count': activeAssignmentsCount,
    };
  }

  @override
  List<Object?> get props => [id, name, email, phone, avatar, activeAssignmentsCount];
}

/// Admin user model
class AdminUserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final List<String> roles;
  final List<String> permissions;
  final bool isSuperAdmin;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.roles = const [],
    this.permissions = const [],
    this.isSuperAdmin = false,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      roles: (json['roles'] as List?)?.cast<String>() ?? [],
      permissions: (json['permissions'] as List?)?.cast<String>() ?? [],
      isSuperAdmin: json['is_super_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'roles': roles,
      'permissions': permissions,
      'is_super_admin': isSuperAdmin,
    };
  }

  @override
  List<Object?> get props => [id, name, email, phone, avatar, roles, permissions, isSuperAdmin];
}
