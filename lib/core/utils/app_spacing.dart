import 'package:flutter/material.dart';

/// Unified spacing and dimension constants for the entire application.
///
/// This class provides consistent spacing values across all screens
/// following an 8-point grid system with additional half-steps.
///
/// Example usage:
/// ```dart
/// SizedBox(height: AppSpacing.md)
/// Padding(padding: AppSpacing.paddingAll16)
/// EdgeInsets.symmetric(horizontal: AppSpacing.lg)
/// ```
class AppSpacing {
  AppSpacing._();

  // ==========================================================================
  // BASE SPACING VALUES (8-point grid system)
  // ==========================================================================

  /// 0px - No spacing
  static const double zero = 0;

  /// 2px - Extra extra small
  static const double xxs = 2;

  /// 4px - Extra small
  static const double xs = 4;

  /// 8px - Small
  static const double sm = 8;

  /// 12px - Small-medium
  static const double smd = 12;

  /// 16px - Medium
  static const double md = 16;

  /// 20px - Medium-large
  static const double mdl = 20;

  /// 24px - Large
  static const double lg = 24;

  /// 32px - Extra large
  static const double xl = 32;

  /// 40px - Extra extra large
  static const double xxl = 40;

  /// 48px - Triple extra large
  static const double xxxl = 48;

  /// 56px - Quad extra large
  static const double xxxxl = 56;

  /// 64px - Quint extra large
  static const double xxxxxl = 64;

  // ==========================================================================
  // RADIUS VALUES
  // ==========================================================================

  /// 4px - Extra small radius
  static const double radiusXs = 4;

  /// 8px - Small radius
  static const double radiusSm = 8;

  /// 12px - Medium radius
  static const double radiusMd = 12;

  /// 16px - Large radius
  static const double radiusLg = 16;

  /// 20px - Extra large radius
  static const double radiusXl = 20;

  /// 24px - Extra extra large radius
  static const double radiusXxl = 24;

  /// 32px - Round radius
  static const double radiusRound = 32;

  /// Full circle radius
  static const double radiusFull = 9999;

  // ==========================================================================
  // BORDER RADIUS
  // ==========================================================================

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusRound = BorderRadius.all(Radius.circular(radiusRound));

  // ==========================================================================
  // COMMON EDGE INSETS - ALL SIDES
  // ==========================================================================

  static const EdgeInsets paddingAll16 = EdgeInsets.all(md);

  // ==========================================================================
  // COMMON EDGE INSETS - HORIZONTAL
  // ==========================================================================

  // ==========================================================================
  // COMMON EDGE INSETS - VERTICAL
  // ==========================================================================

  // ==========================================================================
  // SIZED BOXES - VERTICAL (for column spacing)
  // ==========================================================================

  static const SizedBox verticalSpace4 = SizedBox(height: xs);
  static const SizedBox verticalSpace8 = SizedBox(height: sm);
  static const SizedBox verticalSpace12 = SizedBox(height: smd);
  static const SizedBox verticalSpace16 = SizedBox(height: md);
  static const SizedBox verticalSpace24 = SizedBox(height: lg);
  static const SizedBox verticalSpace32 = SizedBox(height: xl);

  // ==========================================================================
  // SIZED BOXES - HORIZONTAL (for row spacing)
  // ==========================================================================

  static const SizedBox horizontalSpace4 = SizedBox(width: xs);
  static const SizedBox horizontalSpace8 = SizedBox(width: sm);
  static const SizedBox horizontalSpace12 = SizedBox(width: smd);

  // ==========================================================================
  // ICON SIZES
  // ==========================================================================

  /// 16px - Small icon
  static const double iconSm = 16;

  /// 20px - Medium-small icon
  static const double iconMd = 20;

  /// 24px - Medium icon (default)
  static const double iconLg = 24;

  /// 28px - Medium-large icon
  static const double iconXl = 28;

  // ==========================================================================
  // BUTTON HEIGHTS
  // ==========================================================================

  // ==========================================================================
  // INPUT HEIGHTS
  // ==========================================================================

  // ==========================================================================
  // AVATAR SIZES
  // ==========================================================================

  // ==========================================================================
  // CARD DIMENSIONS
  // ==========================================================================

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  // ==========================================================================
  // SCREEN PADDING
  // ==========================================================================

  /// Default screen horizontal padding - 16px
  static const double screenPaddingHorizontal = md;

  /// Default screen vertical padding - 16px
  static const double screenPaddingVertical = md;

  // ==========================================================================
  // DIVIDER
  // ==========================================================================

  // ==========================================================================
  // ELEVATION
  // ==========================================================================

}

/// Extension on [num] for quick spacing conversions
extension SpacingExtension on num {

  /// Creates EdgeInsets with this value on all sides
  EdgeInsets get paddingAll => EdgeInsets.all(toDouble());

  /// Creates BorderRadius with this value
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());
}
