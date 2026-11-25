import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/wizard_results.dart';
import '../invitation_state.dart';
import 'wizard_deps.dart';
import 'wizard_details_actions.dart';
import 'wizard_step_saves.dart';

/// Saving the event: as a draft, or for good (payment or activation next).
mixin WizardSubmitActions on Cubit<InvitationState>, WizardDeps, WizardDetailsActions, WizardStepSaves {
  /// Keeps what was entered so far and leaves the event a draft.
  Future<void> saveDraft() async {
    emit(state.copyWith(isSaving: true, isSaveAsDraft: true, saveSuccess: false, saveError: null));
    final eventId = state.draftEventId;
    if (repository == null || eventId == null) {
      return _saved(savedEventId: 'draft_${DateTime.now().millisecondsSinceEpoch}', asDraft: true);
    }
    final result = await _inOrder([
      () => repository!.saveDetails(eventId, detailsToSend()),
      () => saveGuestsRemote(eventId),
    ]).then((sent) async => sent.isLeft() ? sent : await repository!.save(eventId, asDraft: true));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(
        isSaving: false,
        saveSuccess: false,
        saveError: failure.toString(),
        status: InvitationStatus.failure,
        errorMessage: failure.toString(),
      )),
      (saved) => _saved(savedEventId: '${saved is WizardSaveResult ? saved.eventId : eventId}', asDraft: true),
    );
  }

  /// The final save: every step is sent again (they are safe to repeat),
  /// then the event waits for payment, or goes live when it is free or the
  /// institution's balance covers it. [openWhatsApp] false skips sharing the
  /// invoice: paid events go to the in-app payment screen.
  Future<void> saveAndSend({Uint8List? invoiceImage, bool openWhatsApp = true}) async {
    emit(state.copyWith(isSaving: true, isSaveAsDraft: false, saveSuccess: false, saveError: null));
    if (repository != null) {
      if (!await ensureDraft()) return emit(state.copyWith(isSaving: false, saveError: state.errorMessage));
      final failure = await _submit(state.draftEventId!);
      if (isClosed) return;
      if (failure != null) {
        return emit(state.copyWith(
          isSaving: false,
          saveError: failure.toString(),
          saveErrorIsFreeTrial: failure is WizardRefusedFailure && failure.freeTrialUsed,
        ));
      }
    }
    if (openWhatsApp) await _shareInvoice(invoiceImage);
    if (!isClosed) emit(state.copyWith(isSaving: false, saveSuccess: true));
  }

  Future<Failure?> _submit(int eventId) async {
    final package = state.selectedPackage;
    final sent = await _inOrder([
      () => repository!.saveDetails(eventId, detailsToSend()),
      () => saveGuestsRemote(eventId),
      () => saveConfigRemote(eventId),
      () => saveServicesRemote(eventId),
      if (package != null)
        () => repository!.selectPackage(
              eventId,
              packageId: package.id,
              custom: package.isCustom,
              customInvitations: state.customPackageLimit,
            ),
    ]);
    if (sent.isLeft()) return sent.fold((f) => f, (_) => null);

    final saved = await repository!.save(eventId, asDraft: false);
    final result = saved.fold((_) => null, (r) => r);
    if (result == null) return saved.fold((f) => f, (_) => null);
    if (result.creditsCover) {
      final activated = await repository!.activate(eventId);
      if (activated.isLeft()) return activated.fold((f) => f, (_) => null);
    }
    emit(state.copyWith(
      savedEventId: '$eventId',
      savedInvoiceTotal: result.invoiceTotal,
      paidByCredits: result.creditsCover,
    ));
    return null;
  }

  /// Runs the saves one after another and stops at the first that fails.
  Future<Either<Failure, Object>> _inOrder(List<Future<Either<Failure, Object>> Function()> saves) async {
    for (final save in saves) {
      final result = await save();
      if (result.isLeft()) return result;
    }
    return const Right(unit);
  }

  void _saved({required String savedEventId, required bool asDraft}) {
    emit(state.copyWith(
      isSaving: false,
      saveSuccess: true,
      isSaveAsDraft: asDraft,
      status: InvitationStatus.success,
      savedEventId: savedEventId,
    ));
  }

  /// Hands the invoice to WhatsApp for a paid event. A failure here never
  /// undoes the save.
  Future<void> _shareInvoice(Uint8List? invoiceImage) async {
    final number = state.whatsappNumber;
    final free = state.selectedPackage?.isFree ?? false;
    if (free || state.paidByCredits || whatsAppService == null || number == null) return;
    try {
      final message = whatsAppService!.generateInvoiceMessage(
        eventName: state.eventName ?? '',
        packageName: state.selectedPackage?.nameAr ?? state.selectedPackage?.name ?? '',
        totalPrice: state.invoiceSummary?.totalPrice ?? 0,
        guestCount: state.totalGuestCount,
      );
      invoiceImage != null
          ? await whatsAppService!.openWhatsAppWithInvoice(
              phoneNumber: number,
              invoiceImage: invoiceImage,
              message: message,
            )
          : await whatsAppService!.openWhatsApp(phoneNumber: number, message: message);
    } catch (e) {
      debugPrint('WhatsApp: $e');
    }
  }
}
