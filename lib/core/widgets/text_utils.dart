import 'package:flutter/material.dart';

import '../../core/utils/app_strings.dart';



Widget textUtils({
  required String text,
  required Color color,
  required FontWeight fontWeight,
  required double fontSize,
  TextDecoration? underLine,
  TextOverflow? overFlow,
  double? height,
  TextAlign? textAlign,
  double? letterSpacing,

}) {
  return Text(
    text,
    textAlign: textAlign,
    style: TextStyle(
      fontFamily: AppStrings.fontFamily,
      decoration: underLine,
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      overflow: overFlow,
      height: height ?? 0,
      letterSpacing: letterSpacing ?? 0.5,
    ),
  );
}
