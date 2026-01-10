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

  factory StatModel.fromJson(Map<String, dynamic> json) {
    return StatModel(
      label: json['label'] as String,
      value: json['value'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
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
      'gradientColors': gradientColors.map((c) => c.value).toList(),
      'bgColor': bgColor.value,
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
