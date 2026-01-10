import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import 'shimmer_loading.dart' show AnimatedBuilder;

/// A loading indicator widget with gradient styling.
///
/// This widget provides various loading indicator styles including
/// circular progress, linear progress, and pulsing animations.
///
/// Example usage:
/// ```dart
/// // Simple circular loader
/// AppLoader()
///
/// // Full screen loading overlay
/// AppLoader.fullScreen(message: 'Loading...')
///
/// // Linear progress indicator
/// AppLoader.linear(progress: 0.5)
/// ```
class AppLoader extends StatefulWidget {
  /// The size of the loader.
  final double size;

  /// The stroke width for circular loader.
  final double strokeWidth;

  /// Custom gradient colors.
  final List<Color>? gradientColors;

  /// Loading message to display.
  final String? message;

  /// Whether to show as full screen overlay.
  final bool fullScreen;

  /// Whether to use pulsing animation.
  final bool pulsing;

  /// The type of loader to display.
  final LoaderType type;

  /// Progress value for linear loader (0.0 to 1.0).
  final double? progress;

  /// Background color for full screen overlay.
  final Color? backgroundColor;

  const AppLoader({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.gradientColors,
    this.message,
    this.fullScreen = false,
    this.pulsing = false,
    this.type = LoaderType.circular,
    this.progress,
    this.backgroundColor,
  });

  /// Creates a full screen loading overlay.
  const AppLoader.fullScreen({
    super.key,
    this.size = 48,
    this.strokeWidth = 3,
    this.gradientColors,
    this.message,
    this.pulsing = false,
    this.progress,
    this.backgroundColor,
  })  : fullScreen = true,
        type = LoaderType.circular;

  /// Creates a linear progress indicator.
  const AppLoader.linear({
    super.key,
    this.gradientColors,
    this.progress,
    this.message,
  })  : size = 40,
        strokeWidth = 4,
        fullScreen = false,
        pulsing = false,
        type = LoaderType.linear,
        backgroundColor = null;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.pulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _gradientColors =>
      widget.gradientColors ?? [AppColors.purple600, AppColors.pink600];

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreen) {
      return _buildFullScreenLoader();
    }

    return _buildLoader();
  }

  Widget _buildFullScreenLoader() {
    return Container(
      color: widget.backgroundColor ?? AppColors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoader(),
              if (widget.message != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.message!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    switch (widget.type) {
      case LoaderType.circular:
        return _buildCircularLoader();
      case LoaderType.linear:
        return _buildLinearLoader();
      case LoaderType.dots:
        return _buildDotsLoader();
    }
  }

  Widget _buildCircularLoader() {
    Widget loader = SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(_gradientColors.first),
      ),
    );

    // Add gradient effect using ShaderMask
    loader = ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: _gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        transform: const GradientRotation(0.5),
      ).createShader(bounds),
      child: loader,
    );

    if (widget.pulsing) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: loader,
          );
        },
      );
    }

    return loader;
  }

  Widget _buildLinearLoader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _gradientColors.first.withValues(alpha: 0.2),
                  _gradientColors.last.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: widget.progress != null
                ? FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.progress!.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _gradientColors),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : LinearProgressIndicator(
                    backgroundColor: AppColors.transparent,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_gradientColors.first),
                  ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDotsLoader() {
    return _DotsLoader(
      size: widget.size / 3,
      color: _gradientColors.first,
    );
  }
}

/// Type of loader to display.
enum LoaderType {
  circular,
  linear,
  dots,
}

/// A dots loading indicator.
class _DotsLoader extends StatefulWidget {
  final double size;
  final Color color;

  const _DotsLoader({
    required this.size,
    required this.color,
  });

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start animations with staggered delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              margin: EdgeInsets.symmetric(horizontal: widget.size / 4),
              decoration: BoxDecoration(
                color: widget.color.withValues(
                  alpha: 0.3 + (_animations[index].value * 0.7),
                ),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
