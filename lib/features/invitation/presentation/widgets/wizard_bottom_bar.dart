import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';

/// Reusable bottom bar for wizard screens with Back and Next buttons.
class WizardBottomBar extends StatelessWidget {
  final bool canProceed;
  final bool showBackButton;
  final String? nextButtonText;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const WizardBottomBar({
    super.key,
    required this.canProceed,
    this.showBackButton = true,
    this.nextButtonText,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, -context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (showBackButton) ...[
              Expanded(
                child: SecondaryButton(
                  text: l?.translate('common_back') ?? 'Back',
                  onPressed: onBack ??
                      () => context.read<InvitationCubit>().previousStep(),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.029)),
            ],
            Expanded(
              flex: showBackButton ? 2 : 1,
              child: PrimaryButton(
                text: nextButtonText ?? l?.translate('common_next') ?? 'Next',
                onPressed: canProceed
                    ? (onNext ??
                        () => context.read<InvitationCubit>().nextStep())
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
