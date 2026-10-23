import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_method.dart';

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

/// Account / wallet details for the chosen method only, each with copy.
class PaymentMethodDetails extends StatelessWidget {
  final PaymentChoice choice;
  final BankDetailsEntity? details;

  const PaymentMethodDetails({super.key, required this.choice, required this.details});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final d = details;

    final List<Widget> rows;
    switch (choice.method) {
      case PaymentMethod.cash:
        rows = [
          Text(
            l.translate('payment_cash_details'),
            style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.gray700),
          ),
        ];
      case PaymentMethod.bankTransfer:
        rows = [
          _CopyRow(label: l.translate('bank_details_account_holder'), value: d?.accountHolder),
          _CopyRow(label: l.translate('bank_details_bank'), value: d?.bankName(arabic: arabic), copyable: false),
          _CopyRow(label: l.translate('bank_details_iban'), value: d?.iban),
          _CopyRow(label: l.translate('bank_details_account_number'), value: d?.accountNumber),
          _CopyRow(label: l.translate('bank_details_swift'), value: d?.swiftCode),
        ];
      case PaymentMethod.wallet:
        rows = [
          _CopyRow(label: l.translate('bank_details_wallet_service'), value: choice.label(l), copyable: false),
          _CopyRow(label: l.translate('bank_details_wallet_number'), value: choice.wallet?.accountNumber),
        ];
    }

    final instructions = d?.instructions(arabic: arabic);
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rows,
          if (choice.method != PaymentMethod.cash && instructions != null) ...[
            AppSpacing.verticalSpace4,
            Text(instructions, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.gray600)),
          ],
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool copyable;

  const _CopyRow({required this.label, required this.value, this.copyable = true});

  @override
  Widget build(BuildContext context) {
    final v = value;
    if (v == null || v.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.gray500)),
          ),
          Expanded(
            child: SelectableText(
              v,
              textDirection: copyable ? TextDirection.ltr : null,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: l.translate('bank_details_copy'),
              icon: const Icon(Icons.copy, size: 18, color: AppColors.gray500),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: v));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.translate('bank_details_copied')), duration: const Duration(seconds: 1)),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// "تواصل معنا على واتساب" with the prefilled payment message. Renders
/// nothing when no number is configured.
class PaymentWhatsappButton extends StatelessWidget {
  final String? number;
  final String event;
  final double? amount;
  final String methodLabel;

  const PaymentWhatsappButton({
    super.key,
    required this.number,
    required this.event,
    required this.amount,
    required this.methodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final uri = buildPaymentWhatsappUri(
      number: number,
      template: l.translate(amount == null ? 'payment_whatsapp_message_no_amount' : 'payment_whatsapp_message'),
      event: event,
      amount: amount == null ? null : formatPaymentAmount(amount!),
      method: methodLabel,
    );
    if (uri == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('payment_whatsapp'),
        onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.brandInk,
          side: BorderSide(color: context.brandInk),
          padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.smd),
          shape: const RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
        ),
        icon: const Icon(Icons.chat_outlined),
        label: Text(l.translate('payment_whatsapp_button')),
      ),
    );
  }
}
