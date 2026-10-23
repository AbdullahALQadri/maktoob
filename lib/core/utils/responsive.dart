import 'dart:math' as math;

import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  /// Current screen size
  Size get size => MediaQuery.maybeOf(this)?.size ?? const Size(0, 0);

  /// Screen height
  double get height => size.height;

  /// Screen width
  double get width => size.width;

  /// Dynamic height based on screen, capped at the tallest phone (932) so
  /// tablets keep phone proportions instead of inflating spacing.
  double dynamicHeight(double value) => math.min(height, 932) * value;

  /// Dynamic width based on screen, capped at the widest phone (430): font
  /// and icon sizes derived from it would otherwise double on tablets.
  double dynamicWidth(double value) => math.min(width, 430) * value;
}
