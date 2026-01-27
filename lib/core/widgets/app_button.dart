import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../utils/responsive.dart';

/// A flexible button widget that supports various styles.
///
/// This button can be used as primary, secondary, or custom styled button.
class AppButton extends StatelessWidget {
  /// The text displayed on the button.
  final String text;

  /// Callback function when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Custom width for the button. Defaults to full width.
  final double? width;

  /// Custom height for the button. Defaults to 48.
  final double height;

  /// Border radius for the button. Defaults to 12.
  final double borderRadius;

  /// Background color. If null, uses primary color.
  final Color? backgroundColor;

  /// Text color. Defaults to white.
  final Color? textColor;

  /// Optional icon to display before the text.
  final IconData? icon;

  /// Icon size. Defaults to 20.
  final double iconSize;

  /// Font size. Defaults to 16.
  final double fontSize;

  /// Whether to use outline style.
  final bool outlined;

  /// Border color for outlined button.
  final Color? borderColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 48,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconSize = 20,
    this.fontSize = 16,
    this.outlined = false,
    this.borderColor,
  });

  bool get _isEnabled => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryColor;
    final txtColor = textColor ?? (outlined ? bgColor : Colors.white);
    final border = borderColor ?? bgColor;

    // Use responsive values when defaults are used
    final effectiveHeight = height == 48 ? context.dynamicHeight(0.06) : height;
    final effectiveBorderRadius = borderRadius == 12 ? context.dynamicWidth(0.029) : borderRadius;
    final effectiveIconSize = iconSize == 20 ? context.dynamicWidth(0.051) : iconSize;
    final effectiveFontSize = fontSize == 16 ? context.dynamicWidth(0.04) : fontSize;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width ?? double.infinity,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : bgColor,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          border: outlined ? Border.all(color: border, width: 1.5) : null,
          boxShadow: !outlined && _isEnabled
              ? [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.2),
                    blurRadius: context.dynamicWidth(0.021),
                    offset: Offset(0, context.dynamicHeight(0.002)),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            splashColor: (outlined ? bgColor : Colors.white).withValues(alpha: 0.2),
            highlightColor:
                (outlined ? bgColor : Colors.white).withValues(alpha: 0.1),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: context.dynamicWidth(0.056),
                      height: context.dynamicWidth(0.056),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                      ),
                    )
                  : _buildContent(context, txtColor, effectiveIconSize, effectiveFontSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color txtColor, double effectiveIconSize, double effectiveFontSize) {
    final defaultTextStyle = TextStyle(
      fontFamily: AppStrings.fontFamily,
      fontSize: effectiveFontSize,
      fontWeight: FontWeight.w600,
      color: txtColor,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: txtColor,
            size: effectiveIconSize,
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Text(
            text,
            style: defaultTextStyle,
          ),
        ],
      );
    }

    return Text(
      text,
      style: defaultTextStyle,
    );
  }
}
