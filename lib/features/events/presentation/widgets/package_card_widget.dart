import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/event_models.dart';

class PackageSelectionWidget extends StatelessWidget {
  final List<PackageModel> packages;
  final String? selectedPackage;
  final Function(String) onPackageSelected;

  const PackageSelectionWidget({
    super.key,
    required this.packages,
    required this.selectedPackage,
    required this.onPackageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Package',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: 16.h),
        ...packages.asMap().entries.map((entry) {
          final index = entry.key;
          final pkg = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: _PackageCard(
              package: pkg,
              isSelected: selectedPackage == pkg.id,
              onTap: () => onPackageSelected(pkg.id),
            ),
          );
        }),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(19.w),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: package.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(23.w),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? package.gradientColors.first.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (package.recommended)
              Positioned(
                top: -28.h,
                right: 19.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                    ),
                    borderRadius: BorderRadius.circular(19.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '⭐ ',
                        style: TextStyle(fontSize: 9.sp),
                      ),
                      Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : null,
                        gradient: isSelected
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: package.gradientColors,
                              ),
                        borderRadius: BorderRadius.circular(15.w),
                      ),
                      child: Icon(
                        package.icon,
                        color: Colors.white,
                        size: 23.w,
                      ),
                    ),
                    SizedBox(width: 11.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.gray900,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Up to ${package.invitationsDisplay} invitations',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${package.price}',
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ...package.features.map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 19.w,
                        height: 19.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.green100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 11.w,
                          color: isSelected ? Colors.white : AppColors.green600,
                        ),
                      ),
                      SizedBox(width: 9.w),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
