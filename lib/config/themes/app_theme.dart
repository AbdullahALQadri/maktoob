import 'package:flutter/material.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_strings.dart';

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,

    fontFamily: AppStrings.fontFamily,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 22.0,
        fontFamily: AppStrings.fontFamily,
      ),
      iconTheme: IconThemeData(color: AppColors.black),
      // toolbarHeight: 90,
    ),
  );
}

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
      // secondary: AppColors.logoColor,
      // background: AppColors.ofWhite,
      // surface: AppColors.container,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      // onBackground: AppColors.black,
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
      // secondary: AppColors.logoColor,
      // background: Colors.black,
      // surface: AppColors.grey,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      // onBackground: AppColors.white,
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
