import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/stat_entity.dart';

/// Stat tile — editorial mockup layout.
///
/// Fixed 128pt height, subtle 4pt radius, 1px warm-sand border. Inside:
/// gold icon top-left, then big number + small label bottom-aligned via
/// flex space-between. Entity's `gradientColors` / `bgColor` are ignored.
class StatCardWidget extends StatelessWidget {
  final StatEntity stat;
  final int index;

  const StatCardWidget({
    super.key,
    required this.stat,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return StaggeredSlideFade(
      index: index,
      staggerMs: 80,
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          border: Border.all(color: AppColors.gray200),
        ),
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              stat.icon,
              size: 24,
              color: AppColors.primaryColor,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    stat.value,
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  style: text.labelMedium?.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
