import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import 'shimmer_loading.dart';

/// Base skeleton box widget for building custom skeleton layouts.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? margin;
  final Color? color;
  final bool isCircle;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
    this.color,
    this.isCircle = false,
  });

  /// Creates a circular skeleton.
  const SkeletonBox.circle({
    super.key,
    required double size,
    this.margin,
    this.color,
  })  : width = size,
        height = size,
        borderRadius = 0,
        isCircle = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? context.borderColor,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

/// Skeleton widget for stat cards (used in HomeScreen).
class StatCardSkeleton extends StatelessWidget {
  final int index;

  const StatCardSkeleton({super.key, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeletonBox(
              width: 36,
              height: 36,
              borderRadius: 10,
            ),
            const SizedBox(height: 8),
            SkeletonBox(
              width: 50,
              height: 22,
              borderRadius: 4,
            ),
            const SizedBox(height: 4),
            SkeletonBox(
              width: 70,
              height: 12,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton widget for the stats grid in HomeScreen.
class StatsGridSkeleton extends StatelessWidget {
  const StatsGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return StatCardSkeleton(index: index);
        },
      ),
    );
  }
}

/// Skeleton widget for recent event cards in HomeScreen.
class RecentEventCardSkeleton extends StatelessWidget {
  const RecentEventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Event icon skeleton
            SkeletonBox(
              width: 56,
              height: 56,
              borderRadius: 16,
            ),
            const SizedBox(width: 16),
            // Event details skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 150,
                    height: 18,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    width: 100,
                    height: 14,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SkeletonBox(
                        width: 60,
                        height: 20,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 8),
                      SkeletonBox(
                        width: 80,
                        height: 14,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow skeleton
            SkeletonBox(
              width: 32,
              height: 32,
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton widget for the response rate card in HomeScreen.
class ResponseRateCardSkeleton extends StatelessWidget {
  const ResponseRateCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(
                  width: 120,
                  height: 20,
                  borderRadius: 4,
                ),
                SkeletonBox(
                  width: 60,
                  height: 28,
                  borderRadius: 6,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SkeletonBox(
              width: double.infinity,
              height: 8,
              borderRadius: 4,
            ),
            const SizedBox(height: 12),
            SkeletonBox(
              width: 180,
              height: 14,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full home screen loading skeleton.
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.7),
                  AppColors.tertiaryColor.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShimmerLoading(
                        baseColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.4),
                        child: Container(
                          width: 120,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ShimmerLoading(
                        baseColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.4),
                        child: Container(
                          width: 200,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Stats grid skeleton - overlapping header
          Transform.translate(
            offset: const Offset(0, -60),
            child: const StatsGridSkeleton(),
          ),
          // Response rate card skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ResponseRateCardSkeleton(),
          ),
          const SizedBox(height: 24),
          // Recent events section skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLoading(
                      child: SkeletonBox(
                        width: 130,
                        height: 24,
                        borderRadius: 6,
                      ),
                    ),
                    ShimmerLoading(
                      child: SkeletonBox(
                        width: 80,
                        height: 20,
                        borderRadius: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const RecentEventCardSkeleton(),
                const RecentEventCardSkeleton(),
                const RecentEventCardSkeleton(),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

/// Skeleton widget for event list items (used in EventsScreen).
class EventListItemSkeleton extends StatelessWidget {
  const EventListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card header skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  SkeletonBox(
                    width: 48,
                    height: 48,
                    borderRadius: 14,
                    color: context.borderColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          width: 150,
                          height: 20,
                          borderRadius: 4,
                          color: context.borderColor,
                        ),
                        const SizedBox(height: 8),
                        SkeletonBox(
                          width: 80,
                          height: 24,
                          borderRadius: 12,
                          color: context.borderColor,
                        ),
                      ],
                    ),
                  ),
                  SkeletonBox(
                    width: 70,
                    height: 28,
                    borderRadius: 20,
                    color: context.borderColor,
                  ),
                ],
              ),
            ),
            // Card body skeleton
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRowSkeleton(),
                  const SizedBox(height: 8),
                  _buildInfoRowSkeleton(),
                  const SizedBox(height: 8),
                  _buildInfoRowSkeleton(),
                  const SizedBox(height: 16),
                  // Progress bar skeleton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(
                        width: 100,
                        height: 14,
                        borderRadius: 4,
                      ),
                      SkeletonBox(
                        width: 40,
                        height: 14,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    width: double.infinity,
                    height: 8,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 16),
                  // Stats row skeleton
                  Row(
                    children: [
                      Expanded(child: _buildStatSkeleton()),
                      Container(width: 1, height: 40, color: context.borderColor),
                      Expanded(child: _buildStatSkeleton()),
                    ],
                  ),
                ],
              ),
            ),
            // Card footer skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.overlayBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SkeletonBox(
                width: double.infinity,
                height: 48,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowSkeleton() {
    return Row(
      children: [
        const SkeletonBox.circle(size: 18),
        const SizedBox(width: 10),
        SkeletonBox(
          width: 180,
          height: 14,
          borderRadius: 4,
        ),
      ],
    );
  }

  Widget _buildStatSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SkeletonBox.circle(size: 10),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: 30,
              height: 18,
              borderRadius: 4,
            ),
            const SizedBox(height: 4),
            SkeletonBox(
              width: 50,
              height: 12,
              borderRadius: 4,
            ),
          ],
        ),
      ],
    );
  }
}

/// Full events screen loading skeleton.
class EventsScreenSkeleton extends StatelessWidget {
  final int itemCount;

