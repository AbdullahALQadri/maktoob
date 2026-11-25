import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/pay_currency.dart';
import 'payment_method_widgets.dart';

/// The amount due, in the currency the client pays in.
class PaymentAmountLine extends StatelessWidget {
  const PaymentAmountLine({super.key, required this.amount, this.currency});

  final double? amount;

  /// A foreign currency shows its own amount, with the shekel total beside it.
  final PayCurrency? currency;

  @override
  Widget build(BuildContext context) {
    final a = amount;
    if (a == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final shekels = '${formatPaymentAmount(a)} ${l.translate('currency_ils')}';
    final foreign = currency != null && !currency!.isBase;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
      child: Text(
        '${l.translate('payment_amount_label')}: ${foreign ? '${currency!.formatted} ($shekels)' : shekels}',
        key: const Key('payment_amount'),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.textPrimary),
      ),
    );
  }
}
