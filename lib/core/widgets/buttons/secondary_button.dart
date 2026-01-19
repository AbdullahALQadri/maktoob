import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

/// A secondary button widget with outlined style and optional gradient border.
///
/// This button is used for secondary actions throughout the app.
/// It features a transparent background with a gradient border.
///
/// Example usage:
/// ```dart
/// SecondaryButton(
///   text: 'Cancel',
///   onPressed: () => handleCancel(),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
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

  /// Custom height for the button. Defaults to 56.
  final double height;

  /// Border radius for the button. Defaults to 12.
  final double borderRadius;

  /// Border width. Defaults to 2.
  final double borderWidth;

  /// Whether to use gradient border. Defaults to true.
  final bool useGradientBorder;

  /// Custom border color when not using gradient.
  final Color? borderColor;

  /// Custom text color.
  final Color? textColor;

  /// Custom gradient colors for the border.
  final List<Color>? gradientColors;

  /// Custom text style for the button text.
  final TextStyle? textStyle;

  /// Optional icon to display before the text.
  final IconData? icon;

  /// Icon size. Defaults to 20.
  final double iconSize;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.useGradientBorder = true,
    this.borderColor,
    this.textColor,
    this.gradientColors,
    this.textStyle,
    this.icon,
    this.iconSize = 20,
  });

  bool get _isEnabled => !isLoading && !isDisabled && onPressed != null;

  List<Color> get _defaultGradientColors => [
        AppColors.primaryColor,
        AppColors.tertiaryColor,
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: useGradientBorder
              ? LinearGradient(
                  colors: gradientColors ?? _defaultGradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          border: !useGradientBorder
              ? Border.all(
                  color: borderColor ?? AppColors.gray300,
                  width: borderWidth,
                )
              : null,
        ),
        child: Container(
          margin: useGradientBorder ? EdgeInsets.all(borderWidth) : null,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
                BorderRadius.circular(borderRadius - (useGradientBorder ? borderWidth : 0)),
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: _isEnabled ? onPressed : null,
              borderRadius: BorderRadius.circular(
                  borderRadius - (useGradientBorder ? borderWidth : 0)),
              splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
              highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            textColor ?? AppColors.primaryColor,
                          ),
                        ),
                      )
                    : _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final effectiveTextColor = textColor ?? AppColors.primaryColor;
    final defaultTextStyle = TextStyle(
      fontFamily: AppStrings.fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: effectiveTextColor,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: effectiveTextColor,
            size: iconSize,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: textStyle ?? defaultTextStyle,
          ),
        ],
      );
    }

    // Use ShaderMask for gradient text when using gradient border
    if (useGradientBorder && textColor == null) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: gradientColors ?? _defaultGradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Text(
          text,
          style: (textStyle ?? defaultTextStyle).copyWith(
            color: AppColors.white,
          ),
        ),
      );
    }

    return Text(
      text,
      style: textStyle ?? defaultTextStyle,
    );
  }
}
