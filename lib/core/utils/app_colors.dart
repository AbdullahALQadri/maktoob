import 'package:flutter/material.dart';

/// Maktoob design tokens — warm, cultural, event-festive direction.
///
/// All constant names are preserved from the original palette so existing
/// imports keep working. Only the underlying hex values changed: cool grays
/// became warm taupes, generic sky blue became saffron-gold, navy became
/// deep emerald. See DESIGN.md at the project root for the full system.
class AppColors {
  AppColors._();

  // ===========================================================================
  // BRAND
  // ===========================================================================

  /// Saffron-gold — primary celebratory accent (CTAs, focus, key actions).
  static const Color primaryColor = Color(0xFFC2884A);

  /// White — used as on-primary surface (text/icons on primary).
  static const Color secondaryColor = Color(0xFFFFFFFF);

  /// Deep emerald — secondary celebratory accent (tertiary actions,
  /// success states, complementary highlights).
  static const Color tertiaryColor = Color(0xFF0E5E4A);

  static const Color primary = primaryColor;

  /// Warm ivory scaffold background. The defining "warm paper" surface.
  static const Color surfaceBg = Color(0xFFFBF7F1);

  // ===========================================================================
  // NEUTRALS
  // ===========================================================================

  static const Color transparent = Colors.transparent;
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color red = Colors.red;

  /// Warm charcoal — used for primary icons.
  static const Color icons = Color(0xFF1F1B16);

  /// Warm taupe — used for secondary/sub text.
  static const Color subText = Color(0xFF6B5C45);

  // ===========================================================================
  // WARM TAUPE SCALE (named `gray*` for backward compatibility)
  // ===========================================================================
  // These replace the previous cool tailwind grays with a warm-neutral
  // ramp. Every widget that referenced `gray500` etc. now picks up warmth
  // automatically — no widget code changes required.

  static const Color gray50 = Color(0xFFFAF6EE);
  static const Color gray100 = Color(0xFFF1ECDF);
  static const Color gray200 = Color(0xFFE5DDCB);
  static const Color gray300 = Color(0xFFCFC1A8);
  static const Color gray400 = Color(0xFFA8997B);
  static const Color gray500 = Color(0xFF867860);
  static const Color gray600 = Color(0xFF6B5C45);
  static const Color gray700 = Color(0xFF4C3F2E);
  static const Color gray800 = Color(0xFF332921);
  static const Color gray900 = Color(0xFF1F1B16);

  // ===========================================================================
  // EMERALD (secondary accent family)
  // ===========================================================================

  /// Light emerald wash — used as tertiary container.
  static const Color emerald50 = Color(0xFFE8F1EC);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);

  // ===========================================================================
  // AMBER / GOLD (primary container & celebratory accents)
  // ===========================================================================

  static const Color amber50 = Color(0xFFFBF1E0);
  static const Color amber100 = Color(0xFFF6E2BD);
  static const Color amber200 = Color(0xFFEFCE91);
  static const Color amber500 = Color(0xFFD4A24A);
  static const Color amber600 = Color(0xFFB3812F);
  static const Color amber700 = Color(0xFF8E6422);

  // ===========================================================================
  // GREEN (success states)
  // ===========================================================================

  static const Color green50 = Color(0xFFEAF4EC);
  static const Color green100 = Color(0xFFD3E9D6);
  static const Color green600 = Color(0xFF1B7F4A);

  // ===========================================================================
  // RED (errors — kept distinct from the warm palette for clear hierarchy)
  // ===========================================================================

  static const Color red100 = Color(0xFFFADEDA);
  static const Color red500 = Color(0xFFC4523A);

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
  Color get cardBg =>
      isDarkMode ? const Color(0xFF211C16) : AppColors.white;
  Color get themeSurface =>
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
