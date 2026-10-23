import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/bank_details_entity.dart';

/// Shows Maktoob's manual-payment details on the receipt-upload screen.
///
/// Three outcomes, never an endless spinner:
///  - details configured → only the rows that have a value (SWIFT, holder,
///    wallet, instructions are each optional);
///  - nothing configured → "unavailable, contact support before paying";
///  - request failed → "couldn't load" with a retry.
/// A support chat is offered only when a real support number is configured.
class BankDetailsCardWidget extends StatelessWidget {
  final BankDetailsEntity bankDetails;
  final VoidCallback? onRetry;

  const BankDetailsCardWidget({
    super.key,
    required this.bankDetails,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.translate('bank_details_title'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gray900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._body(context, l, arabic),
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context, AppLocalizations l, bool arabic) {
    if (bankDetails.loadFailed) {
      return [
        _Notice(text: l.translate('bank_details_load_failed_body')),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('bank_details_retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l.translate('bank_details_retry')),
          ),
        ],
      ];
    }

    if (!bankDetails.isConfigured) {
      return [
        _Notice(text: l.translate('bank_details_unavailable_body')),
        const SizedBox(height: 12),
        _supportAction(context, l),
      ];
    }

    final d = bankDetails;
    return [
      if (d.hasBank) ...[
        _SectionTitle(l.translate('bank_details_bank_transfer')),
        _row(context, l, l.translate('bank_details_bank'), d.bankName(arabic: arabic)),
        _row(context, l, l.translate('bank_details_account_holder'), d.accountHolder),
        _row(context, l, l.translate('bank_details_account_number'), d.accountNumber),
        _row(context, l, l.translate('bank_details_iban'), d.iban),
        _row(context, l, l.translate('bank_details_swift'), d.swiftCode),
      ],
      if (d.hasWallet) ...[
        _SectionTitle(l.translate('bank_details_wallet')),
        _row(context, l, l.translate('bank_details_wallet_service'), d.walletProviderName),
        _row(context, l, l.translate('bank_details_wallet_number'), d.walletAccountNumber),
      ],
      if (d.instructions(arabic: arabic) != null) ...[
        _SectionTitle(l.translate('bank_details_instructions')),
        Text(
          d.instructions(arabic: arabic)!,
          style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.gray700),
        ),
        const SizedBox(height: 8),
      ],
      if (d.supportWhatsapp != null) _supportAction(context, l),
    ];
  }

  /// A row only exists when it has a value.
  Widget _row(BuildContext context, AppLocalizations l, String label, String? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.gray500)),
          ),
          Expanded(
            child: SelectableText(
              value,
              textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
            ),
          ),
          IconButton(
            tooltip: l.translate('bank_details_copy'),
            icon: const Icon(Icons.copy, size: 18, color: AppColors.gray500),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.translate('bank_details_copied')), duration: const Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _supportAction(BuildContext context, AppLocalizations l) {
    final number = bankDetails.supportWhatsapp;

    if (number == null) {
      // No real number configured: say so, never open a chat with a guess.
      return Text(
        l.translate('bank_details_support_unavailable'),
        key: const Key('bank_details_support_unavailable'),
        style: const TextStyle(fontSize: 13, color: AppColors.gray500),
      );
    }

    return OutlinedButton.icon(
      key: const Key('bank_details_contact_support'),
      onPressed: () => launchUrl(
        Uri.parse('https://wa.me/${number.replaceAll(RegExp(r'[^\d]'), '')}'),
        mode: LaunchMode.externalApplication,
      ),
      icon: const Icon(Icons.chat_outlined),
      label: Text(l.translate('bank_details_contact_support')),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 4, bottom: 10),
      child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray800)),
    );
  }
}

class _Notice extends StatelessWidget {
  final String text;

  const _Notice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.amber700, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.gray800))),
        ],
      ),
    );
  }
}
