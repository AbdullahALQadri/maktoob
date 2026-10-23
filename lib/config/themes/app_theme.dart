import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/app_spacing.dart';

/// Application theme configuration.
///
/// This class provides complete theme definitions for light and dark modes
/// with consistent styling across all Material widgets.
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppStrings.fontFamily,

    // Colors
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.surfaceBg,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.sky50,
      onPrimaryContainer: AppColors.tertiaryColor,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.tertiaryColor,
      secondaryContainer: AppColors.gray100,
      onSecondaryContainer: AppColors.gray900,
      tertiary: AppColors.tertiaryColor,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.navy50,
      onTertiaryContainer: AppColors.tertiaryColor,
      error: AppColors.red500,
      onError: AppColors.white,
      errorContainer: AppColors.red100,
      onErrorContainer: AppColors.red500,
      surface: AppColors.white,
      onSurface: AppColors.gray900,
      surfaceContainerHighest: AppColors.gray100,
      onSurfaceVariant: AppColors.gray600,
      outline: AppColors.gray300,
      outlineVariant: AppColors.gray200,
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: AppColors.gray900,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.primaryLight,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.surfaceBg,
      foregroundColor: AppColors.gray900,
      surfaceTintColor: AppColors.transparent,
      iconTheme: IconThemeData(color: AppColors.gray900, size: 24),
      actionsIconTheme: IconThemeData(color: AppColors.gray900, size: 24),
      titleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),

    // Text Theme
    textTheme: _buildTextTheme(AppColors.gray900, AppColors.gray600),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.gray700,
      size: 24,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.gray200,
        disabledForegroundColor: AppColors.gray500,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: const TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.red500),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.red500, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      hintStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.gray400,
      ),
      labelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
      errorStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.red500,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.gray200),
      ),
      margin: EdgeInsets.zero,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      elevation: 16,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.gray600,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      dragHandleColor: AppColors.gray300,
      dragHandleSize: Size(40, 4),
      showDragHandle: false,
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.gray900,
      contentTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.gray100,
      selectedColor: AppColors.sky50,
      disabledColor: AppColors.gray100,
      labelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(color: AppColors.gray400, width: 1.5),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.gray400;
      }),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.gray300;
      }),
      trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primaryDark,
      unselectedLabelColor: AppColors.gray500,
      indicatorColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.gray400,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.gray200,
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColor,
      linearTrackColor: AppColors.gray200,
      circularTrackColor: AppColors.gray200,
    ),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      iconColor: AppColors.gray600,
      textColor: AppColors.gray900,
      titleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.gray900,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.gray500,
      ),
    ),
  );

  // ===========================================================================
  // DARK THEME
  // ===========================================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppStrings.fontFamily,

    // Colors
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkBg,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.tertiaryColor,
      onPrimaryContainer: AppColors.darkText,
      secondary: AppColors.darkSurfaceHigh,
      onSecondary: AppColors.darkText,
      secondaryContainer: AppColors.darkSurfaceHigh,
      onSecondaryContainer: AppColors.darkText,
      // Navy is invisible on the navy night, so tertiary turns light sky.
      tertiary: AppColors.primaryLight,
      onTertiary: AppColors.tertiaryColor,
      tertiaryContainer: AppColors.navy700,
      onTertiaryContainer: AppColors.darkText,
      error: AppColors.darkError,
      onError: AppColors.darkBg,
      errorContainer: AppColors.darkErrorContainer,
      onErrorContainer: AppColors.darkOnErrorContainer,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurfaceHigh,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorderStrong,
      outlineVariant: AppColors.darkBorder,
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: AppColors.darkText,
      onInverseSurface: AppColors.darkBg,
      inversePrimary: AppColors.primaryDark,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkText,
      surfaceTintColor: AppColors.transparent,
      iconTheme: IconThemeData(color: AppColors.darkText, size: 24),
      actionsIconTheme: IconThemeData(color: AppColors.darkText, size: 24),
      titleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // Text Theme
    textTheme: _buildTextTheme(AppColors.darkText, AppColors.darkTextSecondary),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.darkTextSecondary,
      size: 24,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.darkSurfaceHigh,
        disabledForegroundColor: AppColors.darkTextMuted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: const TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        textStyle: const TextStyle(
          fontFamily: AppStrings.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.darkError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      hintStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextMuted,
      ),
      labelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextSecondary,
      ),
      errorStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.darkError,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      margin: EdgeInsets.zero,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      elevation: 16,
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: AppColors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      dragHandleColor: AppColors.darkBorderStrong,
      dragHandleSize: Size(40, 4),
      showDragHandle: false,
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurfaceHigh,
      contentTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurfaceHigh,
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
      disabledColor: AppColors.darkSurfaceHigh,
      labelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryLight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(color: AppColors.darkBorderStrong, width: 1.5),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.darkTextMuted;
      }),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.darkBorderStrong;
      }),
      trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primaryLight,
      unselectedLabelColor: AppColors.darkTextMuted,
      indicatorColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      iconColor: AppColors.darkTextSecondary,
      textColor: AppColors.darkText,
      titleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darkText,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColor,
      linearTrackColor: AppColors.darkBorder,
      circularTrackColor: AppColors.darkBorder,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.darkTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
  );

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.33,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.43,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.33,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        height: 1.45,
      ),
    );
  }
}
