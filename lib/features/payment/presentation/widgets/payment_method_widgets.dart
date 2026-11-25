import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_method.dart';

export 'payment_method_details.dart';

/// What the user picked on the payment screen: a method, plus the wallet
/// (by provider name) when the method is [PaymentMethod.wallet].
class PaymentChoice extends Equatable {
  final PaymentMethod method;
  final WalletAccountEntity? wallet;

  const PaymentChoice.cash()
      : method = PaymentMethod.cash,
        wallet = null;

  const PaymentChoice.bank()
      : method = PaymentMethod.bankTransfer,
        wallet = null;

  const PaymentChoice.wallet(WalletAccountEntity this.wallet)
      : method = PaymentMethod.wallet;

  /// The options to offer: cash always; bank only when configured; one row
  /// per configured wallet.
  static List<PaymentChoice> available(BankDetailsEntity? details) {
    final usable = details != null && !details.loadFailed;
    return [
      const PaymentChoice.cash(),
      if (usable && details.hasBank) const PaymentChoice.bank(),
      if (usable) ...details.walletOptions.map(PaymentChoice.wallet),
    ];
  }

  String label(AppLocalizations l) {
    switch (method) {
      case PaymentMethod.cash:
        return l.translate('payment_method_cash');
      case PaymentMethod.bankTransfer:
        return l.translate('payment_method_bank');
      case PaymentMethod.wallet:
        final name = wallet?.providerName ?? '';
        return name.isEmpty ? l.translate('payment_method_wallet_fallback') : name;
    }
  }

  @override
  List<Object?> get props => [method, wallet];
}

/// `https://wa.me/<digits>?text=...` with the approved prefilled message, or
/// null when no number is configured (the button is then hidden).
Uri? buildPaymentWhatsappUri({
  required String? number,
  required String template,
  required String event,
  required String? amount,
  required String method,
}) {
  final digits = number?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
  if (digits.isEmpty) return null;
  var text = template.replaceAll('{event}', event).replaceAll('{method}', method);
  if (amount != null) text = text.replaceAll('{amount}', amount);
  return Uri.https('wa.me', '/$digits', {'text': text});
}

/// Formats a ₪ amount without trailing ".00".
String formatPaymentAmount(double amount) =>
    amount == amount.roundToDouble() ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);

/// The method radio list ("كيف بدك تدفع؟").
class PaymentMethodSelector extends StatelessWidget {
  final List<PaymentChoice> choices;
  final PaymentChoice? selected;
  final ValueChanged<PaymentChoice>? onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.choices,
    required this.selected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.translate('payment_method_title'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.gray900),
        ),
        AppSpacing.verticalSpace12,
        for (final choice in choices) ...[
          _MethodTile(
            key: ValueKey('payment_choice_${choice.method.apiValue}_${choice.wallet?.providerName ?? ''}'),
            choice: choice,
            selected: choice == selected,
            onTap: onChanged == null ? null : () => onChanged!(choice),
          ),
          AppSpacing.verticalSpace8,
        ],
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentChoice choice;
  final bool selected;
  final VoidCallback? onTap;

  const _MethodTile({super.key, required this.choice, required this.selected, this.onTap});

  IconData get _icon {
    switch (choice.method) {
      case PaymentMethod.cash:
        return Icons.payments_outlined;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.white,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InkWell(
        borderRadius: AppSpacing.borderRadiusMd,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.smd),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: selected ? AppColors.primaryColor : AppColors.gray200),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? AppColors.primaryColor : AppColors.gray400,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.smd),
              Icon(_icon, color: AppColors.gray600, size: 22),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      choice.label(l),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                    ),
                    if (choice.method == PaymentMethod.cash)
                      Text(
                        l.translate('payment_method_cash_hint'),
                        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
