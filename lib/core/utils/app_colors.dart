import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Main Brand Colors
  static const Color primaryColor = Color(0xFF3AA4DB);
  static const Color secondaryColor = Color(0xFFFFFFFF);
  static const Color tertiaryColor = Color(0xFF032855);

  static const Color primary = primaryColor;

  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color red = Colors.red;
  static const Color icons = Color(0xFF3E3E41);
  static const Color subText = Color(0xFF5B6D70);

  // Purple
  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color purple100 = Color(0xFFF3E8FF);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);

  // Pink
  static const Color pink500 = Color(0xFFEC4899);
  static const Color pink600 = Color(0xFFDB2777);

  // Rose
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);

  // Gray
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Green
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green600 = Color(0xFF16A34A);

  // Yellow
  static const Color yellow400 = Color(0xFFFACC15);

  // Amber
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  // Blue
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);

  // Cyan
  static const Color cyan50 = Color(0xFFECFEFF);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);

  // Emerald
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  // Indigo
  static const Color indigo500 = Color(0xFF6366F1);

  // Orange
  static const Color orange500 = Color(0xFFF97316);

  // Red shades
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red500 = Color(0xFFEF4444);
}

/// Theme-aware color getters for dark/light mode support.
///
/// Usage: `context.textPrimary`, `context.cardBg`, `context.inputFill`, etc.
extension AppThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Backgrounds
  Color get scaffoldBg => Theme.of(this).scaffoldBackgroundColor;
  Color get cardBg =>
      isDarkMode ? const Color(0xFF1E1E1E) : AppColors.white;
  Color get surfaceColor =>
      isDarkMode ? AppColors.gray800 : AppColors.gray50;
  Color get inputFill =>
      isDarkMode ? AppColors.gray800 : AppColors.gray100;

  // Text
  Color get textPrimary =>
      isDarkMode ? AppColors.white : AppColors.gray900;
  Color get textSecondary =>
      isDarkMode ? AppColors.gray400 : AppColors.gray600;
  Color get textTertiary =>
      isDarkMode ? AppColors.gray500 : AppColors.gray700;
  Color get hintColor =>
      isDarkMode ? AppColors.gray500 : AppColors.gray400;

  // Borders & Dividers
  Color get borderColor =>
      isDarkMode ? AppColors.gray700 : AppColors.gray200;
  Color get dividerColor =>
      isDarkMode ? AppColors.gray700 : AppColors.gray200;

  // Icons
  Color get iconDefault =>
      isDarkMode ? AppColors.gray300 : AppColors.gray400;
  Color get iconSecondary =>
      isDarkMode ? AppColors.gray400 : AppColors.gray500;

  // Misc
  Color get chipBg =>
      isDarkMode ? AppColors.gray800 : AppColors.gray100;
  Color get overlayBg =>
      isDarkMode ? AppColors.gray800 : AppColors.gray100;
}
