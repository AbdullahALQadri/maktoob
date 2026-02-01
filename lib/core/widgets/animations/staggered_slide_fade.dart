import 'package:flutter/material.dart';

/// A reusable staggered slide-and-fade entrance animation.
///
/// Animates the [child] by sliding it up from [slideOffset] pixels
/// while fading it in. The delay is computed as
/// [baseDelayMs] + ([index] * [staggerMs]) milliseconds.
class StaggeredSlideFade extends StatelessWidget {
  final int index;
  final Widget child;
  final int baseDelayMs;
  final int staggerMs;
  final double slideOffset;
  final Curve curve;

  const StaggeredSlideFade({
    super.key,
    required this.index,
    required this.child,
    this.baseDelayMs = 400,
    this.staggerMs = 80,
    this.slideOffset = 20,
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: baseDelayMs + (index * staggerMs)),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, slideOffset * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
