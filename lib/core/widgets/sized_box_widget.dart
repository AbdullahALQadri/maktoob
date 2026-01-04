import 'package:flutter/material.dart';

Widget sizedBoxWidget({
  required double height,
  double width = 0,
}) {
  return SizedBox(
    height: height,
    // height: height.h,
    width: width,
    // width: width.w,
  );
}
