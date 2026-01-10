import 'package:flutter/material.dart';
import 'responsive.dart';
import 'app_colors.dart';

/// Responsive text styles for the app
class AppTextStyles {
  AppTextStyles._();

  /// Get responsive heading 1 style
  static TextStyle h1(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(32),
      fontWeight: FontWeight.bold,
      color: AppColors.gray900,
      height: 1.2,
    );
  }

  /// Get responsive heading 2 style
  static TextStyle h2(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(28),
      fontWeight: FontWeight.bold,
      color: AppColors.gray900,
      height: 1.25,
    );
  }

  /// Get responsive heading 3 style
  static TextStyle h3(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(24),
      fontWeight: FontWeight.w600,
      color: AppColors.gray900,
      height: 1.3,
    );
  }

  /// Get responsive heading 4 style
  static TextStyle h4(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(20),
      fontWeight: FontWeight.w600,
      color: AppColors.gray900,
      height: 1.35,
    );
  }

  /// Get responsive heading 5 style
  static TextStyle h5(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(18),
      fontWeight: FontWeight.w600,
      color: AppColors.gray900,
      height: 1.4,
    );
  }

  /// Get responsive heading 6 style
  static TextStyle h6(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(16),
      fontWeight: FontWeight.w600,
      color: AppColors.gray900,
      height: 1.4,
    );
  }

  /// Get responsive body large style
  static TextStyle bodyLarge(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(16),
      fontWeight: FontWeight.normal,
      color: AppColors.gray700,
      height: 1.5,
    );
  }

  /// Get responsive body medium style
  static TextStyle bodyMedium(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(14),
      fontWeight: FontWeight.normal,
      color: AppColors.gray700,
      height: 1.5,
    );
  }

  /// Get responsive body small style
  static TextStyle bodySmall(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(12),
      fontWeight: FontWeight.normal,
      color: AppColors.gray600,
      height: 1.5,
    );
  }

  /// Get responsive label large style
  static TextStyle labelLarge(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(14),
      fontWeight: FontWeight.w500,
      color: AppColors.gray900,
      height: 1.4,
    );
  }

  /// Get responsive label medium style
  static TextStyle labelMedium(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(12),
      fontWeight: FontWeight.w500,
      color: AppColors.gray700,
      height: 1.4,
    );
  }

  /// Get responsive label small style
  static TextStyle labelSmall(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(10),
      fontWeight: FontWeight.w500,
      color: AppColors.gray600,
      height: 1.4,
    );
  }

  /// Get responsive button text style
  static TextStyle button(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(16),
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.2,
    );
  }

  /// Get responsive caption style
  static TextStyle caption(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(11),
      fontWeight: FontWeight.normal,
      color: AppColors.gray500,
      height: 1.4,
    );
  }

  /// Get responsive overline style
  static TextStyle overline(BuildContext context) {
    final responsive = Responsive(context);
    return TextStyle(
      fontSize: responsive.sp(10),
      fontWeight: FontWeight.w500,
      color: AppColors.gray500,
      letterSpacing: 1.5,
      height: 1.4,
    );
  }
}
