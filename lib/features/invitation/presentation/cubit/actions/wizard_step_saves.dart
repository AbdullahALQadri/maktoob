import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/wizard_results.dart';
import '../invitation_state.dart';
import 'wizard_deps.dart';
import 'wizard_services_actions.dart';

/// Each step saves its own part when the host moves on, as the portal does,
/// so a draft left half-way opens where it stopped.
mixin WizardStepSaves on Cubit<InvitationState>, WizardDeps, WizardServicesActions {
  void nextStep();

  void updateEventDescription(String text) => emit(state.copyWith(eventDescription: text));

  /// `whatsapp` or `email`.
  void setDeliveryMethod(String method) => emit(state.copyWith(deliveryMethod: method));

  void setRequireResponse(bool value) => emit(state.copyWith(requireResponse: value));

  /// Step 2.
  Future<void> saveGuestsAndProceed() => _saveThenNext(saveGuestsRemote);

  /// Step 4: how the invitation goes out, how guests reply, and the extras.
  Future<void> saveSettingsAndProceed() => _saveThenNext((eventId) async {
        final config = await saveConfigRemote(eventId);
        return config.isLeft() ? config : saveServicesRemote(eventId);
      });

  /// The whole list goes, so a removed guest is removed there too.
  Future<Either<Failure, Unit>> saveGuestsRemote(int eventId) => repository!.saveGuests(eventId, state.guests);

  Future<Either<Failure, Unit>> saveConfigRemote(int eventId) {
    final message = (state.invitationMessage ?? '').trim();
    return repository!.saveInvitationConfig(
      eventId,
      WizardInvitationConfig(
        deliveryMethod: state.deliveryMethod,
        requireResponse: state.requireResponse,
        companions: state.partnerWithGuests ?? 0,
        replyDeadline: state.rsvpDeadline,
        // Sent only when typed; otherwise the saved message is kept.
        message: message.isEmpty ? null : message,
      ),
    );
  }

  /// A custom package carries its own services: the list is left alone then.
  Future<Either<Failure, Unit>> saveServicesRemote(int eventId) async {
    final custom = state.selectedPackage?.isCustom ?? false;
    if (custom || (state.selectedServices.isEmpty && state.availableServices.isEmpty)) return const Right(unit);
    return repository!.saveServices(eventId, state.selectedServices.map((s) => s.id).toList(), serviceOptions());
  }

  Future<void> _saveThenNext(Future<Either<Failure, Unit>> Function(int eventId) save) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final eventId = state.draftEventId;
    final result = repository == null || eventId == null ? null : await save(eventId);
    if (isClosed) return;
    final failure = result?.fold((f) => f, (_) => null);
    if (failure != null) return emit(state.copyWith(isLoading: false, errorMessage: failure.toString()));
    emit(state.copyWith(isLoading: false));
    nextStep();
  }
}
