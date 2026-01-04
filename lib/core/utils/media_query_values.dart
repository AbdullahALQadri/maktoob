// import 'package:flutter/material.dart';
//
// extension MediaQueryValues on BuildContext {
//   Size get size => MediaQuery.of(this).size;
//   double get height => size.height;
//   double get width => size.width;
//   double get topPadding => MediaQuery.of(this).viewPadding.top;
//   double get bottomPadding => MediaQuery.of(this).viewPadding.bottom;
//   EdgeInsets get safePadding => MediaQuery.of(this).viewPadding;
//
//   bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
//
//   // Screen breakpoints
//   bool get isSmallScreen => width < 600;
//   bool get isMediumScreen => width >= 600 && width < 1024;
//   bool get isLargeScreen => width >= 1024;
//
//   /// Show a simple snackbar
//   void showSnackBar(String message) {
//     ScaffoldMessenger.of(this).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }
// }

import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  Size get size => MediaQuery.maybeOf(this)?.size ?? const Size(0, 0);
  double get height => size.height;
  double get width => size.width;

  double get topPadding => MediaQuery.maybeOf(this)?.viewPadding.top ?? 0;
  double get bottomPadding => MediaQuery.maybeOf(this)?.viewPadding.bottom ?? 0;
  EdgeInsets get safePadding => MediaQuery.maybeOf(this)?.viewPadding ?? EdgeInsets.zero;

  double dynamicHeight(double value) => height * value;
  double dynamicWidth(double value) => width * value;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  bool get isPortrait => MediaQuery.maybeOf(this)?.orientation == Orientation.portrait;
  bool get isLandscape => !isPortrait;

  bool get isSmallScreen => width < 600;
  bool get isMediumScreen => width >= 600 && width < 1024;
  bool get isLargeScreen => width >= 1024;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

