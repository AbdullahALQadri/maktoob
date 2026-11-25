import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

/// Event type model from API
class EventTypeModel extends Equatable {
  final int? id; // null for custom type
  final String name;
  final String nameAr;
  final String? iconUrl;
  final String? emoji;
  final List<Color>? gradientColors;

  /// Occasion group this type belongs to (null for client-made custom types).
  final int? groupId;

  /// Backend `is_custom` flag (a client-created type that has a real id).
  final bool isClientCustom;

  /// Backend slug (wedding, graduation, opening…); drives the title suggestion.
  final String? slug;

  /// Business-style types (workshops, conferences): an end time, and they may
  /// last several days.
  final bool hasEndTime;

  const EventTypeModel({
    this.id,
    required this.name,
    required this.nameAr,
    this.iconUrl,
    this.emoji,
    this.gradientColors,
    this.groupId,
    this.isClientCustom = false,
    this.slug,
    this.hasEndTime = false,
  });

  bool get isCustom => id == null;

  /// Check if this event type is a marriage/engagement type
  bool get isMarriageOrEngagement {
    final nameLower = name.toLowerCase();
    return nameLower.contains('wedding') ||
        nameLower.contains('marriage') ||
        nameLower.contains('engagement') ||
        nameAr.contains('زفاف') ||
        nameAr.contains('خطوبة');
  }

  factory EventTypeModel.fromJson(Map<String, dynamic> json) {
    // API returns name_en/name_ar, fallback to name for compatibility
    final nameEn = json['name_en'] as String? ?? json['name'] as String? ?? '';
    final nameAr = json['name_ar'] as String? ?? nameEn;
    return EventTypeModel(
      id: json['id'] as int?,
      name: nameEn.isNotEmpty ? nameEn : nameAr,
      nameAr: nameAr.isNotEmpty ? nameAr : nameEn,
      iconUrl: json['icon_url'] as String?,
      emoji: json['emoji'] as String?,
      groupId: _int(json['group_id']),
      isClientCustom: _bool(json['is_custom']),
      slug: _string(json['slug']),
      hasEndTime: _bool(json['has_end_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_ar': nameAr,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (emoji != null) 'emoji': emoji,
    };
  }

  /// Create custom event type
  factory EventTypeModel.custom(String name) {
    return EventTypeModel(
      id: null,
      name: name,
      nameAr: name,
      emoji: '➕',
      gradientColors: const [AppColors.purple600, AppColors.pink600],
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    nameAr,
    iconUrl,
    emoji,
    gradientColors,
    groupId,
    isClientCustom,
    slug,
    hasEndTime,
  ];
}

int? _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

bool _bool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

String? _string(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}
