import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../utils/app_colors.dart';
import 'shimmer_loading.dart' show AnimatedBuilder;

/// A modern scanning indicator widget with gradient animation.
///
/// This widget creates a scanning effect commonly used in QR code scanners
/// and other scanning interfaces.
class ScanningIndicator extends StatefulWidget {
  /// The size of the indicator.
  final double size;

  /// The gradient colors for the scanning effect.
  final List<Color>? gradientColors;

  /// Whether the scanning animation is active.
  final bool isScanning;

  /// The message to display below the indicator.
  final String? message;

  const ScanningIndicator({
    super.key,
    this.size = 200,
    this.gradientColors,
    this.isScanning = true,
    this.message,
  });

  @override
  State<ScanningIndicator> createState() => _ScanningIndicatorState();
}

class _ScanningIndicatorState extends State<ScanningIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _scanLineController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    if (widget.isScanning) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(ScanningIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _scanLineController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _rotationController.stop();
    _pulseController.stop();
    _scanLineController.stop();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  List<Color> get _gradientColors =>
      widget.gradientColors ?? [AppColors.purple600, AppColors.pink600];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isScanning ? _pulseAnimation.value : 1.0,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    _buildRotatingRing(),
                    // Inner scanning area
                    _buildScanningArea(),
                    // Center icon
                    _buildCenterIcon(),
                    // Scan line
                    if (widget.isScanning) _buildScanLine(),
                  ],
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 24),
          _buildMessage(),
        ],
      ],
    );
  }

  Widget _buildRotatingRing() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RotatingRingPainter(
              gradientColors: _gradientColors,
              strokeWidth: 4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanningArea() {
    return Container(
      width: widget.size * 0.75,
      height: widget.size * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _gradientColors.first.withOpacity(0.3),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _gradientColors.first.withOpacity(0.05),
            _gradientColors.last.withOpacity(0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterIcon() {
    return Container(
      width: widget.size * 0.35,
      height: widget.size * 0.35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientColors.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.qr_code_scanner,
        color: Colors.white,
        size: widget.size * 0.18,
      ),
    );
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        return Positioned(
          top: widget.size * 0.125 + (_scanLineAnimation.value * widget.size * 0.75),
          left: widget.size * 0.125,
          right: widget.size * 0.125,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _gradientColors.first,
                  _gradientColors.last,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _gradientColors.first.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage() {
    return AnimatedOpacity(
      opacity: widget.isScanning ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return _AnimatedDot(
                delay: Duration(milliseconds: index * 200),
                color: _gradientColors.first,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RotatingRingPainter extends CustomPainter {
  final List<Color> gradientColors;
  final double strokeWidth;

  _RotatingRingPainter({
    required this.gradientColors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final gradient = SweepGradient(
      colors: [
        gradientColors.first.withOpacity(0.0),
        gradientColors.first,
        gradientColors.last,
        gradientColors.last.withOpacity(0.0),
      ],
      stops: const [0.0, 0.25, 0.75, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedDot extends StatefulWidget {
  final Duration delay;
  final Color color;

  const _AnimatedDot({
    required this.delay,
    required this.color,
  });

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
