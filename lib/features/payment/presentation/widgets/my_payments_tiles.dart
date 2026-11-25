import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/utils/date_words.dart';
import '../../domain/entities/my_payments.dart';

String _money(double amount) => '${amount.toStringAsFixed(2)} ₪';

String _date(BuildContext context, DateTime? d) =>
    d == null ? '' : '${d.day} ${context.monthName(d)} ${d.year}';

/// "Total paid" at the top of the screen.
class PaidTotalCard extends StatelessWidget {
  final double total;

  const PaidTotalCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryColor),
          AppSpacing.horizontalSpace12,
          Expanded(child: Text(context.tr('my_payments_total_paid'), style: AppTextStyles.labelMedium)),
          Text(_money(total), style: AppTextStyles.titleMedium.copyWith(color: context.brandInk)),
        ],
      ),
    );
  }
}

class MyPaymentsSectionTitle extends StatelessWidget {
  final String title;

  const MyPaymentsSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
    child: Text(title, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
  );
}

/// An event waiting for its payment: the amount and a way to pay.
class PaymentDueTile extends StatelessWidget {
  final PaymentDue due;
  final VoidCallback onPay;

  const PaymentDueTile({super.key, required this.due, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      borderColor: AppColors.amber500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(due.eventTitle, style: AppTextStyles.labelLarge),
          AppSpacing.verticalSpace4,
          Text('${context.tr('my_payments_amount_due')}: ${_money(due.amount)}', style: AppTextStyles.bodyMedium),
          AppSpacing.verticalSpace8,
          Text(context.tr('my_payments_due_hint'), style: AppTextStyles.caption.copyWith(color: context.textSecondary)),
          AppSpacing.verticalSpace12,
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: onPay,
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: Text(context.tr('my_payments_pay')),
            ),
          ),
        ],
      ),
    );
  }
}

/// A receipt the host sent: under review, or refused with the reason.
class SentReceiptTile extends StatelessWidget {
  final SentReceipt sent;
  final VoidCallback? onTap;

  const SentReceiptTile({super.key, required this.sent, this.onTap});

  @override
  Widget build(BuildContext context) {
    final rejected = sent.isRejected;
    return AppCard.outlined(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(sent.eventTitle ?? sent.requestNumber, style: AppTextStyles.labelLarge)),
              _Pill(
                text: context.tr(rejected ? 'my_payments_rejected' : 'my_payments_under_review'),
                color: rejected ? AppColors.red500 : AppColors.amber700,
              ),
            ],
          ),
          AppSpacing.verticalSpace4,
          Text('${_money(sent.amount)} · ${_date(context, sent.sentAt)}', style: AppTextStyles.caption),
          AppSpacing.verticalSpace8,
          Text(
            rejected
                ? '${context.tr('my_payments_reason')}: ${sent.reason ?? ''}'
                : context.tr('my_payments_review_hint'),
            style: AppTextStyles.caption.copyWith(color: rejected ? AppColors.red500 : context.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A confirmed payment: receipt number, how and when, and the receipt.
class PaymentReceiptTile extends StatelessWidget {
  final PaymentReceipt receipt;
  final VoidCallback onOpen;

  const PaymentReceiptTile({super.key, required this.receipt, required this.onOpen});

  String _method(BuildContext context) => switch (receipt.method) {
    'cash' => context.tr('my_payments_method_cash'),
    'wallet' => receipt.walletProvider == null
        ? context.tr('my_payments_method_wallet')
        : '${context.tr('my_payments_method_wallet')} (${receipt.walletProvider})',
    _ => context.tr('my_payments_method_bank'),
  };

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(receipt.eventTitle ?? '—', style: AppTextStyles.labelLarge),
                AppSpacing.verticalSpace4,
                Text(receipt.receiptNumber, textDirection: TextDirection.ltr, style: AppTextStyles.caption),
                Text('${_method(context)} · ${_date(context, receipt.paidAt)}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_money(receipt.amount), style: AppTextStyles.labelLarge.copyWith(color: context.brandInk)),
              if (receipt.isRefunded)
                _Pill(text: context.tr('my_payments_refunded'), color: AppColors.gray600)
              else
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: Text(context.tr('my_payments_open_receipt')),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.md),
    ),
    child: Text(text, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
  );
}
