import 'package:flutter/material.dart';

import '../../utils/app_font_weight.dart';
import '../../utils/app_strings.dart';
import '../../utils/media_query_values.dart';

/// A responsive elevated button widget with consistent styling.
class AppElevatedButton extends StatelessWidget {
  final VoidCallback? onPress;
  final String title;
  final Color? titleColor;
  final Color backgroundColor;
  final Color? borderColor;

  const AppElevatedButton({
    super.key,
    required this.onPress,
    required this.title,
    required this.titleColor,
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
          context.dynamicHeight(0.07),
        ),
        foregroundColor: titleColor,
        backgroundColor: backgroundColor,
        textStyle: TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: context.dynamicWidth(0.045),
          fontWeight: AppFontWeight.bold,
        ),
        side: BorderSide(color: borderColor ?? Colors.transparent),
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.015),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.025)),
        ),
      ),
      onPressed: onPress,
      child: Text(title),
    );
  }
}

/// Legacy function for backward compatibility
Widget elevatedButton({
  required VoidCallback? onPress,
  required String title,
  required Color? titleColor,
  required Color backgroundColor,
  Color? borderColor,
}) {
  return Builder(
    builder: (context) => AppElevatedButton(
      onPress: onPress,
      title: title,
      titleColor: titleColor,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    ),
  );
}
