import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../domain/entities/pay_currency.dart';
import 'widgets.dart';

/// The payment was sent: a clear confirmation, WhatsApp, and a way on.
class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({
    super.key,
    required this.cash,
    required this.amount,
    required this.currency,
    required this.whatsapp,
    required this.eventLabel,
    required this.methodLabel,
    required this.onContinue,
  });

  final bool cash;
  final double? amount;
  final PayCurrency? currency;
  final String? whatsapp;
  final String eventLabel;
  final String methodLabel;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PaymentAmountLine(amount: amount, currency: currency),
        Container(
          key: const Key('payment_success'),
          padding: const EdgeInsetsDirectional.all(AppSpacing.mdl),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, color: context.brandInk, size: 48),
              AppSpacing.verticalSpace12,
              Text(
                context.tr(cash ? 'payment_cash_success' : 'payment_transfer_success'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6, fontWeight: FontWeight.w600, color: context.textPrimary),
              ),
            ],
          ),
        ),
        AppSpacing.verticalSpace16,
        PaymentWhatsappButton(number: whatsapp, event: eventLabel, amount: amount, methodLabel: methodLabel),
        AppSpacing.verticalSpace12,
        PaymentSubmitButton(isUploading: false, uploadSuccess: true, canSubmit: true, onPressed: onContinue),
        AppSpacing.verticalSpace32,
      ],
    );
  }
}
