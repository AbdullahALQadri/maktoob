import 'package:flutter/material.dart';

import '../../utils/app_font_weight.dart';
import '../../utils/app_strings.dart';
import '../../utils/media_query_values.dart';

/// A responsive elevated button widget that accepts a child widget.
class AppElevatedButtonForWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color? borderColor;

  const AppElevatedButtonForWidget({
    super.key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(
          double.infinity,
          context.dynamicHeight(0.06),
        ),
        backgroundColor: backgroundColor,
        textStyle: TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: context.dynamicWidth(0.03),
          fontWeight: AppFontWeight.bold,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.012),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          side: BorderSide(
            color: borderColor ?? Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

/// Legacy function for backward compatibility
Widget elevatedButtonForWidget({
  required void Function()? onPressed,
  required Widget child,
  required Color backgroundColor,
  Color? borderColor,
}) {
  return Builder(
    builder: (context) => AppElevatedButtonForWidget(
      onPressed: onPressed,
      child: child,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    ),
  );
}
