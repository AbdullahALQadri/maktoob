import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import 'banner_mood.dart';
import 'mood_ornaments.dart';

/// The hero banner surface of the web dashboards (`.mk-mood`): the mood's
/// gradient, a corner glow, a dot texture and the star ornament. Content is
/// white; the main button on it is white with the mood's ink.
class MoodBanner extends StatelessWidget {
  const MoodBanner({
    super.key,
    required this.mood,
    required this.child,
    this.padding = const EdgeInsetsDirectional.all(20),
  });

  final BannerMood mood;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [mood.from, mood.via, mood.to],
                  stops: const [0, .52, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: AlignmentDirectional.topEnd,
                  radius: 1.1,
                  colors: [mood.glow, mood.glow.withValues(alpha: 0)],
                  stops: const [0, .48],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: MoodDotsPainter())),
          ),
          PositionedDirectional(
            bottom: -70,
            end: -70,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: CustomPaint(size: const Size.square(280), painter: MoodStarPainter(mood.accent)),
            ),
          ),
          // The web sinks the mood into the navy night in dark mode.
          if (dark) Positioned.fill(child: ColoredBox(color: AppColors.darkBg.withValues(alpha: .28))),
          Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: AppColors.white),
              child: IconTheme.merge(
                data: const IconThemeData(color: AppColors.white),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mood of the hour · name": the small chip at the top of a banner.
class MoodChip extends StatelessWidget {
  const MoodChip({super.key, required this.mood, required this.label});

  final BannerMood mood;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: .1),
        border: Border.all(color: AppColors.white.withValues(alpha: .18)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: mood.accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: mood.accent, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
