import 'package:flutter/material.dart';

/// Maktoob design tokens — sky blue + navy identity.
///
/// Sky blue `#3AA4DB` is the action colour, navy `#032855` the depth colour
/// (headers, gradients, strong ink). Neutrals are a cool slate ramp with a
/// hint of navy, and dark mode is a navy night instead of flat grey.
/// See DESIGN.md at the project root for the full system.
class AppColors {
  AppColors._();

  // ===========================================================================
  // BRAND
  // ===========================================================================

  /// Sky blue — primary action colour (CTAs, focus, selection, progress).
  static const Color primaryColor = Color(0xFF3AA4DB);

  /// White — used as on-primary surface (text/icons on primary).
  static const Color secondaryColor = Color(0xFFFFFFFF);

  /// Navy — depth colour (gradient ends, headers, strong brand ink).
  static const Color tertiaryColor = Color(0xFF032855);

  static const Color primary = primaryColor;

  /// Deep sky — sky blue as text on light surfaces (5.2:1 on white) and the
  /// pressed state of primary buttons.
  static const Color primaryDark = Color(0xFF1A73A8);

  /// Light sky — sky blue as text/icons on dark surfaces.
  static const Color primaryLight = Color(0xFF7DC4EA);

  /// Cool cloud scaffold background.
  static const Color surfaceBg = Color(0xFFF5F8FC);

  // Sky washes (selected chips, primary containers, info banners)
  static const Color sky50 = Color(0xFFEAF5FC);
  static const Color sky100 = Color(0xFFD4ECF8);
  static const Color sky200 = Color(0xFFA9D8F0);

  // Navy washes
  static const Color navy50 = Color(0xFFE6ECF4);
  static const Color navy700 = Color(0xFF0A3A73);

  // ===========================================================================
  // NEUTRALS
  // ===========================================================================

  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color red = Colors.red;

  /// Slate ink — used for primary icons.
  static const Color icons = Color(0xFF0F1B2B);

  /// Slate — used for secondary/sub text.
  static const Color subText = Color(0xFF4E5F75);

  // ===========================================================================
  // SLATE SCALE (named `gray*` for backward compatibility)
  // ===========================================================================

  static const Color gray50 = Color(0xFFF7F9FC);
  static const Color gray100 = Color(0xFFEEF2F7);
  static const Color gray200 = Color(0xFFDFE6EE);
  static const Color gray300 = Color(0xFFC5D0DC);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF6B7C93);
  static const Color gray600 = Color(0xFF4E5F75);
  static const Color gray700 = Color(0xFF364558);
  static const Color gray800 = Color(0xFF1E2B3C);
  static const Color gray900 = Color(0xFF0F1B2B);

  // ===========================================================================
  // NAVY NIGHT (dark mode surfaces)
  // ===========================================================================

  /// Dark scaffold — the deepest navy night.
  static const Color darkBg = Color(0xFF07111F);

  /// Dark cards, sheets, dialogs, bottom bar.
  static const Color darkSurface = Color(0xFF0D1B2E);

  /// Dark inputs, chips, raised containers.
  static const Color darkSurfaceHigh = Color(0xFF13243A);

  /// Dark 1px outlines and dividers.
  static const Color darkBorder = Color(0xFF1E3350);

  /// Dark stronger outline (unselected controls).
  static const Color darkBorderStrong = Color(0xFF2A4566);

  /// Dark primary text.
  static const Color darkText = Color(0xFFE6EDF5);

  /// Dark secondary text (6.7:1 on darkSurface).
  static const Color darkTextSecondary = Color(0xFF8FA3BC);

  /// Dark hints / disabled.
  static const Color darkTextMuted = Color(0xFF64799A);

  /// Dark error (soft red that reads on the navy night).
  static const Color darkError = Color(0xFFF87171);
  static const Color darkErrorContainer = Color(0xFF3B1418);
  static const Color darkOnErrorContainer = Color(0xFFFCA5A5);

  // ===========================================================================
  // EMERALD
  // ===========================================================================

  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  // ===========================================================================
  // AMBER (warnings)
  // ===========================================================================

  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  // ===========================================================================
  // GREEN (success states)
  // ===========================================================================

  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green600 = Color(0xFF16A34A);

  // ===========================================================================
  // RED (errors)
  // ===========================================================================

  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red500 = Color(0xFFDC2626);

  // ===========================================================================
  // ESCAPE-HATCH ACCENT FAMILIES
  // ===========================================================================
  // These remain for explicit non-brand uses (charts, illustrations,
  // ai_design feature pickers). Prefer brand tokens above for product UI.

  // Yellow
  static const Color yellow400 = Color(0xFFFACC15);

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

  // Blue
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);

  // Cyan
  static const Color cyan50 = Color(0xFFECFEFF);
  static const Color cyan500 = Color(0xFF06B6D4);
  static const Color cyan600 = Color(0xFF0891B2);

  // Indigo
  static const Color indigo500 = Color(0xFF6366F1);

  // Orange
  static const Color orange500 = Color(0xFFF97316);
}

/// Theme-aware color getters for dark/light mode support.
///
/// Usage: `context.textPrimary`, `context.cardBg`, `context.inputFill`, etc.
extension AppThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Backgrounds
  Color get scaffoldBg => Theme.of(this).scaffoldBackgroundColor;
  Color get cardBg => isDarkMode ? AppColors.darkSurface : AppColors.white;
  Color get themeSurface =>
      isDarkMode ? AppColors.darkSurfaceHigh : AppColors.gray50;
  Color get inputFill =>
      isDarkMode ? AppColors.darkSurfaceHigh : AppColors.gray100;

  // Text
  Color get textPrimary => isDarkMode ? AppColors.darkText : AppColors.gray900;
  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.gray600;
  Color get textTertiary =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.gray700;
  Color get hintColor =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.gray400;

  // Brand ink: navy on light, light sky on dark (navy text vanishes on the
  // navy night). Use for text and outlines that would otherwise be navy.
  Color get brandInk =>
      isDarkMode ? AppColors.primaryLight : AppColors.tertiaryColor;

  // Sky as text: deep sky on light, light sky on dark.
  Color get primaryText =>
      isDarkMode ? AppColors.primaryLight : AppColors.primaryDark;

  // Soft sky wash behind selected / highlighted content.
  Color get primaryWash => isDarkMode
      ? AppColors.primaryColor.withValues(alpha: 0.16)
      : AppColors.sky50;

  // Borders & Dividers
  Color get borderColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.gray200;
  Color get dividerColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.gray200;

  // Icons
  Color get iconDefault =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.gray400;
  Color get iconSecondary =>
      isDarkMode ? AppColors.darkTextMuted : AppColors.gray500;

  // Misc
  Color get chipBg =>
      isDarkMode ? AppColors.darkSurfaceHigh : AppColors.gray100;
  Color get overlayBg =>
      isDarkMode ? AppColors.darkSurfaceHigh : AppColors.gray100;
}
