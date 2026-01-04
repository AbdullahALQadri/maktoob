import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/widgets/text_utils.dart';

Widget appDescription() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40),
    child: textUtils(
      text:
      "Your trusted app — made for the MENA community, built around your needs.",
      color: AppColors.subText,
      fontWeight: AppFontWeight.medium,
      fontSize: 15,
      textAlign: TextAlign.center,
    ),
  );
}
