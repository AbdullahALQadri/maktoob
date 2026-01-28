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

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius borderRadiusRound = BorderRadius.all(Radius.circular(radiusRound));

  // ==========================================================================
  // COMMON EDGE INSETS - ALL SIDES
  // ==========================================================================

  static const EdgeInsets paddingAll0 = EdgeInsets.zero;
  static const EdgeInsets paddingAll4 = EdgeInsets.all(xs);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(sm);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(smd);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(md);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(mdl);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(lg);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(xl);

  // ==========================================================================
  // COMMON EDGE INSETS - HORIZONTAL
  // ==========================================================================

  static const EdgeInsets paddingHorizontal4 = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontal8 = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontal12 = EdgeInsets.symmetric(horizontal: smd);
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontal20 = EdgeInsets.symmetric(horizontal: mdl);
  static const EdgeInsets paddingHorizontal24 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontal32 = EdgeInsets.symmetric(horizontal: xl);

  // ==========================================================================
  // COMMON EDGE INSETS - VERTICAL
  // ==========================================================================

  static const EdgeInsets paddingVertical4 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVertical12 = EdgeInsets.symmetric(vertical: smd);
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVertical20 = EdgeInsets.symmetric(vertical: mdl);
  static const EdgeInsets paddingVertical24 = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVertical32 = EdgeInsets.symmetric(vertical: xl);

  // ==========================================================================
  // SIZED BOXES - VERTICAL (for column spacing)
  // ==========================================================================

  static const SizedBox verticalSpace2 = SizedBox(height: xxs);
  static const SizedBox verticalSpace4 = SizedBox(height: xs);
  static const SizedBox verticalSpace8 = SizedBox(height: sm);
  static const SizedBox verticalSpace12 = SizedBox(height: smd);
  static const SizedBox verticalSpace16 = SizedBox(height: md);
  static const SizedBox verticalSpace20 = SizedBox(height: mdl);
  static const SizedBox verticalSpace24 = SizedBox(height: lg);
  static const SizedBox verticalSpace32 = SizedBox(height: xl);
  static const SizedBox verticalSpace40 = SizedBox(height: xxl);
  static const SizedBox verticalSpace48 = SizedBox(height: xxxl);

  // ==========================================================================
  // SIZED BOXES - HORIZONTAL (for row spacing)
  // ==========================================================================

  static const SizedBox horizontalSpace2 = SizedBox(width: xxs);
  static const SizedBox horizontalSpace4 = SizedBox(width: xs);
  static const SizedBox horizontalSpace8 = SizedBox(width: sm);
  static const SizedBox horizontalSpace12 = SizedBox(width: smd);
  static const SizedBox horizontalSpace16 = SizedBox(width: md);
  static const SizedBox horizontalSpace20 = SizedBox(width: mdl);
  static const SizedBox horizontalSpace24 = SizedBox(width: lg);
  static const SizedBox horizontalSpace32 = SizedBox(width: xl);

  // ==========================================================================
  // ICON SIZES
  // ==========================================================================

  /// 12px - Extra small icon
  static const double iconXs = 12;

  /// 16px - Small icon
  static const double iconSm = 16;

  /// 20px - Medium-small icon
  static const double iconMd = 20;

  /// 24px - Medium icon (default)
  static const double iconLg = 24;

  /// 28px - Medium-large icon
  static const double iconXl = 28;

  /// 32px - Large icon
  static const double iconXxl = 32;

  /// 40px - Extra large icon
  static const double iconXxxl = 40;

  /// 48px - Hero icon
  static const double iconHero = 48;

  // ==========================================================================
  // BUTTON HEIGHTS
  // ==========================================================================

  /// 32px - Small button
  static const double buttonHeightSm = 32;

  /// 40px - Medium button
  static const double buttonHeightMd = 40;

  /// 48px - Large button
  static const double buttonHeightLg = 48;

  /// 56px - Extra large button (default)
  static const double buttonHeightXl = 56;

  // ==========================================================================
  // INPUT HEIGHTS
  // ==========================================================================

  /// 40px - Small input
  static const double inputHeightSm = 40;

  /// 48px - Medium input
  static const double inputHeightMd = 48;

  /// 56px - Large input (default)
  static const double inputHeightLg = 56;

  // ==========================================================================
  // AVATAR SIZES
  // ==========================================================================

  /// 24px - Extra small avatar
  static const double avatarXs = 24;

  /// 32px - Small avatar
  static const double avatarSm = 32;

  /// 40px - Medium avatar
  static const double avatarMd = 40;

  /// 48px - Large avatar
  static const double avatarLg = 48;

  /// 56px - Extra large avatar
  static const double avatarXl = 56;

  /// 64px - Extra extra large avatar
  static const double avatarXxl = 64;

  /// 80px - Hero avatar
  static const double avatarHero = 80;

  /// 120px - Profile avatar
  static const double avatarProfile = 120;

  // ==========================================================================
  // CARD DIMENSIONS
  // ==========================================================================

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Card margin
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: md, vertical: sm);

  /// Card border radius
  static const BorderRadius cardBorderRadius = borderRadiusMd;

  // ==========================================================================
  // SCREEN PADDING
  // ==========================================================================

  /// Default screen horizontal padding - 16px
  static const double screenPaddingHorizontal = md;

  /// Default screen vertical padding - 16px
  static const double screenPaddingVertical = md;

  /// Screen edge insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  /// Screen horizontal edge insets only
  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
  );

  // ==========================================================================
  // DIVIDER
  // ==========================================================================

  /// Divider thickness
  static const double dividerThickness = 1;

  /// Divider indent
  static const double dividerIndent = md;

  // ==========================================================================
  // ELEVATION
  // ==========================================================================

  /// No elevation
  static const double elevation0 = 0;

  /// Small elevation
  static const double elevationSm = 2;

  /// Medium elevation
  static const double elevationMd = 4;

  /// Large elevation
  static const double elevationLg = 8;

  /// Extra large elevation
  static const double elevationXl = 16;
}

/// Extension on [num] for quick spacing conversions
extension SpacingExtension on num {
  /// Creates a vertical SizedBox with this value as height
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Creates a horizontal SizedBox with this value as width
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// Creates EdgeInsets with this value on all sides
  EdgeInsets get paddingAll => EdgeInsets.all(toDouble());

  /// Creates horizontal EdgeInsets with this value
  EdgeInsets get paddingH => EdgeInsets.symmetric(horizontal: toDouble());

  /// Creates vertical EdgeInsets with this value
  EdgeInsets get paddingV => EdgeInsets.symmetric(vertical: toDouble());

  /// Creates BorderRadius with this value
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());
}
