
import 'package:flutter_bloc/flutter_bloc.dart';

import '../invitation_state.dart';
import 'wizard_deps.dart';

/// Choosing the occasion: its type, its own fields and a starter design.
mixin WizardTypeActions on Cubit<InvitationState>, WizardDeps {
  /// Preselects an occasion type (and optionally a starter design) once the
  /// event types are loaded — used when a visitor picked a design in Explore
  /// before signing up. Unknown ids are ignored.
  Future<void> applyPreselection({int? eventTypeId, int? templateId}) async {
    if (eventTypeId == null) return;
    EventTypeModel? type;
    for (final t in state.availableEventTypes) {
      if (t.id == eventTypeId) {
        type = t;
        break;
      }
    }
    if (type == null) return;
    selectEventType(type);

    if (templateId == null) return;
    await loadTemplatesForEventType(eventTypeId);
    if (isClosed || state.selectedEventType?.id != eventTypeId) return;
    for (final t in state.availableTemplates) {
      if (t.id == templateId) {
        selectTemplate(t);
        break;
      }
    }
  }

  /// The ready designs of an occasion.
  Future<void> loadTemplatesForEventType(int eventTypeId) async {
    emit(state.copyWith(isLoadingTemplates: true));
    final result = await repository?.templates(eventTypeId);
    if (isClosed) return;
    emit(
      result == null
          ? state.copyWith(isLoadingTemplates: false, availableTemplates: const [])
          : result.fold(
              (failure) => state.copyWith(isLoadingTemplates: false, errorMessage: failure.toString()),
              (templates) => state.copyWith(isLoadingTemplates: false, availableTemplates: templates),
            ),
    );
  }

  /// Select an event type, then load its per-type detail fields.
  void selectEventType(EventTypeModel eventType) {
    emit(state.copyWith(
      selectedEventType: eventType,
      // Clear template selection when event type changes
      clearSelectedTemplate: true,
      availableTemplates: [],
      eventTypeFormFields: const [],
      isLoadingFormFields: false,
      // Clear previous form data when event type changes
      eventTypeFormData: const {},
    ));
    loadFormFieldsForType(eventType);
  }

  /// The fields of an occasion (they exist before any draft does). A custom
  /// occasion made by the client has none.
  Future<void> loadFormFieldsForType(EventTypeModel eventType) async {
    final typeId = eventType.id;
    if (repository == null || typeId == null || eventType.isClientCustom) return;
    emit(state.copyWith(isLoadingFormFields: true));
    final result = await repository!.typeFields(typeId);
    // The host may have switched occasion meanwhile.
    if (isClosed || state.selectedEventType?.id != typeId) return;
    emit(state.copyWith(isLoadingFormFields: false, eventTypeFormFields: result.getOrElse(() => const [])));
  }

  /// Set custom event type name (for custom type)
  void setCustomEventTypeName(String name) {
    emit(state.copyWith(
      customEventTypeName: name,
      selectedEventType: EventTypeModel.custom(name),
      // Custom types have no per-type detail fields.
      eventTypeFormFields: const [],
      eventTypeFormData: const {},
      isLoadingFormFields: false,
    ));
  }

  /// Select a template
  void selectTemplate(TemplateModel template) {
    emit(state.copyWith(selectedTemplate: template));
  }

  /// Clear selected template only (when using custom template)
  void clearSelectedTemplate() {
    emit(state.copyWith(clearSelectedTemplate: true));
  }
}
