import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Loading skeleton for profile screen.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: const _HeaderSkeleton()),
        SliverPadding(
          padding: EdgeInsets.all(context.dynamicWidth(0.051)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _SectionTitleSkeleton(),
              SizedBox(height: context.dynamicHeight(0.015)),
              const _UserTypeCardSkeleton(),
              SizedBox(height: context.dynamicHeight(0.03)),
              const _SectionTitleSkeleton(),
              SizedBox(height: context.dynamicHeight(0.015)),
              const _InfoCardSkeleton(),
              SizedBox(height: context.dynamicHeight(0.03)),
              const _SectionTitleSkeleton(),
              SizedBox(height: context.dynamicHeight(0.015)),
              const _ActionsCardSkeleton(),
              SizedBox(height: context.dynamicHeight(0.119)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppBarSkeleton(),
            _UserInfoSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _AppBarSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.051),
        vertical: context.dynamicHeight(0.015),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Spacer(),
          ShimmerLoading(
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
            child: Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _UserInfoSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.dynamicWidth(0.061),
        context.dynamicHeight(0.02),
        context.dynamicWidth(0.061),
        context.dynamicHeight(0.039),
      ),
      child: Column(
        children: [
          ShimmerLoading(
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
            child: Container(
              width: context.dynamicWidth(0.4),
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          ShimmerLoading(
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
            child: Container(
              width: context.dynamicWidth(0.501),
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
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
        ],
      ),
    );
  }
}

class _SectionTitleSkeleton extends StatelessWidget {
  const _SectionTitleSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SkeletonBox(
        width: context.dynamicWidth(0.349),
        height: 22,
        borderRadius: 6,
      ),
    );
  }
}

class _UserTypeCardSkeleton extends StatelessWidget {
  const _UserTypeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _UserTypeOptionSkeleton(),
            Divider(
              color: AppColors.gray100,
              height: context.dynamicHeight(0.02),
            ),
            _UserTypeOptionSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _UserTypeOptionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.dynamicHeight(0.015),
        horizontal: context.dynamicWidth(0.021),
      ),
      child: Row(
        children: [
          SkeletonBox(
            width: context.dynamicWidth(0.12),
            height: context.dynamicWidth(0.12),
            borderRadius: context.dynamicWidth(0.029),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: context.dynamicWidth(0.301),
                  height: 18,
                  borderRadius: 4,
                ),
                SizedBox(height: context.dynamicHeight(0.005)),
                SkeletonBox(
                  width: context.dynamicWidth(0.501),
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCardSkeleton extends StatelessWidget {
  const _InfoCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _InfoRowSkeleton(),
            Divider(
              color: AppColors.gray100,
              height: context.dynamicHeight(0.025),
            ),
            _InfoRowSkeleton(),
            Divider(
              color: AppColors.gray100,
              height: context.dynamicHeight(0.025),
            ),
            _InfoRowSkeleton(),
            Divider(
              color: AppColors.gray100,
              height: context.dynamicHeight(0.025),
            ),
            _InfoRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(
          width: context.dynamicWidth(0.101),
          height: context.dynamicWidth(0.101),
          borderRadius: context.dynamicWidth(0.024),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: context.dynamicWidth(0.2),
                height: 14,
                borderRadius: 4,
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              SkeletonBox(
                width: context.dynamicWidth(0.451),
                height: 18,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionsCardSkeleton extends StatelessWidget {
  const _ActionsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _ActionItemSkeleton(),
            Divider(color: AppColors.gray100, height: 1),
            _ActionItemSkeleton(),
            Divider(color: AppColors.gray100, height: 1),
            _ActionItemSkeleton(),
            Divider(color: AppColors.gray100, height: 1),
            _ActionItemSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _ActionItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Row(
        children: [
          SkeletonBox(
            width: context.dynamicWidth(0.056),
            height: context.dynamicWidth(0.056),
            borderRadius: 6,
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: SkeletonBox(
              width: context.dynamicWidth(0.349),
              height: 18,
              borderRadius: 4,
            ),
          ),
          SkeletonBox(
            width: context.dynamicWidth(0.04),
            height: context.dynamicWidth(0.04),
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
