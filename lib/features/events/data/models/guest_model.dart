import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/guest_entity.dart';

class GuestModel extends GuestEntity {
  final Color avatarColor;

  const GuestModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.status,
    super.companions,
    super.isCheckedIn,
    required this.avatarColor,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) {
    // Handle both frontend format and backend API format (invitation with nested guest)
    final guestData = json['guest'] as Map<String, dynamic>? ?? json;
    final id = json['id'] ?? guestData['id'];

    return GuestModel(
      id: id is int ? id.toString() : (id as String? ?? ''),
      name: json['display_name'] as String? ?? guestData['name'] as String? ?? '',
      email: guestData['email'] as String? ?? '',
      phone: guestData['phone'] as String? ?? '',
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      companions: json['companions'] as int? ?? 0,
      isCheckedIn: json['is_checked_in'] as bool? ?? (json['open_count'] as int? ?? 0) > 0,
      avatarColor: Color(json['avatar_color'] as int? ?? AppColors.primaryColor.toARGB32()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': _statusToString(status),
      'companions': companions,
      'is_checked_in': isCheckedIn,
      'avatar_color': avatarColor.toARGB32(),
    };
  }

  factory GuestModel.fromEntity(GuestEntity entity, {required Color avatarColor}) {
    return GuestModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      status: entity.status,
      companions: entity.companions,
      isCheckedIn: entity.isCheckedIn,
      avatarColor: avatarColor,
    );
  }

  GuestEntity toEntity() {
    return GuestEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      status: status,
      companions: companions,
      isCheckedIn: isCheckedIn,
    );
  }

  static GuestStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'attending':
        return GuestStatus.attending;
      case 'declined':
        return GuestStatus.declined;
      case 'pending':
      default:
        return GuestStatus.pending;
    }
  }

  static String _statusToString(GuestStatus status) {
    switch (status) {
      case GuestStatus.attending:
        return 'attending';
      case GuestStatus.declined:
        return 'declined';
      case GuestStatus.pending:
        return 'pending';
    }
  }

  GuestModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    GuestStatus? status,
    int? companions,
    bool? isCheckedIn,
    Color? avatarColor,
  }) {
    return GuestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      companions: companions ?? this.companions,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      avatarColor: avatarColor ?? this.avatarColor,
    );
  }
}
