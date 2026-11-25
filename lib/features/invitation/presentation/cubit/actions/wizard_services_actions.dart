
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/extra_service_model.dart';
import '../invitation_state.dart';
import 'wizard_deps.dart';

/// Step 4: extra services and their levels.
mixin WizardServicesActions on Cubit<InvitationState>, WizardDeps {
  /// Toggle service selection. With [optionId] the service is (re)selected at that level.
  void toggleService(ExtraServiceModel service, {int? optionId}) {
    final currentSelected = List<ExtraServiceModel>.from(state.selectedServices);
    final existingIndex = currentSelected.indexWhere((s) => s.id == service.id);

    if (existingIndex >= 0 && optionId == null) {
      currentSelected.removeAt(existingIndex);
    } else {
      final picked = service.copyWith(
        selectedOptionId: optionId ?? service.selectedOption?.id,
      );
      if (existingIndex >= 0) {
        currentSelected[existingIndex] = picked;
      } else {
        currentSelected.add(picked);
      }
    }

    emit(state.copyWith(selectedServices: currentSelected));
  }

  /// service id => picked level, sent with the selection (`service_options`).
  Map<String, int> serviceOptions() => {
        for (final s in state.selectedServices)
          if (s.selectedOption != null) '${s.id}': s.selectedOption!.id,
      };

  /// Load extra services from API
  Future<void> loadExtraServices() async {
    final eventId = state.draftEventId;
    if (repository == null || eventId == null) return emit(state.copyWith(availableServices: const []));
    emit(state.copyWith(isLoadingServices: true, servicesError: null));
    final result = await repository!.services(eventId);
    if (isClosed) return;
    emit(result.fold(
      (failure) => state.copyWith(isLoadingServices: false, servicesError: failure.toString()),
      (services) => state.copyWith(isLoadingServices: false, availableServices: services),
    ));
  }
}
