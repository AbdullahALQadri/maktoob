import 'package:flutter/material.dart';

/// Keeps the whole app in a centred column on wide screens (tablets).
///
/// Phones are untouched. On a screen wider than [maxWidth] the app is drawn
/// [maxWidth] wide in the middle, with the scaffold colour on both sides.
/// [MediaQuery] is narrowed to the same width, so every screen that sizes
/// itself from `MediaQuery.sizeOf(context)` lays out for the column it is
/// actually drawn in.
class AppContentWidth extends StatelessWidget {
  const AppContentWidth({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= maxWidth) return child;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: maxWidth,
          child: MediaQuery(
            data: media.copyWith(size: Size(maxWidth, media.size.height)),
            child: ClipRect(child: child),
          ),
        ),
      ),
    );
  }
}
