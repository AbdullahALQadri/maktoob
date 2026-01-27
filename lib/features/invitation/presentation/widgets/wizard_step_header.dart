import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../cubit/invitation_cubit.dart';

/// Header widget for wizard steps showing progress
class WizardStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final String? titleAr;
  final String? subtitle;
  final String? subtitleAr;
  final VoidCallback? onBack;
  final bool showBackButton;

  const WizardStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    this.titleAr,
    this.subtitle,
    this.subtitleAr,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    final localizations = AppLocalizations.of(context);
    final stepText = localizations != null
        ? '${localizations.translate('wizard_step')} $currentStep ${localizations.translate('wizard_of')} $totalSteps'
        : 'Step $currentStep of $totalSteps';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 19.w,
        vertical: 20.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and Step indicator in same row
            Row(
              children: [
                // Back button
                if (showBackButton) ...[
                  GestureDetector(
                    onTap: onBack ?? () {
                      if (currentStep == 1) {
                        // First step - close the wizard
                        Navigator.of(context).pop();
                      } else {
                        // Go to previous step
                        context.read<InvitationCubit>().previousStep();
                      }
                    },
                    child: Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 19.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                ],
                // Step indicator
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(19.w),
                  ),
                  child: Text(
                    stepText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Title
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 23.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13.sp,
                ),
              ),
            ],

            SizedBox(height: 16.h),

            // Progress bar
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: constraints.maxWidth * progress,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact step indicator for bottom bar
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isCurrent = index == currentStep - 1;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isCurrent ? 23.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isActive || isCurrent
                ? AppColors.primaryColor
                : AppColors.gray300,
            borderRadius: BorderRadius.circular(4.w),
          ),
        );
      }),
    );
  }
}
