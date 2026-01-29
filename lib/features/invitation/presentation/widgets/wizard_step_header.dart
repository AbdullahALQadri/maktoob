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
        horizontal: context.dynamicWidth(0.051),
        vertical: context.dynamicHeight(0.025),
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
                      width: context.dynamicWidth(0.091),
                      height: context.dynamicWidth(0.091),
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
                        size: context.dynamicWidth(0.051),
                      ),
                    ),
                  ),
                  SizedBox(width: context.dynamicWidth(0.04)),
                ],
                // Step indicator
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.029),
                    vertical: context.dynamicHeight(0.007),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
                  ),
                  child: Text(
                    stepText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicWidth(0.029),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: context.dynamicWidth(0.029),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: context.dynamicHeight(0.02)),

            // Title
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.dynamicWidth(0.061),
                fontWeight: FontWeight.bold,
              ),
            ),

            if (subtitle != null) ...[
              SizedBox(height: context.dynamicHeight(0.005)),
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: context.dynamicWidth(0.035),
                ),
              ),
            ],

            SizedBox(height: context.dynamicHeight(0.02)),

            // Progress bar
            Container(
              height: context.dynamicHeight(0.007),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: constraints.maxWidth * progress,
                        height: context.dynamicHeight(0.007),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
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
          margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.011)),
          width: isCurrent ? context.dynamicWidth(0.061) : context.dynamicWidth(0.021),
          height: context.dynamicWidth(0.021),
          decoration: BoxDecoration(
            color: isActive || isCurrent
                ? AppColors.primaryColor
                : context.borderColor,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
          ),
        );
      }),
    );
  }
}
