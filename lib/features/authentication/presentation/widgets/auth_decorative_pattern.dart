import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Decorative background pattern for auth screens.
class AuthDecorativePattern extends StatelessWidget {
  const AuthDecorativePattern({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top right decorative circle
        Positioned(
          top: -context.dynamicWidth(0.349),
          right: -context.dynamicWidth(0.251),
          child: _Circle(
            size: context.dynamicWidth(0.8),
            isBorder: true,
          ),
        ),
        // Bottom left decorative circle
        Positioned(
          bottom: -context.dynamicWidth(0.2),
          left: -context.dynamicWidth(0.301),
          child: _Circle(
            size: context.dynamicWidth(0.6),
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        // Small accent circles
        Positioned(
          top: context.dynamicHeight(0.15),
          left: context.dynamicWidth(0.101),
          child: const _Circle(size: 12, opacity: 0.3),
        ),
        Positioned(
          top: context.dynamicHeight(0.25),
          right: context.dynamicWidth(0.149),
          child: const _Circle(size: 8, opacity: 0.2),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final bool isBorder;
  final Color? color;
  final double opacity;

  const _Circle({
    required this.size,
    this.isBorder = false,
    this.color,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isBorder ? null : (color ?? Colors.white.withValues(alpha: opacity)),
        border: isBorder
            ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5)
            : null,
      ),
    );
  }
}
