import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// A customizable modern dialog widget for confirmations and alerts.
///
/// This widget provides a consistent dialog design throughout the app
/// with support for various types (info, success, warning, error, confirmation).
/// Fully responsive and supports RTL languages.
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

  /// Whether primary button is enabled.
  final bool isPrimaryEnabled;

  /// Whether primary button is loading.
  final bool isPrimaryLoading;

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
    this.showCloseButton = false,
    this.isDismissible = true,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.isPrimaryEnabled = true,
    this.isPrimaryLoading = false,
  });

  /// Shows a confirmation dialog and returns true if confirmed.
  static Future<bool> showConfirmation(
    BuildContext context, {
    String? title,
    String? message,
    Widget? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    DialogType type = DialogType.warning,
    bool isDismissible = true,
    IconData? icon,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => AppDialog(
        title: title,
        message: message,
        content: content,
        type: type,
        icon: icon,
        primaryButtonText: confirmText,
        secondaryButtonText: cancelText,
        isDismissible: isDismissible,
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        onSecondaryPressed: () => Navigator.of(context).pop(false),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }

  /// Shows a success dialog.
  static Future<void> showSuccess(
    BuildContext context, {
    String? title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    await _showAnimatedDialog(
      context: context,
      child: AppDialog(
        title: title ?? 'Success',
        message: message,
        type: DialogType.success,
        primaryButtonText: buttonText,
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          onPressed?.call();
        },
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
    await _showAnimatedDialog(
      context: context,
      child: AppDialog(
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
    await _showAnimatedDialog(
      context: context,
      child: AppDialog(
        title: title ?? 'Info',
        message: message,
        type: DialogType.info,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Shows a warning dialog.
  static Future<void> showWarning(
    BuildContext context, {
    String? title,
    String? message,
    String buttonText = 'OK',
  }) async {
    await _showAnimatedDialog(
      context: context,
      child: AppDialog(
        title: title ?? 'Warning',
        message: message,
        type: DialogType.warning,
        primaryButtonText: buttonText,
        onPrimaryPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Shows a custom dialog with full control.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
  }) async {
    return _showAnimatedDialog<T>(
      context: context,
      isDismissible: isDismissible,
      child: child,
    );
  }

  /// Shows a dialog with custom content (e.g., with text fields).
  static Future<T?> showCustom<T>(
    BuildContext context, {
    String? title,
    String? message,
    required Widget content,
    DialogType type = DialogType.info,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool isDismissible = true,
    bool isPrimaryEnabled = true,
    bool isPrimaryLoading = false,
    IconData? icon,
  }) async {
    return _showAnimatedDialog<T>(
      context: context,
      isDismissible: isDismissible,
      child: AppDialog(
        title: title,
        message: message,
        content: content,
        type: type,
        icon: icon,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        isDismissible: isDismissible,
        isPrimaryEnabled: isPrimaryEnabled,
        isPrimaryLoading: isPrimaryLoading,
      ),
    );
  }

  /// Internal method to show animated dialog.
  static Future<T?> _showAnimatedDialog<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.061),
        vertical: context.dynamicHeight(0.03),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: context.dynamicWidth(0.901),
          maxHeight: context.dynamicHeight(0.85),
        ),
        padding: EdgeInsets.all(context.dynamicWidth(0.061)),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.061)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: context.dynamicWidth(0.08),
              offset: Offset(0, context.dynamicHeight(0.02)),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              if (showCloseButton)
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: context.dynamicWidth(0.091),
                      height: context.dynamicWidth(0.091),
                      decoration: BoxDecoration(
                        color: context.overlayBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: context.dynamicWidth(0.051),
                        color: context.iconSecondary,
                      ),
                    ),
                  ),
                ),

              // Icon
              _buildIcon(context),

              // Title
              if (title != null) ...[
                SizedBox(height: context.dynamicHeight(0.02)),
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppStrings.fontFamily,
                    fontSize: context.dynamicWidth(0.056),
                    fontWeight: FontWeight.bold,
                    color: _getTitleColor(context),
                  ),
                ),
              ],

              // Message
              if (message != null) ...[
                SizedBox(height: context.dynamicHeight(0.012)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.021),
                  ),
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppStrings.fontFamily,
                      fontSize: context.dynamicWidth(0.037),
                      fontWeight: FontWeight.w400,
                      color: context.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              // Custom content
              if (content != null) ...[
                SizedBox(height: context.dynamicHeight(0.025)),
                content!,
              ],

              // Buttons
              if (primaryButtonText != null || secondaryButtonText != null) ...[
                SizedBox(height: context.dynamicHeight(0.03)),
                _buildButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTitleColor(BuildContext context) {
    switch (type) {
      case DialogType.error:
        return AppColors.red500;
      case DialogType.warning:
        return AppColors.amber700;
      default:
        return context.textPrimary;
    }
  }

  Widget _buildIcon(BuildContext context) {
    final dialogIcon = icon ?? _getDefaultIcon();
    final dialogIconColor = iconColor ?? _getIconColor();
    final dialogIconBackground = iconBackgroundColor ?? _getIconBackground();

    return Container(
      width: context.dynamicWidth(0.2),
      height: context.dynamicWidth(0.2),
      decoration: BoxDecoration(
        color: dialogIconBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: dialogIconColor.withValues(alpha: 0.2),
            blurRadius: context.dynamicWidth(0.051),
            offset: Offset(0, context.dynamicHeight(0.01)),
          ),
        ],
      ),
      child: Icon(
        dialogIcon,
        size: context.dynamicWidth(0.101),
        color: dialogIconColor,
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle_rounded;
      case DialogType.error:
        return Icons.error_rounded;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_rounded;
      case DialogType.confirmation:
        return Icons.help_rounded;
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
        return AppColors.red500.withValues(alpha: 0.12);
      case DialogType.warning:
        return AppColors.amber500.withValues(alpha: 0.12);
      case DialogType.info:
        return AppColors.blue50;
      case DialogType.confirmation:
        return AppColors.purple50;
    }
  }

  Widget _buildButtons(BuildContext context) {
    final buttonHeight = context.dynamicHeight(0.06);
    final borderRadius = context.dynamicWidth(0.035);

    if (secondaryButtonText != null && primaryButtonText != null) {
      return Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: secondaryButtonText!,
              onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
              height: buttonHeight,
              borderRadius: borderRadius,
              useGradientBorder: false,
              borderColor: context.borderColor,
              textColor: context.textTertiary,
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.029)),
          Expanded(
            child: PrimaryButton(
              text: primaryButtonText!,
              onPressed: isPrimaryEnabled ? onPrimaryPressed : null,
              isLoading: isPrimaryLoading,
              isDisabled: !isPrimaryEnabled,
              height: buttonHeight,
              borderRadius: borderRadius,
              gradientColors: _getPrimaryButtonColors(),
            ),
          ),
        ],
      );
    }

    if (primaryButtonText != null) {
      return PrimaryButton(
        text: primaryButtonText!,
        onPressed: isPrimaryEnabled ? onPrimaryPressed : null,
        isLoading: isPrimaryLoading,
        isDisabled: !isPrimaryEnabled,
        height: buttonHeight,
        borderRadius: borderRadius,
        gradientColors: _getPrimaryButtonColors(),
      );
    }

    if (secondaryButtonText != null) {
      return SecondaryButton(
        text: secondaryButtonText!,
        onPressed: onSecondaryPressed ?? () => Navigator.of(context).pop(),
        height: buttonHeight,
        borderRadius: borderRadius,
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
