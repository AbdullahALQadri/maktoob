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
      primaryContainer: AppColors.amber50,
      onPrimaryContainer: AppColors.tertiaryColor,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.tertiaryColor,
      secondaryContainer: AppColors.gray100,
      onSecondaryContainer: AppColors.gray900,
      tertiary: AppColors.tertiaryColor,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.emerald50,
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
      inversePrimary: AppColors.amber500,
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
        foregroundColor: AppColors.primaryColor,
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
        foregroundColor: AppColors.primaryColor,
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
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.1),
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
        color: AppColors.primaryColor,
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
      labelColor: AppColors.primaryColor,
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
    scaffoldBackgroundColor: const Color(0xFF121212),

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.tertiaryColor,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.gray700,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.gray800,
      onSecondaryContainer: AppColors.white,
      tertiary: AppColors.tertiaryColor,
      onTertiary: AppColors.white,
      error: AppColors.red500,
      onError: AppColors.white,
      surface: const Color(0xFF1E1E1E),
      onSurface: AppColors.white,
      surfaceContainerHighest: AppColors.gray800,
      onSurfaceVariant: AppColors.gray400,
      outline: AppColors.gray600,
      outlineVariant: AppColors.gray700,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF121212),
      foregroundColor: AppColors.white,
      surfaceTintColor: AppColors.transparent,
      iconTheme: IconThemeData(color: AppColors.white, size: 24),
      actionsIconTheme: IconThemeData(color: AppColors.white, size: 24),
      titleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    // Text Theme
    textTheme: _buildTextTheme(AppColors.white, AppColors.gray400),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.gray300,
      size: 24,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
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
        foregroundColor: AppColors.primaryColor,
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
        foregroundColor: AppColors.primaryColor,
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
      fillColor: AppColors.gray800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.gray700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.gray700),
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
        borderSide: const BorderSide(color: AppColors.gray700),
      ),
      hintStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.gray500,
      ),
      labelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray400,
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
      color: const Color(0xFF1E1E1E),
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.gray700),
      ),
      margin: EdgeInsets.zero,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      elevation: 16,
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.gray400,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      surfaceTintColor: AppColors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      dragHandleColor: AppColors.gray600,
      dragHandleSize: Size(40, 4),
      showDragHandle: false,
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.gray800,
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
      backgroundColor: AppColors.gray800,
      selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
      disabledColor: AppColors.gray800,
      labelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray300,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
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
      side: const BorderSide(color: AppColors.gray500, width: 1.5),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.gray500;
      }),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.white;
        }
        return AppColors.gray300;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryColor;
        }
        return AppColors.gray700;
      }),
      trackOutlineColor: WidgetStateProperty.all(AppColors.transparent),
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primaryColor,
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

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      iconColor: AppColors.gray400,
      textColor: AppColors.white,
      titleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.gray500,
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.gray700,
      thickness: 1,
      space: 1,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryColor,
      linearTrackColor: AppColors.gray700,
      circularTrackColor: AppColors.gray700,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.gray500,
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
