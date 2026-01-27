import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    primaryColor: AppColors.primaryColor,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      iconTheme: IconThemeData(color: AppColors.black), // leading icon
      actionsIconTheme: IconThemeData(color: AppColors.black), // action icons
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.tertiaryColor,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.tertiaryColor,
      onTertiary: AppColors.white,
      onSurface: AppColors.black,
      onError: AppColors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
      ),
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    iconTheme: IconThemeData(color: AppColors.black),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: AppColors.primaryColor,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.white,
      iconTheme: IconThemeData(color: AppColors.white),
      actionsIconTheme: IconThemeData(color: AppColors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.tertiaryColor,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.tertiaryColor,
      onTertiary: AppColors.white,
      onSurface: AppColors.white,
      onError: AppColors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
      ),
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    iconTheme: IconThemeData(color: AppColors.white),
  );
}
