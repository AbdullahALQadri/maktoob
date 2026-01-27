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
        horizontal: 23.w,
        vertical: 24.h,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 338.w,
          maxHeight: 690.h,
        ),
        padding: EdgeInsets.all(23.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(23.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: 30.w,
              offset: Offset(0, 16.h),
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
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 19.w,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                ),

              // Icon
              _buildIcon(context),

              // Title
              if (title != null) ...[
                SizedBox(height: 16.h),
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppStrings.fontFamily,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                    color: _getTitleColor(),
                  ),
                ),
              ],

              // Message
              if (message != null) ...[
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                  ),
                  child: Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppStrings.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              // Custom content
              if (content != null) ...[
                SizedBox(height: 20.h),
                content!,
              ],

              // Buttons
              if (primaryButtonText != null || secondaryButtonText != null) ...[
                SizedBox(height: 24.h),
                _buildButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTitleColor() {
    switch (type) {
      case DialogType.error:
        return AppColors.red500;
      case DialogType.warning:
        return AppColors.amber700;
      default:
        return AppColors.gray900;
    }
  }

  Widget _buildIcon(BuildContext context) {
    final dialogIcon = icon ?? _getDefaultIcon();
    final dialogIconColor = iconColor ?? _getIconColor();
    final dialogIconBackground = iconBackgroundColor ?? _getIconBackground();

    return Container(
      width: 75.w,
      height: 75.w,
      decoration: BoxDecoration(
        color: dialogIconBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: dialogIconColor.withValues(alpha: 0.2),
            blurRadius: 19.w,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Icon(
        dialogIcon,
        size: 38.w,
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
    final buttonHeight = 49.h;
    final borderRadius = 13.w;

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
              borderColor: AppColors.gray300,
              textColor: AppColors.gray700,
            ),
          ),
          SizedBox(width: 11.w),
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
