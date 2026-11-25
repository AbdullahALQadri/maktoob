import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../domain/entities/pay_currency.dart';
import 'payment_method_widgets.dart';

/// "Pay in": the currencies on offer, each with its amount. The client picks
/// a currency; the amount was fixed by the server.
class PayCurrencyPicker extends StatelessWidget {
  const PayCurrencyPicker({
    super.key,
    required this.currencies,
    required this.selectedCode,
    required this.onChanged,
  });

  final PayCurrencies currencies;
  final String selectedCode;

  /// Null while a payment is being sent.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final foreign = selectedCode != PayCurrency.baseCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr('pay_in'),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final currency in currencies.options)
              _CurrencyChip(
                key: Key('pay_currency_${currency.code}'),
                currency: currency,
                selected: currency.code == selectedCode,
                onTap: onChanged == null ? null : () => onChanged!(currency.code),
              ),
          ],
        ),
        if (foreign) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('pay_in_note', {'total': formatPaymentAmount(currencies.ilsTotal)}),
            key: const Key('pay_in_note'),
            style: TextStyle(fontSize: 12.5, height: 1.5, color: context.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({super.key, required this.currency, required this.selected, required this.onTap});

  final PayCurrency currency;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 96),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? context.primaryWash : context.cardBg,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: selected ? AppColors.primaryColor : context.borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency.name(arabic: context.languageCode == 'ar'),
                style: TextStyle(fontSize: 12.5, color: context.textSecondary),
              ),
              Text(
                currency.isBase
                    ? '${formatPaymentAmount(currency.amount)} ${context.tr('currency_ils')}'
                    : currency.formatted,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: selected ? context.primaryText : context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
