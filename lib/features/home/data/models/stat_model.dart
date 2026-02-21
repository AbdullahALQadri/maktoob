import 'package:flutter/material.dart';

import '../../domain/entities/stat_entity.dart';

class StatModel extends StatEntity {
  const StatModel({
    required super.label,
    required super.value,
    required super.icon,
    required super.gradientColors,
    required super.bgColor,
  });

  static const _knownIcons = [
    Icons.calendar_today,
    Icons.people,
    Icons.check_circle,
    Icons.cancel,
    Icons.event,
  ];

  static IconData _resolveIcon(int codePoint) {
    for (final icon in _knownIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
    return Icons.event;
  }

  factory StatModel.fromJson(Map<String, dynamic> json) {
    return StatModel(
      label: json['label'] as String,
      value: json['value'] as String,
      icon: _resolveIcon(json['icon'] as int),
      gradientColors: (json['gradientColors'] as List<dynamic>)
          .map((c) => Color(c as int))
          .toList(),
      bgColor: Color(json['bgColor'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'icon': icon.codePoint,
      'gradientColors': gradientColors.map((c) => c.toARGB32()).toList(),
      'bgColor': bgColor.toARGB32(),
    };
  }

  factory StatModel.fromEntity(StatEntity entity) {
    return StatModel(
      label: entity.label,
      value: entity.value,
      icon: entity.icon,
      gradientColors: entity.gradientColors,
      bgColor: entity.bgColor,
    );
  }
}
