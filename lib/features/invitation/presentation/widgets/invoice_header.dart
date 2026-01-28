import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

/// Invoice header with app logo and invoice number.
class InvoiceHeader extends StatelessWidget {
  final InvitationState state;

  const InvoiceHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.061)),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.dynamicWidth(0.04)),
          topRight: Radius.circular(context.dynamicWidth(0.04)),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: context.dynamicWidth(0.12),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          Text(
            l?.translate('invitation_event_invoice') ?? 'Event Invoice',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.dynamicWidth(0.061),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            '${l?.translate('invitation_invoice_number') ?? 'Invoice number'}: ${state.invoiceSummary?.invoiceNumber ?? (l?.translate('invitation_new') ?? 'New')}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: context.dynamicWidth(0.035),
            ),
          ),
          Text(
            '${l?.translate('invitation_date') ?? 'Date'}: ${_formatDate(DateTime.now())}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: context.dynamicWidth(0.035),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
