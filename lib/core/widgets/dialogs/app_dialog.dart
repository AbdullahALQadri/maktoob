import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// A customizable dialog widget for confirmations and alerts.
///
/// This widget provides a consistent dialog design throughout the app
/// with support for various types (info, success, warning, error, confirmation).
///
/// Example usage:
/// ```dart
/// // Show confirmation dialog
/// final result = await AppDialog.showConfirmation(
///   context,
///   title: 'Delete Event',
///   message: 'Are you sure you want to delete this event?',
///   confirmText: 'Delete',
///   cancelText: 'Cancel',
/// );
///
/// // Show success dialog
/// await AppDialog.showSuccess(
///   context,
///   title: 'Success!',
///   message: 'Event created successfully.',
/// );
/// ```
class AppDialog extends StatelessWidget {
  /// The title of the dialog.
  final String? title;

  /// The message content of the dialog.
  final String? message;

  /// Custom content widget to display.
  final Widget? content;

  /// The type of dialog.
  final DialogType type;

  /// Primary action button text.
  final String? primaryButtonText;

  /// Secondary action button text.
  final String? secondaryButtonText;

  /// Callback for primary action.
  final VoidCallback? onPrimaryPressed;

  /// Callback for secondary action.
  final VoidCallback? onSecondaryPressed;

  /// Whether to show close button.
  final bool showCloseButton;

  /// Whether the dialog is dismissible by tapping outside.
  final bool isDismissible;

  /// Custom icon to display.
  final IconData? icon;

  /// Custom icon color.
  final Color? iconColor;

  /// Custom icon background color.
  final Color? iconBackgroundColor;

  const AppDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.type = DialogType.info,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.showCloseButton = true,
    this.isDismissible = true,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });

  /// Shows a confirmation dialog and returns true if confirmed.
  static Future<bool> showConfirmation(
    BuildContext context, {
    String? title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    DialogType type = DialogType.warning,
    bool isDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        type: type,
        primaryButtonText: confirmText,
        secondaryButtonText: cancelText,
        isDismissible: isDismissible,
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        onSecondaryPressed: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }

  /// Shows a success dialog.
  static Future<void> showSuccess(
    BuildContext context, {
    String? title,
    String? message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title ?? 'Success',
        message: message,
        type: DialogType.success,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Shows an error dialog.
  static Future<void> showError(
    BuildContext context, {
    String? title,
    String? message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title ?? 'Error',
        message: message,
        type: DialogType.error,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Shows an info dialog.
  static Future<void> showInfo(
    BuildContext context, {
    String? title,
    String? message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title ?? 'Info',
        message: message,
        type: DialogType.info,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Shows a custom dialog.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => Dialog(
        backgroundColor: AppColors.transparent,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            if (showCloseButton)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
              ),

            // Icon
            _buildIcon(),

            // Title
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppStrings.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],

            // Message
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppStrings.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray600,
                  height: 1.5,
                ),
              ),
            ],

            // Custom content
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],

            // Buttons
            if (primaryButtonText != null || secondaryButtonText != null) ...[
              const SizedBox(height: 24),
              _buildButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final dialogIcon = icon ?? _getDefaultIcon();
    final dialogIconColor = iconColor ?? _getIconColor();
    final dialogIconBackground = iconBackgroundColor ?? _getIconBackground();

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: dialogIconBackground,
        shape: BoxShape.circle,
      ),
      child: Icon(
        dialogIcon,
        size: 32,
        color: dialogIconColor,
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.confirmation:
        return Icons.help_outline;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case DialogType.success:
        return AppColors.green600;
      case DialogType.error:
        return AppColors.red500;
      case DialogType.warning:
        return AppColors.amber600;
      case DialogType.info:
        return AppColors.blue600;
      case DialogType.confirmation:
        return AppColors.primaryColor;
    }
  }

  Color _getIconBackground() {
    switch (type) {
      case DialogType.success:
        return AppColors.green100;
      case DialogType.error:
        return AppColors.red500.withValues(alpha: 0.1);
      case DialogType.warning:
        return AppColors.amber500.withValues(alpha: 0.1);
      case DialogType.info:
        return AppColors.blue50;
      case DialogType.confirmation:
        return AppColors.purple50;
    }
  }

  Widget _buildButtons(BuildContext context) {
    if (secondaryButtonText != null && primaryButtonText != null) {
      return Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: secondaryButtonText!,
              onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
              height: 48,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              text: primaryButtonText!,
              onPressed: onPrimaryPressed,
              height: 48,
              gradientColors: _getPrimaryButtonColors(),
            ),
          ),
        ],
      );
    }

    if (primaryButtonText != null) {
      return PrimaryButton(
        text: primaryButtonText!,
        onPressed: onPrimaryPressed,
        height: 48,
        gradientColors: _getPrimaryButtonColors(),
      );
    }

    if (secondaryButtonText != null) {
      return SecondaryButton(
        text: secondaryButtonText!,
        onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
        height: 48,
      );
    }

    return const SizedBox.shrink();
  }

  List<Color>? _getPrimaryButtonColors() {
    switch (type) {
      case DialogType.error:
        return [AppColors.red500, AppColors.rose600];
      case DialogType.warning:
        return [AppColors.amber500, AppColors.orange500];
      case DialogType.success:
        return [AppColors.green600, AppColors.emerald600];
      default:
        return null; // Use default gradient
    }
  }
}

/// Type of dialog to display.
enum DialogType {
  info,
  success,
  warning,
  error,
  confirmation,
}
