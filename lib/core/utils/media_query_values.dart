import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  Size get size => MediaQuery.of(this).size;
  double get height => size.height;
  double get width => size.width;

  double get topPadding => MediaQuery.of(this).viewPadding.top;
  double get bottomPadding => MediaQuery.of(this).viewPadding.bottom;
  EdgeInsets get safePadding => MediaQuery.of(this).viewPadding;

  double dynamicHeight(double value) => height * value;
  double dynamicWidth(double value) => width * value;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => !isPortrait;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
