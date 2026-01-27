import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  /// Current screen size
  Size get size => MediaQuery.maybeOf(this)?.size ?? const Size(0, 0);

  /// Screen height
  double get height => size.height;

  /// Screen width
  double get width => size.width;

  /// Dynamic height based on screen
  double dynamicHeight(double value) => height * value;

  /// Dynamic width based on screen
  double dynamicWidth(double value) => width * value;
}
