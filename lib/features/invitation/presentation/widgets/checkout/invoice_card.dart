import 'package:flutter/material.dart';
import '../../../../../config/locale/app_localizations.dart';
import '../../../../../core/core.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/widgets.dart';
import 'checkout_flow.dart';
import 'invoice_rows.dart';


class InvoiceCard extends StatelessWidget {
  final InvitationState state;
  final GlobalKey invoiceKey;
  final bool isEnglish;

  const InvoiceCard({
    super.key,
    required this.state,
    required this.invoiceKey,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final summary = state.invoiceSummary;
    final isLoading = state.isLoadingInvoice;
    final selected = state.selectedPackage;

    final subtotal = summary?.basePrice ?? selected?.effectivePrice ?? 0.0;
    final extras =
        summary?.servicesTotal ??
        state.selectedServices.fold<double>(0, (sum, s) => sum + s.price);
    final extrasCount = state.selectedServices.length;
    // Tax and total come from the backend invoice (GET {id}/invoice);
    // the app never computes its own tax.
    final vat = summary?.taxAmount ?? 0.0;
    final taxRate = summary?.taxRate ?? 0.0;
    final total = wizardInvoiceTotal(state);

    return RepaintBoundary(
      key: invoiceKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l?.translate('wizard_invoice_summary') ?? 'ملخص الفاتورة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.gray200),
            const SizedBox(height: 16),
            if (isLoading)
              const InvoiceSummarySkeleton()
            else ...[
              InvoiceRow(
                label:
                    l?.translate('wizard_invoice_subtotal') ??
                    'المجموع الفرعي (الباقة)',
                value:
                    '${subtotal.toStringAsFixed(2)} ${l?.translate('currency_ils') ?? '₪'}',
              ),
              const SizedBox(height: 14),
              InvoiceRow(
                label: l?.translate('wizard_invoice_extras') ?? 'خدمات إضافية',
                value:
                    '${extras.toStringAsFixed(2)} ${l?.translate('currency_ils') ?? '₪'}',
                badge: extrasCount > 0 ? '$extrasCount' : null,
              ),
              const SizedBox(height: 14),
              if (vat > 0) ...[
                InvoiceRow(
                  label:
                      '${l?.translate('wizard_invoice_tax') ?? 'الضريبة'} (${taxRate.toStringAsFixed(taxRate % 1 == 0 ? 0 : 1)}%)',
                  value:
                      '${vat.toStringAsFixed(2)} ${l?.translate('currency_ils') ?? '₪'}',
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 2),
              CustomPaint(
                painter: DashedLinePainter(color: AppColors.gray200),
                child: const SizedBox(height: 1, width: double.infinity),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l?.translate('wizard_invoice_total') ?? 'الإجمالي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTotal(total),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          l?.translate('currency_ils') ?? '₪',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTotal(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return '${buf.toString()}.${parts[1]}';
  }
}
