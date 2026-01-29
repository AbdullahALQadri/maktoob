import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/golden_package_model.dart';

/// Package card widget for Golden Scenario
class GoldenPackageCard extends StatelessWidget {
  final GoldenPackageModel package;
  final bool isSelected;
  final VoidCallback? onTap;

  const GoldenPackageCard({
    super.key,
    required this.package,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.width;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(screenWidth * 0.045),
            decoration: BoxDecoration(
              color: isSelected ? null : Colors.white,
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: package.gradientColors,
                    )
                  : null,
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              border: isSelected
                  ? null
                  : Border.all(color: context.borderColor, width: 1.5),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: package.gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Emoji
                    Text(
                      package.emoji,
                      style: TextStyle(fontSize: screenWidth * 0.08),
                    ),
                    SizedBox(width: screenWidth * 0.03),

                    // Name and price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : context.textPrimary,
                            ),
                          ),
                          Text(
                            package.nameAr,
                            style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : context.iconSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          package.isFree ? 'Free' : '${package.price}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.primaryColor,
                          ),
                        ),
                        if (!package.isFree)
                          Text(
                            'ILS',
                            style: TextStyle(
                              fontSize: screenWidth * 0.028,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : context.iconDefault,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: screenWidth * 0.04),

                // Features list
                ...package.features.map((feature) => Padding(
                      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : AppColors.green600.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: screenWidth * 0.03,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.green600,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.025),
                          Text(
                            feature,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : context.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )),

                // Selection indicator
                if (isSelected)
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // "Most Chosen" badge
          if (package.isHighlighted)
            Positioned(
              top: -screenWidth * 0.03,
              right: screenWidth * 0.04,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber500,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber500.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⭐',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'Most Chosen',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
