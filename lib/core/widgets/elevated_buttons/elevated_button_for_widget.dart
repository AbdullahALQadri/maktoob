import 'package:flutter/material.dart';

import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/app_strings.dart';

Widget elevatedButtonForWidget({
  // required Function() onPressed,
  required void Function()? onPressed,
  required Widget child,
  required Color backgroundColor,
  Color? borderColor,


}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: Size(
        double.infinity,
        50,
        // 50.h,
      ),
      backgroundColor: backgroundColor,
      // backgroundColor: AppColors.primaryColor,
      textStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        // fontSize: 12.sp,
        fontWeight: AppFontWeight.bold,
      ),
      // primary: MyColors.kPrimaryColor,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
