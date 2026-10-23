import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_entity.dart';

/// Shown on an event that is saved but not paid (status pending_payment):
/// either "pay to activate" (opens the payment screen) or, when a payment
/// request is already awaiting review, a plain "under review" note.
class PendingPaymentBanner extends StatelessWidget {
  final EventEntity event;
  final bool underReview;

  /// Called after the payment screen closes (to refresh the event).
  final VoidCallback? onPaid;

  const PendingPaymentBanner({
    super.key,
    required this.event,
    required this.underReview,
    this.onPaid,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: AppColors.gray200),
        ),
        child: underReview
            ? Row(
                key: const Key('event_payment_under_review'),
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: AppColors.primaryColor),
                  const SizedBox(width: AppSpacing.smd),
                  Expanded(
                    child: Text(
                      l.translate('event_payment_under_review'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.translate('event_pending_payment_body'),
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.gray700),
                  ),
                  AppSpacing.verticalSpace12,
                  PrimaryButton(
                    key: const Key('event_pay_to_activate'),
                    text: l.translate('event_pay_to_activate'),
                    icon: Icons.payments_outlined,
                    onPressed: () => _openPayment(context),
                  ),
                ],
              ),
      ),
    );
  }

  void _openPayment(BuildContext context) =>
      openEventPayment(context, event, onPaid: onPaid);
}

/// Opens the payment screen for a pending-payment [event] (id, invoice total,
/// title); [onPaid] runs when it closes.
void openEventPayment(
  BuildContext context,
  EventEntity event, {
  VoidCallback? onPaid,
}) {
  final nav = Navigator.of(context);
  nav.pushNamed(Routes.payment, arguments: {
    'eventId': event.id,
    'amount': event.invoiceTotal,
    'eventTitle': event.name,
    'onComplete': () => nav.pop(),
  }).then((_) => onPaid?.call());
}
