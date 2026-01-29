import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// A modern, customizable bottom sheet widget with consistent styling.
///
/// This widget provides a reusable bottom sheet design with support
/// for drag handle, title, icons, and various sheet types.
///
/// Example usage:
/// ```dart
/// AppBottomSheet.show(
///   context,
///   title: 'Select Option',
///   child: ListView(
///     children: options.map((o) => ListTile(title: Text(o))).toList(),
///   ),
/// );
/// ```
class AppBottomSheet extends StatelessWidget {
  /// The title of the bottom sheet.
  final String? title;

  /// Subtitle text below the title.
  final String? subtitle;

  /// The content of the bottom sheet.
  final Widget child;

  /// Whether to show the drag handle.
  final bool showDragHandle;

  /// Whether to show the close button.
  final bool showCloseButton;

  /// Whether the sheet is scrollable.
  final bool isScrollable;

  /// Minimum height of the sheet as fraction of screen height.
  final double? minHeight;

  /// Maximum height of the sheet as fraction of screen height.
  final double? maxHeight;

  /// Initial height of the sheet as fraction of screen height.
  final double? initialHeight;

  /// Padding for the content.
  final EdgeInsetsGeometry? padding;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius for the sheet.
  final double borderRadius;

  /// Callback when close button is pressed.
  final VoidCallback? onClose;

  /// Action widget to display in the header.
  final Widget? action;

  /// Icon to display in the header.
  final IconData? icon;

  /// Icon color.
  final Color? iconColor;

