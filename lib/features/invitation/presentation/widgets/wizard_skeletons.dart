import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Skeleton placeholders for the event-creation wizard.
///
/// All use the shared [SkeletonBox] + [ShimmerLoading] house style so loading
/// states match the rest of the app (warm-paper shimmer) instead of a bare
/// spinner.

/// Generic form-page skeleton (title + subtitle + a few fields + action).
/// Shown while the wizard initialises before the first page renders.
class WizardFormSkeleton extends StatelessWidget {
  const WizardFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceBg,
      child: SafeArea(
        child: ShimmerLoading(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 180, height: 26, borderRadius: 8),
                const SizedBox(height: 10),
                const SkeletonBox(width: 240, height: 14, borderRadius: 6),
                const SizedBox(height: 28),
                for (var i = 0; i < 3; i++) ...[
                  const SkeletonBox(width: 110, height: 13, borderRadius: 6),
                  const SizedBox(height: 8),
                  const SkeletonBox(
                    width: double.infinity,
                    height: 52,
                    borderRadius: 14,
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 8),
                const SkeletonBox(
                  width: double.infinity,
                  height: 54,
                  borderRadius: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A list of service-row placeholders (icon + 2 lines + trailing toggle).
class ServicesListSkeleton extends StatelessWidget {
  final int count;
  const ServicesListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        padding: const EdgeInsetsDirectional.all(16),
        itemCount: count,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsetsDirectional.only(bottom: 12),
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              const SkeletonBox.circle(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(width: 140, height: 14, borderRadius: 6),
                    SizedBox(height: 8),
                    SkeletonBox(width: 80, height: 12, borderRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SkeletonBox(width: 46, height: 26, borderRadius: 13),
            ],
          ),
        ),
      ),
    );
  }
}

/// A list of package-card placeholders.
class PackageListSkeleton extends StatelessWidget {
  final int count;
  const PackageListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            Container(
              margin: const EdgeInsetsDirectional.only(bottom: 10),
              padding: const EdgeInsetsDirectional.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                children: [
                  const SkeletonBox(width: 44, height: 44, borderRadius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(width: 120, height: 15, borderRadius: 6),
                        SizedBox(height: 8),
                        SkeletonBox(width: 180, height: 12, borderRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SkeletonBox(width: 56, height: 24, borderRadius: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Invoice-summary placeholder (rows + total) for the review page.
class InvoiceSummarySkeleton extends StatelessWidget {
  const InvoiceSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row({double labelW = 130}) => Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: labelW, height: 14, borderRadius: 6),
              const SkeletonBox(width: 70, height: 14, borderRadius: 6),
            ],
          ),
        );

    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          row(labelW: 150),
          row(labelW: 110),
          row(labelW: 170),
          const SizedBox(height: 8),
          const SkeletonBox(width: double.infinity, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonBox(width: 80, height: 20, borderRadius: 6),
              SkeletonBox(width: 110, height: 26, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}
