
import 'package:flutter/material.dart';

import 'app_strings.dart';


TextStyle globalTextStyle({
  Color? color,
  required double fontSize,
  double? letterSpacing,
  double? lineHeight,
  FontWeight? fontWeight,
}) =>
    TextStyle(
      color: color ?? Colors.black,
      fontSize: fontSize,
      letterSpacing: letterSpacing ?? 0.5,
      fontWeight: fontWeight ?? FontWeight.normal,
      height: lineHeight ?? 0,
      fontFamily: AppStrings.fontFamily,
    );
