import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_strings.dart';

/// Unified text styles for the entire application.
///
/// This class provides consistent typography across all screens.
/// All text styles use the Satoshi font family and follow a clear hierarchy.
///
/// Example usage:
/// ```dart
/// Text('Hello', style: AppTextStyles.headlineLarge)
/// Text('Subtitle', style: AppTextStyles.bodyMedium)
/// Text('Caption', style: AppTextStyles.caption(context))
/// ```
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = AppStrings.fontFamily;

  // ==========================================================================
  // HEADLINES - For major headings and titles
  // ==========================================================================

  /// Extra large headline - 32px bold
  static const TextStyle headlineXLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
    height: 1.2,
  );

  /// Large headline - 28px bold
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
    height: 1.2,
  );

  /// Medium headline - 24px bold
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
    height: 1.3,
  );

  /// Small headline - 20px semibold
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.gray900,
    height: 1.3,
  );

  // ==========================================================================
  // TITLES - For section titles and card headers
  // ==========================================================================

  /// Large title - 18px semibold
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.gray900,
    height: 1.4,
  );

  /// Medium title - 16px semibold
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.gray900,
    height: 1.4,
  );

  /// Small title - 14px semibold
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.gray900,
    height: 1.4,
  );

  // ==========================================================================
  // BODY - For main content text
  // ==========================================================================

  /// Large body text - 16px regular
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
    height: 1.5,
  );

  /// Medium body text - 14px regular
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
    height: 1.5,
  );

  /// Small body text - 12px regular
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray600,
    height: 1.5,
  );

  // ==========================================================================
  // LABELS - For form labels, buttons, and navigation
  // ==========================================================================

  /// Large label - 16px medium
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.gray800,
    height: 1.4,
  );

  /// Medium label - 14px medium
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.gray700,
    height: 1.4,
  );

  /// Small label - 12px medium
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.gray600,
    height: 1.4,
  );

  // ==========================================================================
  // CAPTIONS & HELPERS
  // ==========================================================================

  /// Caption text - 12px regular
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
    height: 1.4,
  );

  /// Overline text - 10px medium uppercase
  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.gray500,
    letterSpacing: 1.5,
    height: 1.4,
  );

  /// Helper/hint text - 12px regular
  static const TextStyle helper = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray400,
    height: 1.4,
  );

  /// Error text - 12px regular
  static const TextStyle error = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.red500,
    height: 1.4,
  );

  // ==========================================================================
  // BUTTONS
  // ==========================================================================

  /// Primary button text - 16px semibold
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  /// Medium button text - 14px semibold
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  /// Small button text - 12px semibold
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  // ==========================================================================
  // LINKS
  // ==========================================================================

  /// Link text - 14px medium with underline
  static const TextStyle link = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
    height: 1.4,
  );

  /// Small link text - 12px medium
  static const TextStyle linkSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
    height: 1.4,
  );

  // ==========================================================================
  // SPECIAL STYLES
  // ==========================================================================

  /// Price/amount text - 24px bold
  static const TextStyle price = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
    height: 1.2,
  );

  /// Badge text - 10px semibold
  static const TextStyle badge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  /// Input text - 16px regular
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.gray900,
    height: 1.4,
  );

  /// Hint text for inputs - 16px regular
  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.gray400,
    height: 1.4,
  );
}

/// Extension to create variants of text styles easily
extension TextStyleExtension on TextStyle {
  /// Creates a copy with primary color
  TextStyle get primary => copyWith(color: AppColors.primaryColor);

  /// Creates a copy with secondary color
  TextStyle get secondary => copyWith(color: AppColors.gray500);

  /// Creates a copy with tertiary color
  TextStyle get tertiary => copyWith(color: AppColors.tertiaryColor);

  /// Creates a copy with error color
  TextStyle get errorColor => copyWith(color: AppColors.red500);

  /// Creates a copy with success color
  TextStyle get success => copyWith(color: AppColors.green600);

  /// Creates a copy with warning color
  TextStyle get warning => copyWith(color: AppColors.amber600);

  /// Creates a copy with white color
  TextStyle get white => copyWith(color: AppColors.white);

  /// Creates a copy with black color
  TextStyle get black => copyWith(color: AppColors.gray900);

  /// Creates a bold variant
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Creates a semibold variant
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Creates a medium variant
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Creates a regular variant
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// Creates an underlined variant
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);

  /// Creates a centered variant (for use with RichText)
  TextStyle withHeight(double height) => copyWith(height: height);

  /// Creates a variant with custom letter spacing
  TextStyle withSpacing(double spacing) => copyWith(letterSpacing: spacing);
}
