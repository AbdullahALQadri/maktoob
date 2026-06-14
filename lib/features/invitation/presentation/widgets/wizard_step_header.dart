import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';

/// Flat white wizard step header with thin progress bar.
///
/// The back button now lives in the app bar above this widget; this header
/// focuses on progress indication only.
class WizardStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;

  const WizardStepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    final l = AppLocalizations.of(context);
    final stepText = l != null
        ? '${l.translate('wizard_step')} $currentStep ${l.translate('wizard_of')} $totalSteps'
        : 'الخطوة $currentStep من $totalSteps';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.05),
        vertical: context.dynamicHeight(0.018),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                stepText,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: context.dynamicWidth(0.033),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: context.dynamicWidth(0.033),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.012)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1).toDouble(),
              minHeight: 6,
              backgroundColor: AppColors.gray200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
