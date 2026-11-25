
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/invoice_model.dart';
import '../invitation_state.dart';
import '../../../data/repositories/wizard_parsers.dart' show nonBlank;
import 'wizard_deps.dart';

/// Step 5: the invoice and sharing it.
mixin WizardInvoiceActions on Cubit<InvitationState>, WizardDeps {
  /// Generate invoice summary
  void generateInvoiceSummary() {
    final lineItems = <InvoiceLineItem>[];
    double basePrice = 0;
    double servicesTotal = 0;
    double templateFee = 0;

    // Package price
    if (state.selectedPackage != null) {
      basePrice = state.selectedPackage!.isCustom
          ? (state.customPackagePrice ?? 0)
          : state.selectedPackage!.price;

      lineItems.add(InvoiceLineItem(
        description: state.selectedPackage!.name,
        descriptionAr: state.selectedPackage!.nameAr,
        amount: basePrice,
      ));
    }

    // Services
    for (final service in state.selectedServices) {
      servicesTotal += service.effectivePrice;
      lineItems.add(InvoiceLineItem(
        description: service.name,
        descriptionAr: service.nameAr,
        amount: service.price,
      ));
    }

    // Template fee
    if (state.selectedTemplate?.hasExtraFee ?? false) {
      templateFee = state.selectedTemplate!.extraFeeAmount ?? 0;
      if (templateFee > 0) {
        lineItems.add(InvoiceLineItem(
          description: 'Custom Template Fee',
          descriptionAr: 'رسوم القالب المخصص',
          amount: templateFee,
        ));
      }
    }

    final totalPrice = basePrice + servicesTotal + templateFee;

    final invoice = InvoiceSummaryModel(
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      basePrice: basePrice,
      servicesTotal: servicesTotal,
      templateFee: templateFee,
      totalPrice: totalPrice,
      lineItems: lineItems,
      createdAt: DateTime.now(),
      eventName: state.eventName,
      packageName: state.selectedPackage?.name,
      guestCount: state.totalGuestCount,
    );

    emit(state.copyWith(invoiceSummary: invoice));
  }

  /// Set WhatsApp number from API
  void setWhatsAppNumber(String number) {
    emit(state.copyWith(whatsappNumber: nonBlank(number)));
  }

  /// The invoice as the server computes it; without a server, the sum of
  /// what was picked on the device.
  Future<void> loadInvoice() async {
    final eventId = state.draftEventId;
    if (repository == null || eventId == null) return generateInvoiceSummary();
    emit(state.copyWith(isLoadingInvoice: true, invoiceError: null));
    final result = await repository!.invoice(eventId);
    if (isClosed) return;
    emit(result.fold(
      (failure) => state.copyWith(isLoadingInvoice: false, invoiceError: failure.toString()),
      (invoice) => state.copyWith(
        isLoadingInvoice: false,
        invoiceSummary: invoice.summary.copyWith(
          eventName: invoice.summary.eventName ?? state.eventName,
          packageName: state.selectedPackage?.name,
          guestCount: invoice.summary.guestCount ?? state.totalGuestCount,
        ),
        whatsappNumber: invoice.whatsappNumber,
      ),
    ));
  }
}
