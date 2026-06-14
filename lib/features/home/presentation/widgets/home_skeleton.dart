import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Loading skeleton for the redesigned home screen.
///
/// Mirrors the exact composition of [HomeScreen] so the layout doesn't
/// shift on first load:
///   - app bar (wordmark + 2 trailing icons)
///   - greeting block (title + subtitle)
///   - hero metric card
///   - 2x2 stats grid (128pt tall tiles)
///   - recent events section (first card photo-led, rest text-led)
///
/// All boxes use [ShimmerLoading] over a warm-sand base so it feels
/// like the paper surface gently waking up rather than a generic grey
/// pulse.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // No app-bar skeleton — HomeScreen's Scaffold already renders the
    // real _HomeAppBar; this widget only fills the body area.
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 24),
          _GreetingSkeleton(),
          SizedBox(height: 24),
          _HeroMetricSkeleton(),
          SizedBox(height: 24),
          _StatsGridSkeleton(),
          SizedBox(height: 32),
          _SectionHeaderSkeleton(),
          SizedBox(height: 16),
          _PhotoLedEventSkeleton(),
          _TextLedEventSkeleton(),
          _TextLedEventSkeleton(),
          SizedBox(height: 120),
        ],
      ),
    );
  }
}

// =============================================================================
//  building blocks
// =============================================================================

class _GreetingSkeleton extends StatelessWidget {
  const _GreetingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            child: SkeletonBox(
              width: 240,
              height: 30,
              borderRadius: 6,
              color: AppColors.gray200,
            ),
          ),
          SizedBox(height: 10),
          ShimmerLoading(
            child: SkeletonBox(
              width: 200,
              height: 14,
              borderRadius: 4,
              color: AppColors.gray200,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricSkeleton extends StatelessWidget {
  const _HeroMetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsetsDirectional.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.gray200),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        child: SkeletonBox(
                          width: 100,
                          height: 12,
                          borderRadius: 3,
                          color: AppColors.gray200,
                        ),
                      ),
                      SizedBox(height: 12),
                      ShimmerLoading(
                        child: SkeletonBox(
                          width: 140,
                          height: 52,
                          borderRadius: 6,
                          color: AppColors.gray200,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Padding(
                  padding: EdgeInsetsDirectional.only(bottom: 6),
                  child: ShimmerLoading(
                    child: SkeletonBox(
                      width: 70,
                      height: 16,
                      borderRadius: 4,
                      color: AppColors.gray200,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ShimmerLoading(
              child: SkeletonBox(
                width: double.infinity,
                height: 2,
                borderRadius: 1,
                color: AppColors.gray200,
              ),
            ),
            SizedBox(height: 14),
            ShimmerLoading(
              child: SkeletonBox(
                width: 220,
                height: 12,
                borderRadius: 3,
                color: AppColors.gray200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: _StatTileSkeleton()),
              SizedBox(width: 16),
              Expanded(child: _StatTileSkeleton()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _StatTileSkeleton()),
              SizedBox(width: 16),
              Expanded(child: _StatTileSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTileSkeleton extends StatelessWidget {
  const _StatTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsetsDirectional.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerLoading(
            child: SkeletonBox(
              width: 24,
              height: 24,
              borderRadius: 4,
              color: AppColors.gray200,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerLoading(
                child: SkeletonBox(
                  width: 60,
                  height: 24,
                  borderRadius: 4,
                  color: AppColors.gray200,
                ),
              ),
              SizedBox(height: 8),
              ShimmerLoading(
                child: SkeletonBox(
                  width: 90,
                  height: 12,
                  borderRadius: 3,
                  color: AppColors.gray200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerLoading(
            child: SkeletonBox(
              width: 150,
              height: 22,
              borderRadius: 6,
              color: AppColors.gray200,
            ),
          ),
          ShimmerLoading(
            child: SkeletonBox(
              width: 70,
              height: 14,
              borderRadius: 4,
              color: AppColors.gray200,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoLedEventSkeleton extends StatelessWidget {
  const _PhotoLedEventSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          border: Border.all(color: AppColors.gray200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(
              child: SkeletonBox(
                width: double.infinity,
                height: 128,
                borderRadius: 0,
                color: AppColors.gray100,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(
                    child: SkeletonBox(
                      width: 240,
                      height: 22,
                      borderRadius: 6,
                      color: AppColors.gray200,
                    ),
                  ),
                  SizedBox(height: 10),
                  ShimmerLoading(
                    child: SkeletonBox(
                      width: 160,
                      height: 14,
                      borderRadius: 4,
                      color: AppColors.gray200,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLoading(
                        child: SkeletonBox(
                          width: 100,
                          height: 12,
                          borderRadius: 3,
                          color: AppColors.gray200,
                        ),
                      ),
                      ShimmerLoading(
                        child: SkeletonBox(
                          width: 40,
                          height: 12,
                          borderRadius: 3,
                          color: AppColors.gray200,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  ShimmerLoading(
                    child: SkeletonBox(
                      width: double.infinity,
                      height: 1,
                      borderRadius: 0,
                      color: AppColors.gray200,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextLedEventSkeleton extends StatelessWidget {
  const _TextLedEventSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          border: Border.all(color: AppColors.gray200),
        ),
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerLoading(
              child: SkeletonBox(
                width: 70,
                height: 12,
                borderRadius: 3,
                color: AppColors.gray200,
              ),
            ),
            SizedBox(height: 8),
            ShimmerLoading(
              child: SkeletonBox(
                width: 260,
                height: 22,
                borderRadius: 6,
                color: AppColors.gray200,
              ),
            ),
            SizedBox(height: 10),
            ShimmerLoading(
              child: SkeletonBox(
                width: 160,
                height: 14,
                borderRadius: 4,
                color: AppColors.gray200,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerLoading(
                  child: SkeletonBox(
                    width: 100,
                    height: 12,
                    borderRadius: 3,
                    color: AppColors.gray200,
                  ),
                ),
                ShimmerLoading(
                  child: SkeletonBox(
                    width: 40,
                    height: 12,
                    borderRadius: 3,
                    color: AppColors.gray200,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            ShimmerLoading(
              child: SkeletonBox(
                width: double.infinity,
                height: 1,
                borderRadius: 0,
                color: AppColors.gray200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