  /// Icon background color.
  final Color? iconBackgroundColor;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.isScrollable = true,
    this.minHeight,
    this.maxHeight,
    this.initialHeight,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 24,
    this.onClose,
    this.action,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });

  /// Shows a modal bottom sheet with modern animation.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    String? subtitle,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isScrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? minHeight,
    double? maxHeight,
    double? initialHeight,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double borderRadius = 24,
    Widget? action,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: AppColors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 350),
      ),
      builder: (context) => AppBottomSheet(
        title: title,
        subtitle: subtitle,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        isScrollable: isScrollable,
        minHeight: minHeight,
        maxHeight: maxHeight,
        initialHeight: initialHeight,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        action: action,
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        child: child,
      ),
    );
  }

  /// Shows a draggable scrollable bottom sheet.
  static Future<T?> showDraggable<T>(
    BuildContext context, {
    required Widget Function(BuildContext, ScrollController) builder,
    String? title,
    String? subtitle,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
    double initialChildSize = 0.5,
    Color? backgroundColor,
    double borderRadius = 24,
    Widget? action,
    IconData? icon,
    Color? iconColor,
    Color? iconBackgroundColor,
  }) {
    final effectiveBorderRadius = borderRadius == 24
        ? context.dynamicWidth(0.061)
        : borderRadius;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: AppColors.transparent,
      builder: (context) => DraggableScrollableSheet(
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        initialChildSize: initialChildSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? context.cardBg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(effectiveBorderRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Drag handle and header
                _SheetHeader(
                  title: title,
                  subtitle: subtitle,
                  showDragHandle: showDragHandle,
                  showCloseButton: showCloseButton,
                  action: action,
                  icon: icon,
                  iconColor: iconColor,
                  iconBackgroundColor: iconBackgroundColor,
                ),
                // Content
                Expanded(
                  child: builder(context, scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Shows a confirm/cancel bottom sheet with modern styling.
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
    SheetType type = SheetType.warning,
  }) async {
    final colors = _getTypeColors(type);
    final result = await show<bool>(
      context,
      title: title,
      icon: icon ?? _getTypeIcon(type),
      iconColor: colors.iconColor,
      iconBackgroundColor: colors.iconBackground,
      showCloseButton: false,
      child: _ConfirmSheet(
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor ?? colors.buttonColor,
      ),
    );
    return result ?? false;
  }

  /// Shows an options picker bottom sheet.
  static Future<T?> showOptions<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<SheetOption<T>> options,
    T? selectedValue,
    IconData? icon,
  }) {
    return show<T>(
      context,
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      child: _OptionsSheet<T>(
        options: options,
        selectedValue: selectedValue,
      ),
    );
  }

  /// Shows an action sheet with a list of actions.
  static Future<T?> showActions<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    required List<SheetAction<T>> actions,
    String? cancelText,
  }) {
    return show<T>(
      context,
      title: title,
      subtitle: subtitle,
      showCloseButton: title != null,
      child: _ActionsSheet<T>(
        actions: actions,
        cancelText: cancelText,
      ),
    );
  }

  /// Shows an info bottom sheet.
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    IconData? icon,
  }) async {
    await show(
      context,
      title: title,
      icon: icon ?? Icons.info_rounded,
      iconColor: AppColors.blue600,
      iconBackgroundColor: AppColors.blue50,
      showCloseButton: false,
      child: _InfoSheet(
        message: message,
        buttonText: buttonText,
      ),
    );
  }

  /// Shows a success bottom sheet.
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    await show(
      context,
      title: title,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.green600,
      iconBackgroundColor: AppColors.green100,
      showCloseButton: false,
      child: _InfoSheet(
        message: message,
        buttonText: buttonText,
        buttonColor: AppColors.green600,
        onPressed: onPressed,
      ),
    );
  }

  /// Shows an error bottom sheet.
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await show(
      context,
      title: title,
      icon: Icons.error_rounded,
      iconColor: AppColors.red500,
      iconBackgroundColor: AppColors.red500.withValues(alpha: 0.1),
      showCloseButton: false,
      child: _InfoSheet(
        message: message,
        buttonText: buttonText,
        buttonColor: AppColors.red500,
      ),
    );
  }

  static _TypeColors _getTypeColors(SheetType type) {
    switch (type) {
      case SheetType.success:
        return _TypeColors(
          iconColor: AppColors.green600,
          iconBackground: AppColors.green100,
          buttonColor: AppColors.green600,
        );
      case SheetType.error:
        return _TypeColors(
          iconColor: AppColors.red500,
          iconBackground: AppColors.red500.withValues(alpha: 0.1),
          buttonColor: AppColors.red500,
        );
      case SheetType.warning:
        return _TypeColors(
          iconColor: AppColors.amber600,
          iconBackground: AppColors.amber500.withValues(alpha: 0.1),
          buttonColor: AppColors.amber600,
        );
      case SheetType.info:
        return _TypeColors(
          iconColor: AppColors.blue600,
          iconBackground: AppColors.blue50,
          buttonColor: AppColors.blue600,
        );
    }
  }

  static IconData _getTypeIcon(SheetType type) {
    switch (type) {
      case SheetType.success:
        return Icons.check_circle_rounded;
      case SheetType.error:
        return Icons.error_rounded;
      case SheetType.warning:
        return Icons.warning_rounded;
      case SheetType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? 0.9;
    final effectiveMinHeight = minHeight ?? 0.1;
    final effectiveBorderRadius = borderRadius == 24
        ? context.dynamicWidth(0.061)
        : borderRadius;
    final defaultPadding = EdgeInsets.fromLTRB(
      context.dynamicWidth(0.061),
      0,
      context.dynamicWidth(0.061),
      context.dynamicHeight(0.03),
    );

    Widget content = Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * effectiveMaxHeight,
        minHeight: screenHeight * effectiveMinHeight,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.cardBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(effectiveBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _SheetHeader(
            title: title,
            subtitle: subtitle,
            showDragHandle: showDragHandle,
            showCloseButton: showCloseButton,
            onClose: onClose,
            action: action,
            icon: icon,
            iconColor: iconColor,
            iconBackgroundColor: iconBackgroundColor,
          ),
          // Content
          if (isScrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: padding ?? defaultPadding,
                child: child,
              ),
            )
          else
            Padding(
              padding: padding ?? defaultPadding,
              child: child,
            ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: content,
    );
  }
}