  const EventsScreenSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const EventListItemSkeleton();
      },
    );
  }
}

/// Skeleton widget for venue cards (used in VenueScreen).
class VenueCardSkeleton extends StatelessWidget {
  const VenueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Venue icon skeleton
            SkeletonBox(
              width: 60,
              height: 60,
              borderRadius: 16,
            ),
            const SizedBox(width: 16),
            // Venue details skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 140,
                    height: 18,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    width: 200,
                    height: 14,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SkeletonBox(
                        width: 80,
                        height: 24,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 8),
                      SkeletonBox(
                        width: 60,
                        height: 24,
                        borderRadius: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow skeleton
            const SkeletonBox.circle(size: 32),
          ],
        ),
      ),
    );
  }
}

/// Full venues screen loading skeleton.
class VenuesScreenSkeleton extends StatelessWidget {
  final int itemCount;

  const VenuesScreenSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const VenueCardSkeleton();
      },
    );
  }
}

/// Skeleton widget for event details screen.
class EventDetailsSkeleton extends StatelessWidget {
  const EventDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.7),
                  AppColors.tertiaryColor.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerLoading(
                          baseColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.4),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const Spacer(),
                        ShimmerLoading(
                          baseColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.4),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Row(
                        children: [
                          ShimmerLoading(
                            baseColor: Colors.white.withValues(alpha: 0.2),
                            highlightColor: Colors.white.withValues(alpha: 0.4),
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShimmerLoading(
                                    baseColor:
                                        Colors.white.withValues(alpha: 0.2),
                                    highlightColor:
                                        Colors.white.withValues(alpha: 0.4),
                                    child: Container(
                                      width: 180,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ShimmerLoading(
                                        baseColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        highlightColor: Colors.white
                                            .withValues(alpha: 0.4),
                                        child: Container(
                                          width: 70,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ShimmerLoading(
                                        baseColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        highlightColor: Colors.white
                                            .withValues(alpha: 0.4),
                                        child: Container(
                                          width: 60,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Quick stats skeleton
          const _QuickStatsSkeleton(),
          // Tab bar skeleton
          const _TabBarSkeleton(),
          // Content skeleton
          const _EventContentSkeleton(),
        ],
      ),
    );
  }
}

class _QuickStatsSkeleton extends StatelessWidget {
  const _QuickStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Column(
                children: [
                  const SkeletonBox.circle(size: 40),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    width: 40,
                    height: 24,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 4),
                  SkeletonBox(
                    width: 60,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarSkeleton extends StatelessWidget {
  const _TabBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 44,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: index == 0 ? context.borderColor : AppColors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventContentSkeleton extends StatelessWidget {
  const _EventContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Info card skeleton
          ShimmerLoading(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gray300.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonBox(
                        width: 40,
                        height: 40,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      SkeletonBox(
                        width: 140,
                        height: 20,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRowSkeleton(),
                  const SizedBox(height: 16),
                  _buildInfoRowSkeleton(),
                  const SizedBox(height: 16),
                  _buildInfoRowSkeleton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Analytics card skeleton
          ShimmerLoading(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gray300.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonBox(
                        width: 40,
                        height: 40,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      SkeletonBox(
                        width: 150,
                        height: 20,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildProgressSkeleton(),
                  const SizedBox(height: 16),
                  _buildProgressSkeleton(),
                  const SizedBox(height: 16),
                  _buildProgressSkeleton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowSkeleton() {
    return Row(
      children: [
        SkeletonBox(
          width: 40,
          height: 40,
          borderRadius: 10,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: 60,
                height: 12,
                borderRadius: 4,
              ),
              const SizedBox(height: 4),
              SkeletonBox(
                width: 150,
                height: 14,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SkeletonBox(
              width: 80,
              height: 14,
              borderRadius: 4,
            ),
            SkeletonBox(
              width: 100,
              height: 12,
              borderRadius: 4,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SkeletonBox(
          width: double.infinity,
          height: 10,
          borderRadius: 5,
        ),
      ],
    );
  }
}

/// Skeleton for QR scanner stats cards.
class ScannerStatsSkeleton extends StatelessWidget {
  const ScannerStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: ShimmerLoading(
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == 2 ? 0 : 6,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gray300.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SkeletonBox.circle(size: 44),
                  const SizedBox(height: 12),
                  SkeletonBox(
                    width: 40,
                    height: 28,
                    borderRadius: 6,
                  ),
                  const SizedBox(height: 4),
                  SkeletonBox(
                    width: 60,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton for upload area in PaymentUploadScreen.
class UploadAreaSkeleton extends StatelessWidget {
  const UploadAreaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.borderColor,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const SkeletonBox.circle(size: 64),
            const SizedBox(height: 16),
            SkeletonBox(
              width: 160,
              height: 18,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),
            SkeletonBox(
              width: 200,
              height: 14,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bank details card skeleton for PaymentUploadScreen.
class BankDetailsCardSkeleton extends StatelessWidget {
  const BankDetailsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray300.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(
                  width: 40,
                  height: 40,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                SkeletonBox(
                  width: 120,
                  height: 20,
                  borderRadius: 4,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRowSkeleton(),
            const SizedBox(height: 12),
            _buildDetailRowSkeleton(),
            const SizedBox(height: 12),
            _buildDetailRowSkeleton(),
            const SizedBox(height: 12),
            _buildDetailRowSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRowSkeleton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonBox(
            width: 80,
            height: 14,
            borderRadius: 4,
          ),
          SkeletonBox(
            width: 120,
            height: 14,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
