import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/wizard_results.dart';
import '../../../domain/utils/event_setup_rules.dart';
import '../invitation_state.dart';
import 'wizard_deps.dart';

/// Step 1: creating the draft and saving its details.
mixin WizardDetailsActions on Cubit<InvitationState>, WizardDeps {
  void nextStep();

  /// Creates the draft if there is none yet. False when it could not.
  Future<bool> ensureDraft() async {
    if (state.draftEventId != null || repository == null) return true;
    final created = await repository!.createDraft(
      eventTypeId: state.selectedEventType?.id,
      customTypeName: state.customEventTypeName,
      templateId: state.selectedTemplate?.id,
      institutionId: state.institutionId,
    );
    return created.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.toString()));
        return false;
      },
      (eventId) {
        emit(state.copyWith(draftEventId: eventId));
        return true;
      },
    );
  }

  /// Saves step 1 (creating the draft first), then moves to the guests.
  Future<void> createDraftAndSaveDetails() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    if (!await ensureDraft()) return;

    final eventId = state.draftEventId;
    if (repository != null && eventId != null) {
      final saved = await repository!.saveDetails(eventId, detailsToSend());
      if (saved.isLeft()) {
        return emit(state.copyWith(isLoading: false, errorMessage: saved.swap().getOrElse(() => throw 0).toString()));
      }
    }
    emit(state.copyWith(isLoading: false));
    nextStep();
  }

  WizardDetails detailsToSend() {
    final time = state.eventTime;
    // A place that was only typed has no pin: coordinates go out only for a
    // real pick inside Gaza (the backend refuses anything else).
    final place = state.customLocation;
    final pinned = place != null && place.isInGaza;

    return WizardDetails(
      title: state.eventName?.trim() ?? '',
      description: state.eventDescription,
      date: state.eventDate ?? DateTime.now().add(const Duration(days: 30)),
      time: time == null
          ? null
          : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      // Only business types send an end: on the start day, or on the last day.
      endDate: EventSetupRules.endDateTimeToSend(
        hasEndTime: state.selectedEventType?.hasEndTime == true,
        date: state.eventDate,
        start: state.eventTime,
        end: state.eventEndTime,
        lastDay: state.eventEndDate,
      ),
      venueId: state.selectedVenue?.id,
      place: place?.placeName,
      latitude: pinned ? place.latitude : null,
      longitude: pinned ? place.longitude : null,
      companions: state.partnerWithGuests,
      formValues: state.eventTypeFormData,
    );
  }
}
