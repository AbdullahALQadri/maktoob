import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class StepHeaderWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepHeaderWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
            AppColors.rose600,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Animated background circle
            Positioned(
              top: -context.dynamicWidth(0.051),
              right: -context.dynamicWidth(0.051),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.5),
                duration: const Duration(seconds: 10),
                builder: (context, value, child) {
                  return Container(
                    width: context.dynamicWidth(0.4),
                    height: context.dynamicWidth(0.4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.dynamicWidth(0.061),
                context.dynamicHeight(0.025),
                context.dynamicWidth(0.061),
                context.dynamicHeight(0.039),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.029),
                      vertical: context.dynamicHeight(0.007),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: context.dynamicWidth(0.035),
                          color: Colors.white,
                        ),
                        SizedBox(width: context.dynamicWidth(0.016)),
                        Text(
                          'Step $currentStep of $totalSteps',
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.029),
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  Text(
                    'Create Event',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.069),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.005)),
                  Text(
                    "Let's make something amazing",
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.035),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.03)),
                  // Progress bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: context.dynamicWidth(0.029),
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: context.dynamicWidth(0.029),
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.dynamicHeight(0.01)),
                  Container(
                    height: context.dynamicHeight(0.01),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: constraints.maxWidth * progress,
                            height: context.dynamicHeight(0.01),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
