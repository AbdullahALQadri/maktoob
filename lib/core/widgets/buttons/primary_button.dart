import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive.dart';

/// A primary button widget with gradient support.
///
/// This button is used for primary actions throughout the app.
/// It features a gradient background from purple to pink and
/// includes hover/press animations.
///
/// Example usage:
/// ```dart
/// PrimaryButton(
///   text: 'Continue',
///   onPressed: () => handleContinue(),
///   isLoading: isSubmitting,
/// )
/// ```
class PrimaryButton extends StatelessWidget {
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

  /// Custom gradient colors. If not provided, uses default purple-pink gradient.
  final List<Color>? gradientColors;

  /// Custom text style for the button text.
  final TextStyle? textStyle;

  /// Optional icon to display before the text.
  final IconData? icon;

  /// Icon size. Defaults to 20.
  final double iconSize;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
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
    // Use responsive values when defaults are used
    final effectiveHeight = height == 56 ? context.dynamicHeight(0.07) : height;
    final effectiveBorderRadius = borderRadius == 12 ? context.dynamicWidth(0.029) : borderRadius;
    final effectiveIconSize = iconSize == 20 ? context.dynamicWidth(0.051) : iconSize;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width ?? double.infinity,
        height: effectiveHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? _defaultGradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          boxShadow: _isEnabled
              ? [
                  BoxShadow(
                    color: (gradientColors?.first ?? AppColors.primaryColor)
                        .withValues(alpha: 0.3),
                    blurRadius: context.dynamicWidth(0.029),
                    offset: Offset(0, context.dynamicHeight(0.005)),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            splashColor: AppColors.white.withValues(alpha: 0.2),
            highlightColor: AppColors.white.withValues(alpha: 0.1),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: context.dynamicWidth(0.061),
                      height: context.dynamicWidth(0.061),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : _buildContent(context, effectiveIconSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double effectiveIconSize) {
    final defaultTextStyle = TextStyle(
      fontFamily: AppStrings.fontFamily,
      fontSize: context.dynamicWidth(0.04),
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.white,
            size: effectiveIconSize,
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Text(
            text,
            style: textStyle ?? defaultTextStyle,
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle ?? defaultTextStyle,
    );
  }
}
