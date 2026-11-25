import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/location_model.dart';
import '../../../domain/entities/wizard_results.dart';
import '../../../domain/utils/event_setup_rules.dart';
import '../invitation_state.dart';
import 'wizard_deps.dart';
import 'wizard_type_actions.dart';

/// Opening the wizard: the catalogue, the owner and a draft being resumed.
mixin WizardStartActions on Cubit<InvitationState>, WizardDeps, WizardTypeActions {
  /// "Who is this occasion for?": null = the personal account, else the
  /// institution. Asked once, before the draft is created.
  void setEventOwner({int? institutionId, String? institutionName, int? credits}) {
    emit(
      institutionId == null
          ? state.copyWith(clearInstitution: true)
          : state.copyWith(
              institutionId: institutionId,
              institutionName: institutionName,
              institutionCredits: credits,
            ),
    );
  }

  /// Loads the occasions, then the draft when one is being resumed.
  Future<void> initializeWizard({int? draftEventId}) async {
    emit(state.copyWith(isLoading: true, draftEventId: draftEventId));
    final result = await repository?.catalogue();
    if (isClosed) return;
    final failure = result?.fold((f) => f, (_) => null);
    if (failure != null) return emit(state.copyWith(isLoading: false, errorMessage: failure.toString()));

    final catalogue = result?.getOrElse(() => const WizardCatalogue()) ?? const WizardCatalogue();
    emit(state.copyWith(
      isLoading: false,
      availableEventTypes: catalogue.types,
      availableEventTypeGroups: catalogue.groups,
    ));
    if (draftEventId != null) await loadDraftData(draftEventId);
  }

  /// Everything the host already entered, so a resumed draft starts where
  /// it stopped.
  Future<void> loadDraftData(int draftEventId) async {
    final result = await repository?.draft(draftEventId);
    if (result == null || isClosed) return;
    final draft = result.fold((_) => null, (d) => d);
    if (draft == null) return;

    // The catalogue entry knows its group; the saved one is the fallback.
    final type = state.availableEventTypes.where((t) => t.id == draft.typeId).firstOrNull ?? draft.type;
    final date = draft.date;
    final end = draft.endDate;
    final pinned = draft.latitude != null && draft.longitude != null;

    emit(state.copyWith(
      draftEventId: draft.id,
      eventName: draft.title,
      eventDescription: draft.description,
      eventDate: date,
      eventTime: date == null ? null : TimeOfDay.fromDateTime(date.toLocal()),
      eventEndTime: end == null ? null : TimeOfDay.fromDateTime(end.toLocal()),
      eventEndDate: end != null && date != null && EventSetupRules.isLaterDay(date, end) ? end : null,
      // The place comes back even without a pin, so it is never asked twice.
      customLocation: pinned || draft.place.isNotEmpty
          ? LocationModel(
              latitude: draft.latitude ?? 0,
              longitude: draft.longitude ?? 0,
              address: '',
              placeName: draft.place,
            )
          : null,
      partnerWithGuests: draft.companions,
      rsvpDeadline: draft.replyDeadline,
      invitationMessage: draft.message,
      generatedImageUrl: draft.designUrl,
      deliveryMethod: draft.deliveryMethod,
      requireResponse: draft.requireResponse,
      guests: draft.guests.isEmpty ? null : draft.guests,
      selectedEventType: type,
      eventTypeFormData: draft.formValues,
    ));
    if (type != null) await loadFormFieldsForType(type);
  }
}
