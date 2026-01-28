import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive.dart';

/// A text button widget with consistent styling.
///
/// This button is used for low-emphasis actions throughout the app.
/// It has no background and shows only text with optional icon.
///
/// Example usage:
/// ```dart
/// AppTextButton(
///   text: 'Learn more',
///   onPressed: () => navigateToInfo(),
/// )
///
/// AppTextButton(
///   text: 'Cancel',
///   onPressed: () => Navigator.pop(context),
///   color: AppColors.gray500,
/// )
/// ```
class AppTextButton extends StatelessWidget {
  /// The text displayed on the button.
  final String text;

  /// Callback function when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Text color.
  final Color? color;

  /// Custom text style.
  final TextStyle? textStyle;

  /// Icon to display before the text.
  final IconData? prefixIcon;

  /// Icon to display after the text.
  final IconData? suffixIcon;

  /// Icon size.
  final double? iconSize;

  /// Padding around the button content.
  final EdgeInsetsGeometry? padding;

  /// Button size variant.
  final ButtonSize size;

  /// Whether text should be underlined.
  final bool underline;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.color,
    this.textStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize,
    this.padding,
    this.size = ButtonSize.medium,
    this.underline = false,
  });

  bool get _isEnabled => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryColor;
    final effectiveFontSize = _getFontSize(context);
    final effectiveIconSize = iconSize ?? _getIconSize(context);
    final effectivePadding = padding ?? _getPadding(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isEnabled ? 1.0 : 0.5,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: _isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
          splashColor: effectiveColor.withValues(alpha: 0.1),
          highlightColor: effectiveColor.withValues(alpha: 0.05),
          child: Padding(
            padding: effectivePadding,
            child: isLoading
                ? SizedBox(
                    width: effectiveFontSize,
                    height: effectiveFontSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                    ),
                  )
                : _buildContent(context, effectiveColor, effectiveFontSize, effectiveIconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Color effectiveColor,
    double fontSize,
    double iconSize,
  ) {
    final defaultTextStyle = TextStyle(
      fontFamily: AppStrings.fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: effectiveColor,
      decoration: underline ? TextDecoration.underline : null,
      decorationColor: effectiveColor,
    );

    final textWidget = Text(
      text,
      style: textStyle ?? defaultTextStyle,
    );

    if (prefixIcon != null || suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[
            Icon(prefixIcon, color: effectiveColor, size: iconSize),
            SizedBox(width: context.dynamicWidth(0.015)),
          ],
          textWidget,
          if (suffixIcon != null) ...[
            SizedBox(width: context.dynamicWidth(0.015)),
            Icon(suffixIcon, color: effectiveColor, size: iconSize),
          ],
        ],
      );
    }

    return textWidget;
  }

  double _getFontSize(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return context.dynamicWidth(0.032);
      case ButtonSize.medium:
        return context.dynamicWidth(0.037);
      case ButtonSize.large:
        return context.dynamicWidth(0.042);
    }
  }

  double _getIconSize(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return context.dynamicWidth(0.04);
      case ButtonSize.medium:
        return context.dynamicWidth(0.045);
      case ButtonSize.large:
        return context.dynamicWidth(0.051);
    }
  }

  EdgeInsetsGeometry _getPadding(BuildContext context) {
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.021),
          vertical: context.dynamicHeight(0.008),
        );
      case ButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.029),
          vertical: context.dynamicHeight(0.012),
        );
      case ButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.035),
          vertical: context.dynamicHeight(0.015),
        );
    }
  }
}

/// Button size variants.
enum ButtonSize {
  small,
  medium,
  large,
}
