import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/widgets/elevated_buttons/elevated_button.dart';
import '../../../../core/widgets/sized_box_widget.dart';
import '../../../../core/widgets/text_utils.dart';

Widget onBordingWidget({
  required String backgroundImage,
  required String title,
  required String subTitle,
  void Function()? LangOnTap,
  required bool isVisible,
  required void Function()? createOnPress,
  required void Function()? loginOnPress,
}) {
  return Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          backgroundImage,
          fit: BoxFit.cover,
          // Enable caching for better performance
          cacheWidth: 1080, // Reasonable cache width for most devices
          cacheHeight: 1920,
          filterQuality: FilterQuality.medium,
        ),
      ),

      Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16, top: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 30,
              height: 60,
              fit: BoxFit.contain,
              // Use lower filter quality for small images
              filterQuality: FilterQuality.low,
            ),
            InkWell(
              onTap: LangOnTap,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8 , vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    textUtils(
                      text: 'عربي',
                      color: AppColors.black,
                      fontWeight: AppFontWeight.medium,
                      fontSize: 15,
                    ),
                    const SizedBox(width: 10),
                    Image.asset('assets/images/arFlag.png'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      Align(
        alignment: Alignment.bottomCenter,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryColor.withOpacity(0.05),
                    AppColors.primaryColor.withOpacity(0.25),
                    AppColors.primaryColor.withOpacity(0.5),
                    AppColors.primaryColor.withOpacity(0.7),
                    AppColors.primaryColor.withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textUtils(
                    text: title,
                    fontSize: 40,
                    fontWeight: AppFontWeight.bold,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 10),
                  textUtils(
                    text: subTitle,
                    fontSize: 16,
                    fontWeight: AppFontWeight.medium,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 20),

                  elevatedButton(
                    title: isVisible ? "Create an Account" : "Next",
                    titleColor: AppColors.white,
                    backgroundColor: AppColors.secondaryColor,
                    onPress: createOnPress,
                  ),

                  if (isVisible) ...[
                    sizedBoxWidget(height: 10),
                    elevatedButton(
                      title: "Login to Your Account",
                      titleColor: AppColors.primaryColor,
                      backgroundColor: AppColors.white,
                      onPress: loginOnPress,
                    ),
                  ],

                  sizedBoxWidget(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Image.asset(
                      "assets/images/copy.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
