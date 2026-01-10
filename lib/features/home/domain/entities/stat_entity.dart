import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class StatEntity extends Equatable {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final Color bgColor;

  const StatEntity({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.bgColor,
  });

  @override
  List<Object?> get props => [label, value, icon, gradientColors, bgColor];
}
