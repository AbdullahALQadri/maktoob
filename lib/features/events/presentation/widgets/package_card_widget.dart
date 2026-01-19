import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
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
            fontSize: context.dynamicWidth(0.05),
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
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
        margin: EdgeInsets.only(bottom: context.dynamicHeight(0.015)),
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: package.gradientColors,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.06)),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? package.gradientColors.first.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
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
                top: -context.dynamicHeight(0.035),
                right: context.dynamicWidth(0.05),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.03),
                    vertical: context.dynamicHeight(0.008),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                    ),
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
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
                        style: TextStyle(fontSize: context.dynamicWidth(0.025)),
                      ),
                      Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: context.dynamicWidth(0.028),
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
                      width: context.dynamicWidth(0.12),
                      height: context.dynamicWidth(0.12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : null,
                        gradient: isSelected
                            ? null
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: package.gradientColors,
                              ),
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                      ),
                      child: Icon(
                        package.icon,
                        color: Colors.white,
                        size: context.dynamicWidth(0.06),
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(0.03)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.045),
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.gray900,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(0.003)),
                          Text(
                            'Up to ${package.invitationsDisplay} invitations',
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.03),
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${package.price}',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.07),
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.dynamicHeight(0.02)),
                ...package.features.map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: context.dynamicHeight(0.01)),
                  child: Row(
                    children: [
                      Container(
                        width: context.dynamicWidth(0.05),
                        height: context.dynamicWidth(0.05),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.green100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: context.dynamicWidth(0.03),
                          color: isSelected ? Colors.white : AppColors.green600,
                        ),
                      ),
                      SizedBox(width: context.dynamicWidth(0.025)),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: context.dynamicWidth(0.035),
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
