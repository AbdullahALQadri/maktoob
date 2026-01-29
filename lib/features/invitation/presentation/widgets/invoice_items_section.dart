import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

/// Invoice items table section.
class InvoiceItemsSection extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;

  const InvoiceItemsSection({
    super.key,
    required this.state,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final invoice = state.invoiceSummary;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_invoice_details') ?? 'Invoice Details',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          _TableHeader(l: l),
          _InvoiceRow(
            label:
                '${l?.translate('invitation_package') ?? 'Package'}: ${isEnglish ? (state.selectedPackage?.name ?? '-') : (state.selectedPackage?.nameAr ?? '-')}',
            price: state.selectedPackage?.isCustom == true &&
                    state.customPackagePrice != null
                ? state.customPackagePrice!
                : state.selectedPackage?.price ?? 0,
          ),
          if (state.uploadedTemplateFile != null)
            _InvoiceRow(
              label: l?.translate('invitation_custom_template_fee') ??
                  'Custom Template Fee',
              price: invoice?.templateFee ?? 50,
            ),
          if (state.selectedServices.isNotEmpty) ...[
            _ServicesHeader(l: l),
            ...state.selectedServices.map(
              (service) => _InvoiceRow(
                label: '  • ${isEnglish ? service.name : service.nameAr}',
                price: service.price,
                indent: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final AppLocalizations? l;

  const _TableHeader({this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.dynamicHeight(0.015),
        horizontal: context.dynamicWidth(0.04),
      ),
      decoration: BoxDecoration(
        color: context.overlayBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.dynamicWidth(0.021)),
          topRight: Radius.circular(context.dynamicWidth(0.021)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              l?.translate('invitation_item') ?? 'Item',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l?.translate('invitation_price') ?? 'Price',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesHeader extends StatelessWidget {
  final AppLocalizations? l;

  const _ServicesHeader({this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.dynamicHeight(0.01),
        horizontal: context.dynamicWidth(0.04),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          Text(
            '${l?.translate('invitation_extra_services') ?? 'Extra Services'}:',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.032),
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final double price;
  final bool indent;

  const _InvoiceRow({
    required this.label,
    required this.price,
    this.indent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.dynamicHeight(0.015),
        horizontal: context.dynamicWidth(0.04),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                color: indent ? context.textSecondary : context.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${price.toStringAsFixed(0)} ₪',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                fontWeight: indent ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
