import 'package:flutter/material.dart';

import '../../../core/utils/app_strings.dart';
import '../../utils/app_font_weight.dart';

Widget elevatedButton({
  required VoidCallback? onPress,
  required String title,
  required Color? titleColor,
  required Color backgroundColor,
  Color? borderColor,
}) {
  return ElevatedButton(

    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: Size(double.infinity, 56),
      foregroundColor: titleColor,
      backgroundColor: backgroundColor,
      textStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 18,
        fontWeight: AppFontWeight.bold,
      ),
      side: BorderSide(color: borderColor ?? Colors.transparent),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    onPressed: onPress,
    child: Text(title),
  );
}
