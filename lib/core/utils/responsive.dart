import 'dart:math';

import 'package:flutter/material.dart';

/// Responsive sizing utility based on a design size.
///
/// Initialize once at app startup via [Responsive.init] inside a
/// [Builder] or [LayoutBuilder] so the screen metrics are available.
///
/// Usage:
/// ```dart
/// // Width‑relative (padding, margin, icon size, border radius)
/// SizedBox(width: 16.w)
///
/// // Height‑relative (vertical spacing)
/// SizedBox(height: 12.h)
///
/// // Scale‑safe font size
/// TextStyle(fontSize: 14.sp)
///
/// // Radius (uses width scale)
/// BorderRadius.circular(8.r)
/// ```
class Responsive {
  Responsive._();

  static const double _designWidth = 375.0;
  static const double _designHeight = 812.0;

  static double _screenWidth = _designWidth;
  static double _screenHeight = _designHeight;

  /// Call this once in your [MaterialApp.builder] or the top of your
  /// widget tree so every `.w`, `.h`, `.sp`, `.r` extension works.
  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  static double get scaleWidth => _screenWidth / _designWidth;
  static double get scaleHeight => _screenHeight / _designHeight;
  static double get scaleText => min(scaleWidth, scaleHeight);

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
}

/// Responsive extensions on [num].
extension ResponsiveNum on num {
  /// Width‑relative pixels.
  double get w => toDouble() * Responsive.scaleWidth;

  /// Height‑relative pixels.
  double get h => toDouble() * Responsive.scaleHeight;

  /// Scale‑safe font size (capped by the smaller axis).
  double get sp => toDouble() * Responsive.scaleText;

  /// Radius (same as width scale).
  double get r => toDouble() * Responsive.scaleWidth;
}
