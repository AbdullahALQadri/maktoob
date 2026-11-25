import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/pay_currency.dart';
import '../../domain/entities/payment_method.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'payment_success_view.dart';
import 'widgets.dart';

/// The payment form: the amount, the ways to pay, the receipt and the button.
class PaymentContent extends StatelessWidget {
  final PaymentState state;
  final List<PaymentChoice> choices;
  final PaymentChoice? choice;
  final double? amount;
  final String eventLabel;
  final ValueChanged<PaymentChoice> onChoice;
  final VoidCallback onSubmit;
  final VoidCallback? onSkip;

  /// The currency the client pays in; null = shekels.
  final PayCurrency? currency;

  const PaymentContent({
    super.key,
    required this.state,
    required this.choices,
    required this.choice,
    required this.amount,
    required this.eventLabel,
    required this.onChoice,
    required this.onSubmit,
    this.onSkip,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final current = state;
    final isUploading = current is Uploading;
    final uploadProgress = current is Uploading ? current.progress : 0.0;
    final details = current.bankDetails;
    final whatsapp = details?.paymentWhatsapp;
    final c = choice;

    if (current is UploadSuccess) {
      return PaymentSuccessView(
        cash: current.method == PaymentMethod.cash,
        amount: amount,
        currency: currency,
        whatsapp: whatsapp,
        eventLabel: eventLabel,
        methodLabel: c?.label(l) ?? l.translate('payment_method_cash'),
        onContinue: onSubmit,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentAmountLine(amount: amount, currency: currency),
        // null = still loading; a failed request arrives as
        // BankDetailsEntity.loadFailed() (retry card). Cash stays available.
        if (details == null)
          const BankDetailsCardSkeleton()
        else ...[
          if (details.loadFailed) ...[
            BankDetailsCardWidget(
              bankDetails: details,
              onRetry: () => context.read<PaymentCubit>().loadBankDetails(),
            ),
            AppSpacing.verticalSpace16,
          ],
          PaymentMethodSelector(
            choices: choices,
            selected: c,
            onChanged: isUploading ? null : onChoice,
          ),
        ],
        if (c != null) ...[
          const Divider(height: AppSpacing.xl, color: AppColors.gray200),
          PaymentMethodDetails(choice: c, details: details),
          AppSpacing.verticalSpace16,
          if (c.method.requiresReceipt) ...[
            UploadAreaWidget(
              selectedFiles: current.selectedFiles,
              isUploading: isUploading,
              uploadProgress: uploadProgress,
              onPickFile: () => context.read<PaymentCubit>().pickFile(),
              onRemoveFile: (i) => context.read<PaymentCubit>().removeFile(i),
            ),
            AppSpacing.verticalSpace16,
            if (current.selectedFiles.isNotEmpty) ...[
              PaymentSubmitButton(
                isUploading: isUploading,
                uploadSuccess: false,
                canSubmit: !isUploading,
                onPressed: onSubmit,
              ),
              AppSpacing.verticalSpace12,
            ],
          ] else ...[
            PrimaryButton(
              key: const Key('payment_confirm_cash'),
              text: l.translate('payment_confirm_cash'),
              icon: Icons.check,
              isLoading: isUploading,
              onPressed: isUploading ? null : onSubmit,
            ),
            AppSpacing.verticalSpace12,
          ],
          PaymentWhatsappButton(
            number: whatsapp,
            event: eventLabel,
            amount: amount,
            methodLabel: c.label(l),
          ),
        ],
        AppSpacing.verticalSpace8,
        TextButton(
          onPressed: onSkip,
          child: Text(
            l.translate('payment_skip'),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        AppSpacing.verticalSpace32,
      ],
    );
  }
}