/// Header widget for the bottom sheet.
class _SheetHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showDragHandle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Widget? action;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const _SheetHeader({
    this.title,
    this.subtitle,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.onClose,
    this.action,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        if (showDragHandle)
          Container(
            margin: EdgeInsets.only(top: context.dynamicHeight(0.015)),
            width: context.dynamicWidth(0.101),
            height: context.dynamicHeight(0.005),
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
            ),
          ),

        // Icon (if provided)
        if (icon != null) ...[
          SizedBox(height: context.dynamicHeight(0.025)),
          Container(
            width: context.dynamicWidth(0.16),
            height: context.dynamicWidth(0.16),
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.purple50,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (iconColor ?? AppColors.primaryColor).withValues(alpha: 0.2),
                  blurRadius: context.dynamicWidth(0.04),
                  offset: Offset(0, context.dynamicHeight(0.007)),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: context.dynamicWidth(0.08),
              color: iconColor ?? AppColors.primaryColor,
            ),
          ),
        ],

        // Title and close button
        if (title != null || showCloseButton)
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.dynamicWidth(0.061),
              icon != null ? context.dynamicHeight(0.02) : context.dynamicHeight(0.02),
              context.dynamicWidth(0.061),
              context.dynamicHeight(0.01),
            ),
            child: Row(
              children: [
                // Title and subtitle
                if (title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: icon != null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          textAlign: icon != null ? TextAlign.center : TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppStrings.fontFamily,
                            fontSize: context.dynamicWidth(0.051),
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: context.dynamicHeight(0.005)),
                          Text(
                            subtitle!,
                            textAlign: icon != null ? TextAlign.center : TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppStrings.fontFamily,
                              fontSize: context.dynamicWidth(0.035),
                              color: context.iconSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Spacer if no title
                if (title == null) const Spacer(),

                // Action
                if (action != null) ...[
                  action!,
                  SizedBox(width: context.dynamicWidth(0.029)),
                ],

                // Close button
                if (showCloseButton && icon == null)
                  GestureDetector(
                    onTap: onClose ?? () => Navigator.of(context).pop(),
                    child: Container(
                      width: context.dynamicWidth(0.091),
                      height: context.dynamicWidth(0.091),
                      decoration: BoxDecoration(
                        color: context.overlayBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: context.dynamicWidth(0.051),
                        color: context.iconSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Divider for sheets without icon
        if (title != null && icon == null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
            child: Divider(
              color: context.overlayBg,
              height: context.dynamicHeight(0.02),
            ),
          ),
      ],
    );
  }
}

/// Confirm sheet content widget.
class _ConfirmSheet extends StatelessWidget {
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;

  const _ConfirmSheet({
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppStrings.fontFamily,
            fontSize: context.dynamicWidth(0.037),
            color: context.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.03)),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: cancelText,
                onPressed: () => Navigator.of(context).pop(false),
                height: context.dynamicHeight(0.06),
                borderRadius: context.dynamicWidth(0.035),
                useGradientBorder: false,
                borderColor: context.borderColor,
                textColor: context.textTertiary,
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.029)),
            Expanded(
              child: PrimaryButton(
                text: confirmText,
                onPressed: () => Navigator.of(context).pop(true),
                height: context.dynamicHeight(0.06),
                borderRadius: context.dynamicWidth(0.035),
                gradientColors: confirmColor != null
                    ? [confirmColor!, confirmColor!.withValues(alpha: 0.8)]
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Info sheet content widget.
class _InfoSheet extends StatelessWidget {
  final String message;
  final String buttonText;
  final Color? buttonColor;
  final VoidCallback? onPressed;

  const _InfoSheet({
    required this.message,
    required this.buttonText,
    this.buttonColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppStrings.fontFamily,
            fontSize: context.dynamicWidth(0.037),
            color: context.textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.03)),
        PrimaryButton(
          text: buttonText,
          onPressed: () {
            Navigator.of(context).pop();
            onPressed?.call();
          },
          height: context.dynamicHeight(0.06),
          borderRadius: context.dynamicWidth(0.035),
          gradientColors: buttonColor != null
              ? [buttonColor!, buttonColor!.withValues(alpha: 0.8)]
              : null,
        ),
      ],
    );
  }
}

