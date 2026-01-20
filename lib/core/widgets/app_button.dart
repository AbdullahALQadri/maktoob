import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

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

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: outlined ? Border.all(color: border, width: 1.5) : null,
          boxShadow: !outlined && _isEnabled
              ? [
                  BoxShadow(
                    color: bgColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: (outlined ? bgColor : Colors.white).withOpacity(0.2),
            highlightColor:
                (outlined ? bgColor : Colors.white).withOpacity(0.1),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                      ),
                    )
                  : _buildContent(txtColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color txtColor) {
    final defaultTextStyle = TextStyle(
      fontFamily: AppStrings.fontFamily,
      fontSize: fontSize,
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
            size: iconSize,
          ),
          const SizedBox(width: 8),
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
