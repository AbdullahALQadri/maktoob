import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive.dart';

/// A modern, uniform SnackBar utility for the entire application.
///
/// Features a glassmorphism design with transparent/frosted glass effect.
/// Provides consistent styling with support for different types:
/// success, error, warning, info.
///
/// Example usage:
/// ```dart
/// AppSnackBar.showSuccess(
///   context,
///   message: 'Profile updated successfully',
/// );
///
/// AppSnackBar.showError(
///   context,
///   message: 'Failed to save changes',
/// );
/// ```
class AppSnackBar {
  AppSnackBar._();

  /// Shows a success snackbar with green styling
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows an error snackbar with red styling
  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows a warning snackbar with amber styling
  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows an info snackbar with blue styling
  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows a custom snackbar with primary app color
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
    Color? backgroundColor,
    Color? iconColor,
    IconData? icon,
  }) {
    _show(
      context,
      message: message,
      title: title,
      type: SnackBarType.custom,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
      customBackgroundColor: backgroundColor,
      customIconColor: iconColor,
      customIcon: icon,
    );
  }

  /// Hides the current snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Internal method to show the snackbar
  static void _show(
    BuildContext context, {
    required String message,
    String? title,
    required SnackBarType type,
    required Duration duration,
    VoidCallback? onAction,
    String? actionLabel,
    Color? customBackgroundColor,
    Color? customIconColor,
    IconData? customIcon,
  }) {
    // Hide any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final colors = _getColors(type, customBackgroundColor, customIconColor);
    final icon = customIcon ?? _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _GlassSnackBarContent(
          message: message,
          title: title,
          icon: icon,
          accentColor: colors.accentColor,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.015),
        ),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.045)),
        ),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static _SnackBarColors _getColors(
    SnackBarType type,
    Color? customBg,
    Color? customIcon,
  ) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarColors(
          accentColor: AppColors.green600,
        );
      case SnackBarType.error:
        return _SnackBarColors(
          accentColor: AppColors.red500,
        );
      case SnackBarType.warning:
        return _SnackBarColors(
          accentColor: AppColors.amber600,
        );
      case SnackBarType.info:
        return _SnackBarColors(
          accentColor: AppColors.blue600,
        );
      case SnackBarType.custom:
        return _SnackBarColors(
          accentColor: customBg ?? AppColors.primaryColor,
        );
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
      case SnackBarType.custom:
        return Icons.notifications_rounded;
    }
  }
}

/// Glass morphism snackbar content widget
class _GlassSnackBarContent extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final Color accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _GlassSnackBarContent({
    required this.message,
    this.title,
    required this.icon,
    required this.accentColor,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.045)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            // Semi-transparent dark background for glass effect
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.045)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            // Inner dark overlay for better readability
            decoration: BoxDecoration(
              color: AppColors.gray900.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.045)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.018),
            ),
            child: Row(
              children: [
                // Accent colored icon container
                Container(
                  width: context.dynamicWidth(0.109),
                  height: context.dynamicWidth(0.109),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: context.dynamicWidth(0.056),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.035)),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null) ...[
                        Text(
                          title!,
                          style: TextStyle(
                            fontFamily: AppStrings.fontFamily,
                            fontSize: context.dynamicWidth(0.037),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.dynamicHeight(0.004)),
                      ],
                      Text(
                        message,
                        style: TextStyle(
                          fontFamily: AppStrings.fontFamily,
                          fontSize: context.dynamicWidth(0.035),
                          fontWeight: title != null ? FontWeight.w400 : FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Action button
                if (actionLabel != null && onAction != null) ...[
                  SizedBox(width: context.dynamicWidth(0.021)),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      onAction!();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.035),
                        vertical: context.dynamicHeight(0.01),
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          fontFamily: AppStrings.fontFamily,
                          fontSize: context.dynamicWidth(0.032),
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
                // Close/dismiss indicator
                if (actionLabel == null) ...[
                  SizedBox(width: context.dynamicWidth(0.021)),
                  Container(
                    width: context.dynamicWidth(0.08),
                    height: context.dynamicWidth(0.08),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: context.dynamicWidth(0.04),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal class to hold snackbar colors
class _SnackBarColors {
  final Color accentColor;

  _SnackBarColors({
    required this.accentColor,
  });
}

/// Types of snackbar
enum SnackBarType {
  success,
  error,
  warning,
  info,
  custom,
}
