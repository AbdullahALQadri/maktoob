import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

/// Invoice total section.
class InvoiceTotalSection extends StatelessWidget {
  final InvitationState state;

  const InvoiceTotalSection({super.key, required this.state});

  double get _total {
    final invoice = state.invoiceSummary;
    double total = 0;

    // Package price
    if (state.selectedPackage?.isCustom == true &&
        state.customPackagePrice != null) {
      total += state.customPackagePrice!;
    } else {
      total += state.selectedPackage?.price ?? 0;
    }

    // Custom template fee
    if (state.uploadedTemplateFile != null) {
      total += invoice?.templateFee ?? 50;
    }

    // Extra services
    for (var service in state.selectedServices) {
      total += service.price;
    }

    // Use invoice total if available (from API)
    return invoice?.totalPrice ?? total;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l?.translate('invitation_total') ?? 'Total',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.051),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.061),
              vertical: context.dynamicHeight(0.015),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
            ),
            child: Text(
              '${_total.toStringAsFixed(0)} ₪',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.056),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Invoice footer with thank you message.
class InvoiceFooter extends StatelessWidget {
  const InvoiceFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.dynamicWidth(0.04)),
          bottomRight: Radius.circular(context.dynamicWidth(0.04)),
        ),
      ),
      child: Column(
        children: [
          Text(
            l?.translate('invitation_thank_you') ??
                'Thank you for using Maktoob app',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.035),
              color: context.textSecondary,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            '${l?.translate('invitation_support') ?? 'For support'}: support@maktoob.app',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
              color: context.iconSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
