import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// A modern shimmer/skeleton loading widget with gradient animation.
///
/// This widget creates a shimmering effect that moves across the child widget,
/// commonly used to indicate loading states in a visually appealing way.
///
/// Example usage:
/// ```dart
/// ShimmerLoading(
///   child: Container(
///     width: 200,
///     height: 100,
///     color: Colors.white,
///   ),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  /// The child widget to apply the shimmer effect to.
  final Widget child;

  /// The base color of the shimmer (the darker color).
  final Color? baseColor;

  /// The highlight color of the shimmer (the lighter, moving color).
  final Color? highlightColor;

  /// Duration of one shimmer animation cycle.
  final Duration duration;

  /// Whether the shimmer animation is enabled.
  final bool enabled;

  /// The direction of the shimmer animation.
  final ShimmerDirection direction;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
    this.direction = ShimmerDirection.ltr,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _baseColor => widget.baseColor ?? AppColors.gray200;
  Color get _highlightColor => widget.highlightColor ?? AppColors.gray100;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return _createGradient(bounds).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  LinearGradient _createGradient(Rect bounds) {
    final begin = widget.direction == ShimmerDirection.ltr
        ? Alignment(-1.0 + _animation.value, 0.0)
        : Alignment(1.0 - _animation.value, 0.0);
    final end = widget.direction == ShimmerDirection.ltr
        ? Alignment(_animation.value, 0.0)
        : Alignment(-_animation.value, 0.0);

    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        _baseColor,
        _highlightColor,
        _baseColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}

/// The direction of the shimmer animation.
enum ShimmerDirection {
  /// Left to right shimmer animation.
  ltr,

  /// Right to left shimmer animation.
  rtl,
}

/// A modern gradient shimmer loading widget.
///
/// This creates a more vibrant shimmer effect using the app's primary gradient colors.
class GradientShimmer extends StatefulWidget {
  /// The child widget to apply the shimmer effect to.
  final Widget child;

  /// The gradient colors for the shimmer effect.
  final List<Color>? gradientColors;

  /// Duration of one shimmer animation cycle.
  final Duration duration;

  /// Whether the shimmer animation is enabled.
  final bool enabled;

  const GradientShimmer({
    super.key,
    required this.child,
    this.gradientColors,
    this.duration = const Duration(milliseconds: 1800),
    this.enabled = true,
  });

  @override
  State<GradientShimmer> createState() => _GradientShimmerState();
}

class _GradientShimmerState extends State<GradientShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(GradientShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _gradientColors =>
      widget.gradientColors ??
      [
        AppColors.purple600.withOpacity(0.1),
        AppColors.pink600.withOpacity(0.2),
        AppColors.purple600.withOpacity(0.1),
      ];

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + _animation.value, -0.3),
              end: Alignment(_animation.value, 0.3),
              colors: _gradientColors,
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// A helper widget for animating based on animation value.
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder_(
      animation: animation,
      builder: builder,
    );
  }
}

class AnimatedBuilder_ extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder_({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
