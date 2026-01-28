import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';

/// A unified icon button widget with consistent styling.
///
/// This button provides various styles for icon-only buttons
/// used throughout the app.
///
/// Example usage:
/// ```dart
/// AppIconButton(
///   icon: Icons.add,
///   onPressed: () => handleAdd(),
/// )
///
/// AppIconButton.filled(
///   icon: Icons.close,
///   onPressed: () => Navigator.pop(context),
///   backgroundColor: AppColors.red500,
/// )
///
/// AppIconButton.outlined(
///   icon: Icons.edit,
///   onPressed: () => handleEdit(),
/// )
/// ```
class AppIconButton extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Callback function when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Icon color.
  final Color? iconColor;

  /// Background color.
  final Color? backgroundColor;

  /// Border color for outlined style.
  final Color? borderColor;

  /// Border width for outlined style.
  final double borderWidth;

  /// Icon size.
  final double? iconSize;

  /// Button size (width and height).
  final double? size;

  /// Border radius.
  final double? borderRadius;

  /// Button style variant.
  final IconButtonVariant variant;

  /// Tooltip text.
  final String? tooltip;

  /// Shadow/elevation.
  final double elevation;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.iconSize,
    this.size,
    this.borderRadius,
    this.variant = IconButtonVariant.ghost,
    this.tooltip,
    this.elevation = 0,
  });

  /// Creates a filled icon button with solid background.
  factory AppIconButton.filled({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Color? iconColor,
    Color? backgroundColor,
    double? iconSize,
    double? size,
    double? borderRadius,
    String? tooltip,
    double elevation = 2,
  }) {
    return AppIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      iconColor: iconColor ?? AppColors.white,
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      iconSize: iconSize,
      size: size,
      borderRadius: borderRadius,
      variant: IconButtonVariant.filled,
      tooltip: tooltip,
      elevation: elevation,
    );
  }

  /// Creates an outlined icon button with border.
  factory AppIconButton.outlined({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Color? iconColor,
    Color? borderColor,
    double borderWidth = 1.5,
    double? iconSize,
    double? size,
    double? borderRadius,
    String? tooltip,
  }) {
    return AppIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      iconColor: iconColor ?? AppColors.primaryColor,
      borderColor: borderColor ?? AppColors.primaryColor,
      borderWidth: borderWidth,
      iconSize: iconSize,
      size: size,
      borderRadius: borderRadius,
      variant: IconButtonVariant.outlined,
      tooltip: tooltip,
    );
  }

  /// Creates a soft/tonal icon button with light background.
  factory AppIconButton.soft({
    Key? key,
    required IconData icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    Color? iconColor,
    Color? backgroundColor,
    double? iconSize,
    double? size,
    double? borderRadius,
    String? tooltip,
  }) {
    return AppIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      iconColor: iconColor ?? AppColors.primaryColor,
      backgroundColor: backgroundColor ?? AppColors.primaryColor.withValues(alpha: 0.1),
      iconSize: iconSize,
      size: size,
      borderRadius: borderRadius,
      variant: IconButtonVariant.soft,
      tooltip: tooltip,
    );
  }

  bool get _isEnabled => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? context.dynamicWidth(0.11);
    final effectiveIconSize = iconSize ?? context.dynamicWidth(0.056);
    final effectiveBorderRadius = borderRadius ?? context.dynamicWidth(0.029);
    final effectiveIconColor = _getIconColor();
    final effectiveBackgroundColor = _getBackgroundColor();

    Widget button = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isEnabled ? 1.0 : 0.5,
      child: Container(
        width: effectiveSize,
        height: effectiveSize,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          border: variant == IconButtonVariant.outlined
              ? Border.all(
                  color: borderColor ?? AppColors.gray300,
                  width: borderWidth,
                )
              : null,
          boxShadow: elevation > 0 && _isEnabled
              ? [
                  BoxShadow(
                    color: (effectiveBackgroundColor ?? AppColors.gray500)
                        .withValues(alpha: 0.3),
                    blurRadius: elevation * 2,
                    offset: Offset(0, elevation),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            splashColor: effectiveIconColor.withValues(alpha: 0.2),
            highlightColor: effectiveIconColor.withValues(alpha: 0.1),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: effectiveIconSize * 0.8,
                      height: effectiveIconSize * 0.8,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(effectiveIconColor),
                      ),
                    )
                  : Icon(
                      icon,
                      size: effectiveIconSize,
                      color: effectiveIconColor,
                    ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Color _getIconColor() {
    if (iconColor != null) return iconColor!;
    switch (variant) {
      case IconButtonVariant.filled:
        return AppColors.white;
      case IconButtonVariant.outlined:
      case IconButtonVariant.soft:
      case IconButtonVariant.ghost:
        return AppColors.gray700;
    }
  }

  Color? _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor;
    switch (variant) {
      case IconButtonVariant.filled:
        return AppColors.primaryColor;
      case IconButtonVariant.soft:
        return AppColors.gray100;
      case IconButtonVariant.outlined:
      case IconButtonVariant.ghost:
        return AppColors.transparent;
    }
  }
}

/// Icon button style variants.
enum IconButtonVariant {
  /// No background, just icon.
  ghost,

  /// Solid colored background.
  filled,

  /// Border with transparent background.
  outlined,

  /// Light/tonal background.
  soft,
}
