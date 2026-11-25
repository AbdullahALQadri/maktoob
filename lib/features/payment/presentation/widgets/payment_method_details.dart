import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/bank_details_entity.dart';
import '../../domain/entities/payment_method.dart';
import 'payment_method_widgets.dart';

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
          // A foreign currency with an account of its own: say whose it is.
          if (d?.bankCurrency != null)
            Text(
              l.translate('pay_account_for').replaceAll('{code}', d!.bankCurrency!),
              key: const Key('pay_account_for'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
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
