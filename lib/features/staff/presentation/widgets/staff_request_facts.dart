import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/staff_entities.dart';

/// Everything staff need to decide on a payment: the client, the event, the
/// amount (and the currency it was paid in), the method, the receipt.
class StaffRequestFacts extends StatelessWidget {
  const StaffRequestFacts({super.key, required this.request});

  final StaffPaymentRequest request;

  @override
  Widget build(BuildContext context) {
    final ils = context.tr('currency_ils');
    final foreign = request.originalCurrency != null && request.originalAmount != null;
    final method = request.method == null ? null : context.tr('staff_method_${request.method}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${request.amount.toStringAsFixed(2)} $ils',
          key: const Key('staff_request_amount'),
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: context.textPrimary),
        ),
        if (foreign)
          Text(
            context.tr('staff_paid_in', {
              'amount': request.originalAmount!.toStringAsFixed(2),
              'currency': request.originalCurrency!,
            }),
            style: TextStyle(fontSize: 14, color: context.textSecondary),
          ),
        const SizedBox(height: 16),
        _Fact('staff_fact_kind', context.tr(request.isUpgrade ? 'staff_kind_upgrade' : 'staff_kind_payment')),
        if (request.isUpgrade && request.targetInvitations != null)
          _Fact('staff_fact_target', context.tr('upgrade_invitations', {'count': request.targetInvitations!})),
        _Fact('staff_fact_client', request.clientName),
        _Fact('staff_fact_phone', request.clientPhone, ltr: true),
        _Fact('staff_fact_event', request.eventTitle),
        _Fact('staff_fact_method', [?method, ?request.walletProvider].join(' · ')),
        _Fact('staff_fact_notes', request.clientNotes),
        if (!request.isPending) _Fact('staff_fact_decision', request.adminNotes),
        const SizedBox(height: 12),
        Text(
          context.tr('staff_receipt'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
        ),
        const SizedBox(height: 8),
        if (request.imageUrls.isEmpty)
          Text(
            context.tr(request.method == 'cash' ? 'staff_receipt_cash' : 'staff_receipt_none'),
            style: TextStyle(fontSize: 14, height: 1.5, color: context.textSecondary),
          ),
        for (final url in request.imageUrls)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Pinch to read the small print of a transfer slip.
              child: InteractiveViewer(
                maxScale: 5,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, _) => const SizedBox(height: 160),
                  errorWidget: (context, _, _) => Container(
                    height: 120,
                    alignment: Alignment.center,
                    color: context.cardBg,
                    child: Icon(Icons.broken_image_outlined, color: context.textSecondary),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.labelKey, this.value, {this.ltr = false});

  final String labelKey;
  final String? value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr(labelKey), style: TextStyle(fontSize: 12.5, color: context.textSecondary)),
          const SizedBox(height: 2),
          Text(
            text,
            textDirection: ltr ? TextDirection.ltr : null,
            style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w600, color: context.textPrimary),
          ),
        ],
      ),
    );
  }
}
