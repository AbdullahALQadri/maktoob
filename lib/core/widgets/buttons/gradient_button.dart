import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

/// A customizable button with gradient background support.
///
/// This button provides full control over gradient direction, colors,
/// and various styling options. It can be used for special actions
/// that require custom gradient styling.
///
/// Example usage:
/// ```dart
/// GradientButton(
///   text: 'Get Started',
///   gradientColors: [Colors.blue, Colors.purple],
///   onPressed: () => handleGetStarted(),
/// )
/// ```
class GradientButton extends StatefulWidget {
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

  /// The gradient colors for the button background.
  final List<Color> gradientColors;

  /// The starting alignment for the gradient.
  final AlignmentGeometry gradientBegin;

  /// The ending alignment for the gradient.
  final AlignmentGeometry gradientEnd;

  /// Custom text style for the button text.
  final TextStyle? textStyle;

  /// Text color. Defaults to white.
  final Color textColor;

  /// Optional icon to display before the text.
  final IconData? icon;

  /// Icon size. Defaults to 20.
  final double iconSize;

  /// Optional child widget to display instead of text.
  final Widget? child;

  /// Whether to show shadow when enabled.
  final bool showShadow;

  /// Shadow color. Defaults to first gradient color with opacity.
  final Color? shadowColor;

  /// Whether to animate on tap.
  final bool animateOnTap;

  const GradientButton({
    super.key,
    this.text = '',
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.gradientColors = const [],
    this.gradientBegin = Alignment.centerLeft,
    this.gradientEnd = Alignment.centerRight,
    this.textStyle,
    this.textColor = Colors.white,
    this.icon,
    this.iconSize = 20,
    this.child,
    this.showShadow = true,
    this.shadowColor,
    this.animateOnTap = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      !widget.isLoading && !widget.isDisabled && widget.onPressed != null;

  List<Color> get _effectiveGradientColors => widget.gradientColors.isEmpty
      ? [AppColors.purple600, AppColors.pink600]
      : widget.gradientColors;

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled && widget.animateOnTap) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.animateOnTap) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.animateOnTap) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isEnabled ? 1.0 : 0.6,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _effectiveGradientColors,
                  begin: widget.gradientBegin,
                  end: widget.gradientEnd,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _isEnabled && widget.showShadow
                    ? [
                        BoxShadow(
                          color: (widget.shadowColor ??
                                  _effectiveGradientColors.first)
                              .withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: (widget.shadowColor ??
                                  _effectiveGradientColors.last)
                              .withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: AppColors.transparent,
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  child: InkWell(
                    onTap: _isEnabled ? widget.onPressed : null,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    splashColor: AppColors.white.withValues(alpha: 0.2),
                    highlightColor: AppColors.white.withValues(alpha: 0.1),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.textColor),
                              ),
                            )
                          : _buildContent(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.child != null) {
      return widget.child!;
    }

    final defaultTextStyle = TextStyle(
      fontFamily: AppStrings.fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: widget.textColor,
    );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: widget.textColor,
            size: widget.iconSize,
          ),
          if (widget.text.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: widget.textStyle ?? defaultTextStyle,
            ),
          ],
        ],
      );
    }

    return Text(
      widget.text,
      style: widget.textStyle ?? defaultTextStyle,
    );
  }
}

/// A custom animated builder widget for smoother animations.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedWidget_(
      animation: animation,
      builder: builder,
    );
  }
}

class AnimatedWidget_ extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedWidget_({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