/// Options sheet content widget.
class _OptionsSheet<T> extends StatelessWidget {
  final List<SheetOption<T>> options;
  final T? selectedValue;

  const _OptionsSheet({
    required this.options,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        final isSelected = option.value == selectedValue;
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(option.value),
          child: Container(
            margin: EdgeInsets.only(bottom: context.dynamicHeight(0.01)),
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.018),
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.purple50 : context.themeSurface,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : context.borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Container(
                    width: context.dynamicWidth(0.101),
                    height: context.dynamicWidth(0.101),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.1)
                          : context.overlayBg,
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
                    ),
                    child: Icon(
                      option.icon,
                      color: isSelected ? AppColors.primaryColor : context.iconSecondary,
                      size: context.dynamicWidth(0.051),
                    ),
                  ),
                  SizedBox(width: context.dynamicWidth(0.029)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: TextStyle(
                          fontFamily: AppStrings.fontFamily,
                          fontSize: context.dynamicWidth(0.04),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryColor : context.textPrimary,
                        ),
                      ),
                      if (option.subtitle != null) ...[
                        SizedBox(height: context.dynamicHeight(0.002)),
                        Text(
                          option.subtitle!,
                          style: TextStyle(
                            fontFamily: AppStrings.fontFamily,
                            fontSize: context.dynamicWidth(0.032),
                            color: context.iconSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: context.dynamicWidth(0.061),
                    height: context.dynamicWidth(0.061),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: context.dynamicWidth(0.035),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Actions sheet content widget.
class _ActionsSheet<T> extends StatelessWidget {
  final List<SheetAction<T>> actions;
  final String? cancelText;

  const _ActionsSheet({
    required this.actions,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...actions.map((action) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(action.value),
            child: Container(
              margin: EdgeInsets.only(bottom: context.dynamicHeight(0.01)),
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.04),
                vertical: context.dynamicHeight(0.018),
              ),
              decoration: BoxDecoration(
                color: action.isDestructive
                    ? AppColors.red500.withValues(alpha: 0.05)
                    : context.themeSurface,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
              ),
              child: Row(
                children: [
                  if (action.icon != null) ...[
                    Container(
                      width: context.dynamicWidth(0.101),
                      height: context.dynamicWidth(0.101),
                      decoration: BoxDecoration(
                        color: action.isDestructive
                            ? AppColors.red500.withValues(alpha: 0.1)
                            : context.overlayBg,
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
                      ),
                      child: Icon(
                        action.icon,
                        color: action.isDestructive ? AppColors.red500 : context.textSecondary,
                        size: context.dynamicWidth(0.051),
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(0.029)),
                  ],
                  Expanded(
                    child: Text(
                      action.label,
                      style: TextStyle(
                        fontFamily: AppStrings.fontFamily,
                        fontSize: context.dynamicWidth(0.04),
                        fontWeight: FontWeight.w500,
                        color: action.isDestructive ? AppColors.red500 : context.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: action.isDestructive ? AppColors.red500 : context.iconDefault,
                    size: context.dynamicWidth(0.051),
                  ),
                ],
              ),
            ),
          );
        }),
        if (cancelText != null) ...[
          SizedBox(height: context.dynamicHeight(0.01)),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.018)),
              decoration: BoxDecoration(
                color: context.overlayBg,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
              ),
              child: Text(
                cancelText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppStrings.fontFamily,
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.w600,
                  color: context.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Type colors helper class.
class _TypeColors {
  final Color iconColor;
  final Color iconBackground;
  final Color buttonColor;

  _TypeColors({
    required this.iconColor,
    required this.iconBackground,
    required this.buttonColor,
  });
}

/// Sheet types.
enum SheetType {
  success,
  error,
  warning,
  info,
}

/// Option for options sheet.
class SheetOption<T> {
  final String label;
  final String? subtitle;
  final T value;
  final IconData? icon;

  const SheetOption({
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
  });
}

/// Action for action sheet.
class SheetAction<T> {
  final String label;
  final T value;
  final IconData? icon;
  final bool isDestructive;

  const SheetAction({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
  });
}
