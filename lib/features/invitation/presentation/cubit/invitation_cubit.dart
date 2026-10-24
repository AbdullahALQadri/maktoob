// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/event_wizard_api_service.dart';
import '../../../../core/error/free_trial_refusal.dart';
import '../../../../core/error/institution_errors.dart';
import '../../../../core/utils/phone_normalizer.dart';
import '../../../../core/utils/venue_text.dart';
import '../../data/models/extra_service_model.dart';
import '../../data/models/invitation_draft_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/location_model.dart';
import '../../data/services/excel_parser_service.dart';
import '../../data/services/invoice_generator.dart';
import '../../data/services/whatsapp_service.dart';
import '../../domain/utils/event_setup_rules.dart';
import 'invitation_state.dart';

/// Cubit for managing the 7-page event creation wizard
class InvitationCubit extends Cubit<InvitationState> {
  final EventWizardApiService? apiService;
  final ExcelParserService? excelParserService;
  final WhatsAppService? whatsAppService;
  final InvoiceGenerator? invoiceGenerator;

  InvitationCubit({
    this.apiService,
    this.excelParserService,
    this.whatsAppService,
    this.invoiceGenerator,
  }) : super(InvitationState.initial());

  // ============ Initialization ============

  /// Initialize the wizard, optionally with draft data
  /// "لمن هذه المناسبة؟": null = personal account, else the institution
  /// (owner or manager of an approved institution). Asked once, before the
  /// draft is created.
  void setEventOwner({int? institutionId, String? institutionName, int? credits}) {
    if (institutionId == null) {
      emit(state.copyWith(clearInstitution: true));
    } else {
      emit(state.copyWith(
        institutionId: institutionId,
        institutionName: institutionName,
        institutionCredits: credits,
      ));
    }
  }

  Future<void> initializeWizard({int? draftEventId}) async {
    emit(state.copyWith(
      isLoading: true,
      draftEventId: draftEventId,
    ));

    try {
      List<EventTypeModel> eventTypes;
      List<EventTypeGroupModel> groups = const [];

      if (apiService != null) {
        // Load event types from API
        final response = await apiService!.getEventTypes();
        final eventTypesData = (response['data']?['event_types'] as List?) ?? [];
        eventTypes = eventTypesData.map((e) => EventTypeModel.fromJson(e as Map<String, dynamic>)).toList();
        // Occasion groups for the two-step picker (absent on older backends).
        final groupsData = response['data']?['groups'];
        if (groupsData is List) {
          groups = groupsData
              .whereType<Map>()
              .map((g) => EventTypeGroupModel.fromJson(Map<String, dynamic>.from(g)))
              .toList();
        }
      } else {
        eventTypes = [];
      }

      emit(state.copyWith(
        isLoading: false,
        availableEventTypes: eventTypes,
        availableEventTypeGroups: groups,
      ));

      // If draft ID provided, load draft data
      if (draftEventId != null) {
        await _loadDraftData(draftEventId);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _loadDraftData(int draftEventId) async {
    if (apiService == null) return;

    try {
      final response = await apiService!.getWizardState(draftEventId);
      final data = response['data'];
      final eventData = data is Map ? data['event'] : null;
      if (eventData is! Map) return;

      // `title` / `description` are the unified columns (title_ar is legacy).
      final title = (eventData['title'] ?? eventData['title_ar'])?.toString();
      final description = eventData['description']?.toString();
      final date = DateTime.tryParse('${eventData['event_date'] ?? ''}');

      // Event type: prefer the loaded catalogue entry (has group info), fall
      // back to the eager-loaded `event_type` relation.
      final typeId = int.tryParse('${eventData['event_type_id'] ?? ''}');
      EventTypeModel? type;
      if (typeId != null) {
        for (final t in state.availableEventTypes) {
          if (t.id == typeId) {
            type = t;
            break;
          }
        }
        final rel = eventData['event_type'];
        if (type == null && rel is Map) {
          type = EventTypeModel.fromJson(Map<String, dynamic>.from(rel));
        }
      }

      // Saved per-type answers. PHP serialises an empty array as `[]`.
      final rawValues = eventData['event_type_form_values'];
      final formValues = rawValues is Map
          ? rawValues.map((k, v) => MapEntry('$k', v))
          : <String, dynamic>{};

      // Everything else the host already entered, so resuming a draft
      // doesn't make them start over.
      final endDate = DateTime.tryParse('${eventData['end_date'] ?? ''}');
      final lat = double.tryParse('${eventData['custom_venue_lat'] ?? ''}');
      final lng = double.tryParse('${eventData['custom_venue_lng'] ?? ''}');
      final venueLine = VenueText.line(
        eventData['custom_venue_name_ar']?.toString(),
        eventData['custom_venue_address_ar']?.toString(),
      );
      final partners = int.tryParse('${eventData['partner_count'] ?? eventData['max_companions'] ?? ''}');
      final deadline = DateTime.tryParse('${eventData['response_deadline'] ?? ''}');
      final message = eventData['message_ar']?.toString();
      final drafts = eventData['draft_guests'];
      final guests = <GuestInfoModel>[
        if (drafts is List)
          for (final g in drafts.whereType<Map>())
            if (g['is_duplicate'] != true && g['is_duplicate'] != 1)
              GuestInfoModel(name: '${g['guest_name'] ?? ''}', phone: '${g['phone'] ?? ''}'),
      ];

      final rawId = eventData['id'];
      emit(state.copyWith(
        draftEventId: rawId is int ? rawId : int.tryParse('$rawId') ?? draftEventId,
        eventName: title,
        eventDescription: description,
        eventDate: date,
        eventTime: date == null ? null : TimeOfDay.fromDateTime(date.toLocal()),
        eventEndTime: endDate == null ? null : TimeOfDay.fromDateTime(endDate.toLocal()),
        // The place comes back even without a pin, so a resumed draft never
        // asks for it again.
        customLocation: (lat != null && lng != null) || venueLine.isNotEmpty
            ? LocationModel(
                latitude: lat ?? 0,
                longitude: lng ?? 0,
                address: '',
                placeName: venueLine,
              )
            : null,
        partnerWithGuests: partners != null && partners > 0 ? partners : null,
        rsvpDeadline: deadline,
        invitationMessage: (message ?? '').isEmpty ? null : message,
        guests: guests.isEmpty ? null : guests,
        selectedEventType: type,
        eventTypeFormData: formValues,
      ));

      if (type != null) {
        await loadFormFieldsForType(type);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

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

  /// Load templates for selected event type
  Future<void> loadTemplatesForEventType(int eventTypeId) async {
    emit(state.copyWith(isLoadingTemplates: true));

    try {
      List<TemplateModel> templates;

      if (apiService != null) {
        final response = await apiService!.getTemplatesForEventType(eventTypeId);
        final templatesData = (response['data']?['templates'] as List?) ?? [];
        templates = templatesData.map((t) => TemplateModel.fromJson(t as Map<String, dynamic>)).toList();
      } else {
        templates = [];
      }

      emit(state.copyWith(
        isLoadingTemplates: false,
        availableTemplates: templates,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingTemplates: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ============ Navigation ============

  /// Create draft event on server and proceed to next step (from Page 1)
  /// This should be called when user clicks "Next" on Page 1
  /// Initialize draft event without proceeding to next step.
  /// Used by AI Design Studio when the user opens it before filling all details.
  Future<void> initializeWizardIfNeeded() async {
    if (state.draftEventId != null) return; // already created

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      if (apiService != null) {
        final response = await apiService!.initializeWizard(
          eventTypeId: state.selectedEventType?.id,
          customEventTypeName: state.customEventTypeName,
          institutionId: state.institutionId,
        );
        final eventId = response['data']?['event_id'] as int?;
        emit(state.copyWith(
          isLoading: false,
          draftEventId: eventId,
          errorMessage: eventId == null ? 'invitation_failed_create_draft' : null,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> createDraftAndProceed() async {
    // Skip if already has draft
    if (state.draftEventId != null) {
      nextStep();
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (apiService != null) {
        // Call API to create draft event
        final response = await apiService!.initializeWizard(
          eventTypeId: state.selectedEventType?.id,
          customEventTypeName: state.customEventTypeName,
          templateId: state.selectedTemplate?.id,
          institutionId: state.institutionId,
        );

        final eventId = response['data']?['event_id'] as int?;
        if (eventId != null) {
          emit(state.copyWith(
            isLoading: false,
            draftEventId: eventId,
          ));
          nextStep();
        } else {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'invitation_failed_create_draft',
          ));
        }
      } else {
        // No API service, just proceed locally
        emit(state.copyWith(isLoading: false));
        nextStep();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Create draft + save details in one step, then proceed (3-page wizard Page 1)
  Future<void> createDraftAndSaveDetails() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Step 1: Create draft if needed
      if (state.draftEventId == null && apiService != null) {
        final response = await apiService!.initializeWizard(
          eventTypeId: state.selectedEventType?.id,
          customEventTypeName: state.customEventTypeName,
          templateId: state.selectedTemplate?.id,
          institutionId: state.institutionId,
        );
        final eventId = response['data']?['event_id'] as int?;
        if (eventId != null) {
          emit(state.copyWith(draftEventId: eventId));
        } else {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'invitation_failed_create_draft',
          ));
          return;
        }
      }

      // Step 2: Save event details
      if (apiService != null && state.draftEventId != null) {
        await _callSaveEventDetails(state.draftEventId!);
      }

      emit(state.copyWith(isLoading: false));
      nextStep();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _callSaveEventDetails(int eventId) {
    String? formatTimeOfDay(TimeOfDay? t) => t == null
        ? null
        : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    // Page 1 fabricates a LocationModel with 0/0 coordinates when the user only
    // types a location name instead of picking one on the map. The backend
    // validates custom_venue_lat/lng against the Gaza bounding box, so 0/0 comes
    // back as a 422. Send coordinates only when they are a real Gaza pick; the
    // typed name still goes through as custom_venue_name_ar/address.
    final loc = state.customLocation;
    final hasCoords = loc != null && loc.isInGaza;

    return apiService!.saveEventDetails(
      eventId,
      // Empty title -> the backend writes one from the occasion's names.
      titleAr: state.eventName?.trim() ?? '',
      titleEn: null,
      descriptionAr: state.eventDescription,
      eventDate: state.eventDate ?? DateTime.now().add(const Duration(days: 30)),
      eventTime: formatTimeOfDay(state.eventTime),
      // Only business types (has_end_time) send an end: same day + end time.
      eventEndDate: EventSetupRules.endDateTimeToSend(
        hasEndTime: state.selectedEventType?.hasEndTime == true,
        date: state.eventDate,
        start: state.eventTime,
        end: state.eventEndTime,
      ),
      eventEndTime: null,
      venueId: state.selectedVenue?.id,
      customVenueNameAr: state.customLocation?.placeName,
      // The place is asked once: the typed line holds all of it, so an older
      // separate address (folded into the line on resume) is cleared.
      customVenueAddressAr: state.customLocation == null ? null : '',
      customVenueLat: hasCoords ? loc.latitude : null,
      customVenueLng: hasCoords ? loc.longitude : null,
      partnerCount: state.partnerWithGuests,
      eventTypeFormValues: state.eventTypeFormData,
    );
  }

  /// Save guests + services in one step, then proceed (3-page wizard Page 2)
  Future<void> saveGuestsAndServicesAndProceed() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (apiService != null && state.draftEventId != null) {
        // Save guests
        // Always sync, so removing every guest clears them server-side too.
        await apiService!.addManualGuests(
          state.draftEventId!,
          state.guests.map((g) => {
            'name': g.name,
            'phone': g.phone,
          }).toList(),
        );

        // Save services
        if (state.selectedServices.isNotEmpty) {
          await apiService!.saveExtraServices(
            state.draftEventId!,
            state.selectedServices.map((s) => s.id).toList(),
            options: _serviceOptions(),
          );
        }
      }

      emit(state.copyWith(isLoading: false));
      nextStep();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Save event details and proceed to next step (from Page 2)
  Future<void> saveDetailsAndProceed() async {
    if (state.draftEventId == null) {
      nextStep();
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (apiService != null) {
        await _callSaveEventDetails(state.draftEventId!);
      }

      emit(state.copyWith(isLoading: false));
      nextStep();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Save guests and proceed to next step (from Page 4)
  Future<void> saveGuestsAndProceed() async {
    if (state.draftEventId == null || state.guests.isEmpty) {
      nextStep();
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (apiService != null) {
        await apiService!.addManualGuests(
          state.draftEventId!,
          state.guests.map((g) => {
            'name': g.name,
            'phone': g.phone,
          }).toList(),
        );
      }

      emit(state.copyWith(isLoading: false));
      nextStep();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Save services and proceed to next step (from Page 5)
  Future<void> saveServicesAndProceed() async {
    if (state.draftEventId == null) {
      nextStep();
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (apiService != null && state.selectedServices.isNotEmpty) {
        await apiService!.saveExtraServices(
          state.draftEventId!,
          state.selectedServices.map((s) => s.id).toList(),
          options: _serviceOptions(),
        );
      }

      emit(state.copyWith(isLoading: false));
      nextStep();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Save package selection and proceed to next step (from Page 6)
  Future<void> savePackageAndProceed() async {
    if (state.draftEventId == null || state.selectedPackage == null) {
      nextStep();
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      if (apiService != null) {
        await apiService!.selectPackage(
          state.draftEventId!,
          packageId: state.selectedPackage!.isCustom ? null : state.selectedPackage!.id,
          isCustomPackage: state.selectedPackage!.isCustom,
          customGuestCount: state.selectedPackage!.isCustom ? state.customPackageLimit : null,
        );
      }

      emit(state.copyWith(isLoading: false));
      nextStep();
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Navigate to the next step (3-page wizard)
  void nextStep() {
    final nextStepMap = {
      // Modern 3-page wizard
      InvitationStep.eventSetup: InvitationStep.guestsAndServices,
      InvitationStep.guestsAndServices: InvitationStep.reviewAndSubmit,
      InvitationStep.reviewAndSubmit: InvitationStep.reviewAndSubmit,
      // Legacy steps → redirect to modern equivalents
      InvitationStep.eventTypeSelection: InvitationStep.guestsAndServices,
      InvitationStep.eventDetails: InvitationStep.guestsAndServices,
      InvitationStep.invitationPreview: InvitationStep.guestsAndServices,
      InvitationStep.guestManagement: InvitationStep.reviewAndSubmit,
      InvitationStep.extraServices: InvitationStep.reviewAndSubmit,
      InvitationStep.packageSelection: InvitationStep.reviewAndSubmit,
      InvitationStep.invoiceSummary: InvitationStep.reviewAndSubmit,
      InvitationStep.landing: InvitationStep.eventSetup,
      InvitationStep.eventType: InvitationStep.eventSetup,
      InvitationStep.creation: InvitationStep.guestsAndServices,
      InvitationStep.guests: InvitationStep.reviewAndSubmit,
      InvitationStep.share: InvitationStep.reviewAndSubmit,
      InvitationStep.package: InvitationStep.reviewAndSubmit,
      InvitationStep.payment: InvitationStep.reviewAndSubmit,
      InvitationStep.confirmation: InvitationStep.reviewAndSubmit,
    };

    final next = nextStepMap[state.currentStep];
    if (next != null) {
      emit(state.copyWith(currentStep: next));
    }
  }

  /// Navigate to the previous step (3-page wizard)
  void previousStep() {
    final prevStepMap = {
      // Modern 3-page wizard
      InvitationStep.eventSetup: InvitationStep.eventSetup,
      InvitationStep.guestsAndServices: InvitationStep.eventSetup,
      InvitationStep.reviewAndSubmit: InvitationStep.guestsAndServices,
      // Legacy steps → redirect to modern equivalents
      InvitationStep.eventTypeSelection: InvitationStep.eventSetup,
      InvitationStep.eventDetails: InvitationStep.eventSetup,
      InvitationStep.invitationPreview: InvitationStep.eventSetup,
      InvitationStep.guestManagement: InvitationStep.eventSetup,
      InvitationStep.extraServices: InvitationStep.eventSetup,
      InvitationStep.packageSelection: InvitationStep.guestsAndServices,
      InvitationStep.invoiceSummary: InvitationStep.guestsAndServices,
      InvitationStep.landing: InvitationStep.eventSetup,
      InvitationStep.eventType: InvitationStep.eventSetup,
      InvitationStep.creation: InvitationStep.eventSetup,
      InvitationStep.guests: InvitationStep.eventSetup,
      InvitationStep.share: InvitationStep.guestsAndServices,
      InvitationStep.package: InvitationStep.guestsAndServices,
      InvitationStep.payment: InvitationStep.guestsAndServices,
      InvitationStep.confirmation: InvitationStep.guestsAndServices,
    };

    final prev = prevStepMap[state.currentStep];
    if (prev != null) {
      emit(state.copyWith(currentStep: prev));
    }
  }

  /// Go to a specific step
  void goToStep(InvitationStep step) {
    emit(state.copyWith(currentStep: step));
  }

  // ============ Page 1: Event Type Selection ============

  /// Set available event types from API
  void setAvailableEventTypes(List<EventTypeModel> eventTypes) {
    emit(state.copyWith(availableEventTypes: eventTypes));
  }

  /// Select an event type, then load its per-type detail fields.
  void selectEventType(EventTypeModel eventType) {
    emit(state.copyWith(
      selectedEventType: eventType,
      // Clear template selection when event type changes
      clearSelectedTemplate: true,
      clearUploadedTemplate: true,
      availableTemplates: [],
      eventTypeFormFields: const [],
      isLoadingFormFields: false,
      // Clear previous form data when event type changes
      eventTypeFormData: const {},
    ));
    loadFormFieldsForType(eventType);
  }

  /// Load the detail fields of [eventType] by type id (works before a draft
  /// event exists). Client custom types have no fields.
  Future<void> loadFormFieldsForType(EventTypeModel eventType) async {
    final typeId = eventType.id;
    if (apiService == null || typeId == null || eventType.isClientCustom) {
      return;
    }
    emit(state.copyWith(isLoadingFormFields: true));
    try {
      final response = await apiService!.getAiFormFields(typeId);
      final fields = EventTypeFormField.listFromJson(response['data']?['fields']);
      // Ignore stale responses if the user switched type meanwhile.
      if (state.selectedEventType?.id != typeId) return;
      emit(state.copyWith(isLoadingFormFields: false, eventTypeFormFields: fields));
    } catch (_) {
      if (state.selectedEventType?.id != typeId) return;
      emit(state.copyWith(isLoadingFormFields: false, eventTypeFormFields: const []));
    }
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

  /// Set available templates from API
  void setAvailableTemplates(List<TemplateModel> templates) {
    emit(state.copyWith(availableTemplates: templates));
  }

  /// Select a template
  void selectTemplate(TemplateModel template) {
    emit(state.copyWith(
      selectedTemplate: template,
      clearUploadedTemplate: true,
    ));
  }

  /// Upload custom template file
  void uploadCustomTemplate(File file) {
    emit(state.copyWith(
      uploadedTemplateFile: file,
      selectedTemplate: TemplateModel.customPlaceholder(),
    ));
  }

  /// Set custom template description
  void setCustomTemplateDescription(String description) {
    emit(state.copyWith(uploadedTemplateDescription: description));
  }

  /// Clear uploaded template
  void clearUploadedTemplate() {
    emit(state.copyWith(
      clearUploadedTemplate: true,
      clearUploadedTemplateDescription: true,
    ));
  }

  /// Clear all custom template data (file, description, and template selection)
  void clearCustomTemplate() {
    emit(state.copyWith(
      clearUploadedTemplate: true,
      clearSelectedTemplate: true,
      clearUploadedTemplateDescription: true,
    ));
  }

  /// Clear uploaded template file only
  void clearUploadedTemplateFile() {
    emit(state.copyWith(clearUploadedTemplate: true));
  }

  /// Clear custom template description only
  void clearCustomTemplateDescription() {
    emit(state.copyWith(clearUploadedTemplateDescription: true));
  }

  /// Clear selected template only (when using custom template)
  void clearSelectedTemplate() {
    emit(state.copyWith(clearSelectedTemplate: true));
  }

  // ============ Page 2: Event Details ============

  /// Update event name
  void updateEventName(String name) {
    emit(state.copyWith(eventName: name));
  }

  /// Update event description
  void updateEventDescription(String? description) {
    emit(state.copyWith(eventDescription: description));
  }

  /// Update event date
  void updateDate(DateTime date) {
    emit(state.copyWith(eventDate: date));
  }

  /// Update event time
  void updateTime(TimeOfDay time) {
    emit(state.copyWith(eventTime: time));
  }

  /// Update event end date (optional — null means no explicit end).
  void updateEndDate(DateTime date) {
    emit(state.copyWith(eventEndDate: date));
  }

  /// Update event end time (optional).
  void updateEndTime(TimeOfDay time) {
    emit(state.copyWith(eventEndTime: time));
  }

  /// Set available venues from API
  void setAvailableVenues(List<VenueModel> venues) {
    emit(state.copyWith(availableVenues: venues));
  }

  /// Select a venue
  void selectVenue(VenueModel venue) {
    emit(state.copyWith(
      selectedVenue: venue,
      clearCustomLocation: true,
    ));
  }

  /// Clear selected venue
  void clearVenue() {
    emit(state.copyWith(clearSelectedVenue: true));
  }

  /// Clear custom location
  void clearLocation() {
    emit(state.copyWith(clearCustomLocation: true));
  }

  /// Set custom location from Google Maps
  void setCustomLocation(LocationModel location) {
    emit(state.copyWith(
      customLocation: location,
      clearSelectedVenue: true,
    ));
  }

  /// Update partner with guests count
  void updateRsvpDeadline(DateTime? date) {
    emit(date == null
        ? state.copyWith(clearRsvpDeadline: true)
        : state.copyWith(rsvpDeadline: date));
  }

  void updateInvitationMessage(String message) {
    emit(state.copyWith(invitationMessage: message));
  }

  void updatePartnerWithGuests(int? count) {
    if (count == null) {
      emit(state.copyWith(clearPartnerWithGuests: true));
    } else {
      emit(state.copyWith(partnerWithGuests: count));
    }
  }

  /// Set event type form fields from API
  void setEventTypeFormFields(List<EventTypeFormField> fields) {
    emit(state.copyWith(eventTypeFormFields: fields));
  }

  /// Update event type form field value
  void updateEventTypeFormField(String key, dynamic value) {
    final newFormData = Map<String, dynamic>.from(state.eventTypeFormData);
    newFormData[key] = value;
    emit(state.copyWith(eventTypeFormData: newFormData));
  }

  // ============ Page 3: Preview ============

  /// Set preview image URL from API
  void setPreviewImageUrl(String? url) {
    emit(state.copyWith(previewImageUrl: url));
  }

  // ============ Page 4: Guest Management ============

  /// Add guests from mobile contacts
  void addContactGuests(List<GuestInfoModel> contactGuests) {
    emit(state.copyWith(
      contactsGuests: contactGuests,
    ));
    _mergeAndDeduplicateGuests();
  }

  /// Add guests from Excel file
  Future<ExcelParseResult?> addExcelGuests(File excelFile) async {
    if (excelParserService == null) return null;

    emit(state.copyWith(status: InvitationStatus.loading));

    final result = await excelParserService!.parseExcelFile(excelFile);

    emit(state.copyWith(
      status: InvitationStatus.success,
      excelGuests: result.guests,
    ));

    _mergeAndDeduplicateGuests();
    return result;
  }

  /// Add a manual guest
  void addManualGuest(GuestInfoModel guest) {
    final newManualGuests = List<GuestInfoModel>.from(state.manualGuests)
      ..add(guest.copyWith(source: GuestSource.manual));

    emit(state.copyWith(manualGuests: newManualGuests));
    _mergeAndDeduplicateGuests();
  }

  /// Update current guest input
  void updateCurrentGuestName(String name) {
    emit(state.copyWith(
      currentGuestInput: state.currentGuestInput.copyWith(name: name),
    ));
  }

  void updateCurrentGuestPhone(String phone) {
    emit(state.copyWith(
      currentGuestInput: state.currentGuestInput.copyWith(phone: phone),
    ));
  }

  void updateCurrentGuestEmail(String email) {
    emit(state.copyWith(
      currentGuestInput: state.currentGuestInput.copyWith(email: email),
    ));
  }

  /// Add current guest to list and reset input
  void addCurrentGuest() {
    if (!state.currentGuestInput.isValid) return;

    addManualGuest(state.currentGuestInput);
    emit(state.copyWith(
      currentGuestInput: const GuestInfoModel(name: ''),
    ));
  }

  /// Remove a guest by index
  void removeGuest(int index) {
    if (index < 0 || index >= state.guests.length) return;

    final guestToRemove = state.guests[index];
    final phone = guestToRemove.normalizedPhone;

    // Remove from appropriate source list
    switch (guestToRemove.source) {
      case GuestSource.contacts:
        final newContacts = List<GuestInfoModel>.from(state.contactsGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(contactsGuests: newContacts));
        break;
      case GuestSource.excel:
        final newExcel = List<GuestInfoModel>.from(state.excelGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(excelGuests: newExcel));
        break;
      case GuestSource.manual:
        final newManual = List<GuestInfoModel>.from(state.manualGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(manualGuests: newManual));
        break;
    }

    _mergeAndDeduplicateGuests();
  }

  /// Remove a guest from contacts list
  void removeContactGuest(String phone) {
    final normalizedPhone = _normalizePhone(phone);
    final newContacts = List<GuestInfoModel>.from(state.contactsGuests)
      ..removeWhere((g) => g.normalizedPhone == normalizedPhone);
    emit(state.copyWith(contactsGuests: newContacts));
    _mergeAndDeduplicateGuests();
  }

  /// Clear all guests
  void clearAllGuests() {
    emit(state.copyWith(
      guests: [],
      contactsGuests: [],
      excelGuests: [],
      manualGuests: [],
      duplicatePhoneNumbers: {},
    ));
  }

  /// Alias for clearAllGuests (backward compatibility)
  @Deprecated('Use clearAllGuests instead')
  void clearGuests() => clearAllGuests();

  /// Alias for addManualGuest (backward compatibility)
  @Deprecated('Use addManualGuest instead')
  void addGuestDirect(GuestInfoModel guest) => addManualGuest(guest);

  /// Merge guests from all sources and remove duplicates
  /// Priority: manual > excel > contacts
  void _mergeAndDeduplicateGuests() {
    final phoneMap = <String, GuestInfoModel>{};
    final duplicates = <String>{};

    // Add manual guests first (highest priority)
    for (final guest in state.manualGuests) {
      final phone = guest.normalizedPhone;
      if (phone.isNotEmpty) {
        phoneMap[phone] = guest;
      }
    }

    // Add excel guests (medium priority)
    for (final guest in state.excelGuests) {
      final phone = guest.normalizedPhone;
      if (phone.isNotEmpty) {
        if (phoneMap.containsKey(phone)) {
          duplicates.add(phone);
        } else {
          phoneMap[phone] = guest;
        }
      }
    }

    // Add contacts guests (lowest priority)
    for (final guest in state.contactsGuests) {
      final phone = guest.normalizedPhone;
      if (phone.isNotEmpty) {
        if (phoneMap.containsKey(phone)) {
          duplicates.add(phone);
        } else {
          phoneMap[phone] = guest;
        }
      }
    }

    emit(state.copyWith(
      guests: phoneMap.values.toList(),
      duplicatePhoneNumbers: duplicates,
    ));
  }

  String _normalizePhone(String phone) => PhoneNormalizer.normalize(phone);

  // ============ Page 5: Extra Services ============

  /// Set available services from API
  void setAvailableServices(List<ExtraServiceModel> services) {
    emit(state.copyWith(availableServices: services));
  }

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
  Map<String, int> _serviceOptions() => {
        for (final s in state.selectedServices)
          if (s.selectedOption != null) '${s.id}': s.selectedOption!.id,
      };

  /// Check if a service is selected
  bool isServiceSelected(int serviceId) {
    return state.selectedServices.any((s) => s.id == serviceId);
  }

  // ============ Page 6: Package Selection ============

  /// Set available packages from API
  void setAvailablePackages(List<PackageModel> packages) {
    emit(state.copyWith(availablePackages: packages));
  }

  /// Select a package. Tapping the selected package again deselects it.
  /// The choice stays changeable until payment: the backend's
  /// `POST {id}/package` replaces (or clears) the previous selection.
  void selectPackage(PackageModel package) {
    if (!package.isAvailable) return;
    if (state.selectedPackage?.id == package.id) {
      clearPackage();
      return;
    }
    emit(state.copyWith(
      selectedPackage: package,
      packageValidationError: false,
    ));
  }

  /// Drop the current package choice (locally and on the draft event) so
  /// the host can pick another one.
  Future<void> clearPackage() async {
    emit(state.copyWith(
      clearSelectedPackage: true,
      packageValidationError: false,
    ));
    final eventId = state.draftEventId;
    if (apiService == null || eventId == null) return;
    try {
      await apiService!.selectPackage(eventId, packageId: null);
    } catch (e) {
      // Best effort: the final submit re-sends the chosen package anyway.
      debugPrint('clearPackage: $e');
    }
  }

  /// Set custom package invitation limit
  void setCustomPackageLimit(int limit) {
    emit(state.copyWith(customPackageLimit: limit));
    calculateCustomPackagePrice(limit);
  }

  /// Set custom package price (from API)
  void setCustomPackagePrice(double price) {
    emit(state.copyWith(customPackagePrice: price));
  }

  /// Clear the package validation error flag (after dialog is shown)
  void clearPackageValidationError() {
    emit(state.copyWith(packageValidationError: false));
  }

  /// Validate package limit against guest count
  void _validatePackageLimit() {
    if (state.selectedPackage == null) return;

    final isExceeded = state.isPackageLimitExceeded;
    if (state.packageValidationError != isExceeded) {
      emit(state.copyWith(packageValidationError: isExceeded));
    }
  }

  /// Check if can proceed from package selection
  bool validatePackageSelection() {
    _validatePackageLimit();
    return state.canProceedFromPackage;
  }

  // ============ Page 7: Invoice & Save ============

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
    emit(state.copyWith(whatsappNumber: _nonBlank(number)));
  }

  /// A blank number from the API (unset setting) is "no number", not "".
  static String? _nonBlank(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  /// Save as draft
  Future<void> saveDraft() async {
    emit(state.copyWith(
      isSaving: true,
      isSaveAsDraft: true,
      saveSuccess: false,
      saveError: null,
    ));

    try {
      if (apiService != null && state.draftEventId != null) {
        final eventId = state.draftEventId!;

        // Persist what the user has entered so far, so resuming the draft
        // shows it (the save call alone only flips the status).
        await _callSaveEventDetails(eventId);
        // Always sync, so removing every guest clears them server-side too.
        await apiService!.addManualGuests(
          eventId,
          state.guests.map((g) => {'name': g.name, 'phone': g.phone}).toList(),
        );

        final response = await apiService!.saveEvent(eventId, isDraft: true);

        // Backend returns `data` = the event itself (no nested `event` key).
        final data = response['data'];
        final savedId = (data is Map ? (data['event']?['id'] ?? data['id']) : null) ?? eventId;

        emit(state.copyWith(
          isSaving: false,
          saveSuccess: true,
          isSaveAsDraft: true,
          status: InvitationStatus.success,
          savedEventId: savedId.toString(),
        ));
      } else {
        // Fallback for when no API service
        emit(state.copyWith(
          isSaving: false,
          saveSuccess: true,
          isSaveAsDraft: true,
          status: InvitationStatus.success,
          savedEventId: 'draft_${DateTime.now().millisecondsSinceEpoch}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        saveSuccess: false,
        saveError: e.toString(),
        status: InvitationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Save and submit invitation
  Future<void> saveAndSubmit() async {
    emit(state.copyWith(status: InvitationStatus.loading));

    try {
      // Generate invoice summary if not done
      if (state.invoiceSummary == null) {
        generateInvoiceSummary();
      }

      if (apiService != null) {
        int eventId;

        // Step 1: Initialize wizard if no draft exists
        if (state.draftEventId == null) {
          final initResponse = await apiService!.initializeWizard(
            eventTypeId: state.selectedEventType?.id,
            customEventTypeName: state.customEventTypeName,
            templateId: state.selectedTemplate?.id,
            institutionId: state.institutionId,
          );
          eventId = initResponse['data']?['event_id'] as int? ?? 0;
          emit(state.copyWith(draftEventId: eventId));
        } else {
          eventId = state.draftEventId!;
        }

        // Step 2: Save event details
        await _callSaveEventDetails(eventId);

        // Step 3: Add guests
        // Always sync, so removing every guest clears them server-side too.
        await apiService!.addManualGuests(
          eventId,
          state.guests.map((g) => {
            'name': g.name,
            'phone': g.phone,
          }).toList(),
        );

        // Step 4: Save invitation configuration
        final hasCompanions = state.partnerWithGuests != null && state.partnerWithGuests! > 0;
        await apiService!.saveInvitationConfig(
          eventId,
          defaultDeliveryMethod: 'whatsapp',
          allowCompanions: hasCompanions,
          maxCompanions: hasCompanions ? state.partnerWithGuests! : 0,
          requireResponse: true,
          responseDeadline: state.rsvpDeadline,
          // Sent only when typed; otherwise the saved message is kept.
          messageAr: (state.invitationMessage ?? '').trim().isEmpty
              ? null
              : state.invitationMessage!.trim(),
        );

        // Step 5: Save extra services
        if (state.selectedServices.isNotEmpty) {
          await apiService!.saveExtraServices(
            eventId,
            state.selectedServices.map((s) => s.id).toList(),
            options: _serviceOptions(),
          );
        }

        // Step 6: Select package
        if (state.selectedPackage != null) {
          await apiService!.selectPackage(
            eventId,
            packageId: state.selectedPackage!.isCustom ? null : state.selectedPackage!.id,
            isCustomPackage: state.selectedPackage!.isCustom,
            customGuestCount: state.selectedPackage!.isCustom ? state.customPackageLimit : null,
          );
        }

        // Step 7: Final save
        await apiService!.saveEvent(eventId, isDraft: false);

        emit(state.copyWith(
          status: InvitationStatus.success,
          savedEventId: eventId.toString(),
          invitationId: eventId.toString(),
        ));
      } else {
        // Fallback for when no API service
        final eventId = 'EVT-${DateTime.now().millisecondsSinceEpoch}';
        emit(state.copyWith(
          status: InvitationStatus.success,
          savedEventId: eventId,
          invitationId: eventId,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Generate invoice image and open WhatsApp
  Future<void> openWhatsAppWithInvoice() async {
    if (whatsAppService == null || invoiceGenerator == null) return;
    if (state.whatsappNumber == null) return;

    emit(state.copyWith(status: InvitationStatus.loading));

    try {
      // Generate invoice image
      final invoiceImageFile = await invoiceGenerator!.generateInvoiceImage(
        invoice: state.invoiceSummary ?? InvoiceSummaryModel.empty(),
        eventName: state.eventName ?? '',
        packageName: state.selectedPackage?.name ?? '',
        guestCount: state.totalGuestCount,
        eventType: state.selectedEventType?.name,
      );

      emit(state.copyWith(generatedInvoiceImage: invoiceImageFile));

      // Read file bytes for WhatsApp sharing
      final invoiceImageBytes = await invoiceImageFile.readAsBytes();

      // Generate message
      final message = whatsAppService!.generateInvoiceMessage(
        eventName: state.eventName ?? '',
        packageName: state.selectedPackage?.name ?? '',
        totalPrice: state.invoiceSummary?.totalPrice ?? 0,
        guestCount: state.totalGuestCount,
      );

      // Open WhatsApp
      await whatsAppService!.openWhatsAppWithInvoice(
        phoneNumber: state.whatsappNumber!,
        invoiceImage: invoiceImageBytes,
        message: message,
      );

      emit(state.copyWith(status: InvitationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ============ Utility Methods ============

  /// Reset state
  void reset() {
    emit(InvitationState.initial());
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Check if loading
  bool get isLoading => state.status == InvitationStatus.loading;

  // ============ AI Image Generation ============

  // Legacy generateAiImage and _pollGenerationStatus removed.
  // AI image generation now lives in `AiDesignCubit` which uses FCM push
  // (with polling fallback at 8s) instead of polling every 3 seconds.

  /// Register the AI-generated image URL into wizard state so the
  /// "Continue to Guests" button can enable.
  void setAiGeneratedImage(String url, {int? imageId}) {
    emit(state.copyWith(
      generatedImageUrl: url,
      generatingImageId: imageId,
      previewImageUrl:   url, // also feed the legacy preview slot
    ));
  }

  /// Clear the AI-generated image (e.g. user wants to regenerate)
  void clearAiGeneratedImage() {
    emit(state.copyWith(
      clearGeneratedImage: true,
    ));
  }

  // ============ Page 3: Load Preview ============

  /// Load preview from API
  Future<void> loadPreview() async {
    emit(state.copyWith(
      isLoadingPreview: true,
      previewError: null,
    ));

    try {
      String? previewUrl;

      if (apiService != null && state.draftEventId != null) {
        final response = await apiService!.getInvitationPreview(state.draftEventId!);
        final data = response['data'];
        previewUrl = data['preview_url'];
      } else {
        previewUrl = null;
      }

      emit(state.copyWith(
        isLoadingPreview: false,
        previewImageUrl: previewUrl,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingPreview: false,
        previewError: e.toString(),
      ));
    }
  }

  // ============ Page 4: Excel Import ============

  /// Import guests from Excel file
  Future<void> importGuestsFromExcel(File file) async {
    emit(state.copyWith(isLoadingExcel: true));

    try {
      if (excelParserService != null) {
        final result = await excelParserService!.parseExcelFile(file);
        emit(state.copyWith(
          isLoadingExcel: false,
          excelGuests: result.guests,
        ));
        _mergeAndDeduplicateGuests();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingExcel: false,
        errorMessage: 'invitation_excel_read_error',
      ));
    }
  }

  /// Remove a guest by object reference (alias for removeGuestByModel)
  void removeGuestByModel(GuestInfoModel guest) {
    final phone = guest.normalizedPhone;

    switch (guest.source) {
      case GuestSource.contacts:
        final newContacts = List<GuestInfoModel>.from(state.contactsGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(contactsGuests: newContacts));
        break;
      case GuestSource.excel:
        final newExcel = List<GuestInfoModel>.from(state.excelGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(excelGuests: newExcel));
        break;
      case GuestSource.manual:
        final newManual = List<GuestInfoModel>.from(state.manualGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(manualGuests: newManual));
        break;
    }

    _mergeAndDeduplicateGuests();
  }

  /// Clear duplicate notification
  void clearDuplicateNotification() {
    emit(state.copyWith(duplicatePhoneNumbers: {}));
  }

  // ============ Page 5: Load Services ============

  /// Load extra services from API
  Future<void> loadExtraServices() async {
    emit(state.copyWith(
      isLoadingServices: true,
      servicesError: null,
    ));

    try {
      List<ExtraServiceModel> services;

      if (apiService != null && state.draftEventId != null) {
        final response = await apiService!.getExtraServices(state.draftEventId!);
        final servicesData = response['data']['services'] as List? ?? [];
        services = servicesData.map((s) => ExtraServiceModel.fromJson(s)).toList();
      } else {
        services = [];
      }

      emit(state.copyWith(
        isLoadingServices: false,
        availableServices: services,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingServices: false,
        servicesError: e.toString(),
      ));
    }
  }

  // ============ Page 6: Load Packages ============

  /// Load packages from API
  Future<void> loadPackages() async {
    emit(state.copyWith(
      isLoadingPackages: true,
      packagesError: null,
    ));

    try {
      List<PackageModel> packages;
      bool freeTrialAvailable = true;
      int? suggestedPackageId;

      if (apiService != null && state.draftEventId != null) {
        final response = await apiService!.getPackages(state.draftEventId!);
        final data = response['data'] is Map ? response['data'] as Map : const {};
        final packagesData = data['packages'] as List? ?? [];
        packages = packagesData.map((p) => PackageModel.fromJson(p)).toList();
        freeTrialAvailable = data['free_trial_available'] as bool? ?? true;
        suggestedPackageId = _parseInt(data['suggested_package_id']);
      } else {
        packages = [];
      }

      // Ensure a Custom package is always available
      final hasCustom = packages.any((p) => p.isCustom);
      if (!hasCustom) {
        packages.add(const PackageModel(
          id: -1,
          name: 'invitation_custom_package',
          nameAr: 'invitation_custom_package',
          price: 0,
          isCustom: true,
          features: [
            'invitation_custom_package_feature1',
            'invitation_custom_package_feature2',
            'invitation_custom_package_feature3',
          ],
          featuresAr: [
            'invitation_custom_package_feature1',
            'invitation_custom_package_feature2',
            'invitation_custom_package_feature3',
          ],
        ));
      }

      // A previously chosen package that is no longer offered (e.g. the free
      // trial after it was used) must not stay silently selected.
      final selected = state.selectedPackage;
      final stillValid = selected == null ||
          selected.isCustom ||
          packages.any((p) => p.id == selected.id && p.isAvailable);

      emit(state.copyWith(
        isLoadingPackages: false,
        availablePackages: packages,
        freeTrialAvailable: freeTrialAvailable,
        suggestedPackageId: suggestedPackageId,
        clearSelectedPackage: !stillValid,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingPackages: false,
        packagesError: e.toString(),
      ));
    }
  }

  /// Calculate custom package price from API
  Future<void> calculateCustomPackagePrice(int limit) async {
    emit(state.copyWith(isLoadingCustomPrice: true));

    try {
      if (apiService == null) {
        emit(state.copyWith(isLoadingCustomPrice: false));
        return;
      }
      final response = await apiService!.calculateCustomPackage(limit);
      final calc = response['data']?['calculation'];
      final price = double.tryParse('${calc is Map ? calc['total'] : ''}');
      // A newer limit may have been typed while this one was in flight.
      if (isClosed || state.customPackageLimit != limit) return;

      emit(state.copyWith(
        isLoadingCustomPrice: false,
        customPackagePrice: price,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingCustomPrice: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ============ Page 7: Invoice & Save ============

  /// Load invoice data
  Future<void> loadInvoice() async {
    emit(state.copyWith(
      isLoadingInvoice: true,
      invoiceError: null,
    ));

    try {
      if (apiService != null && state.draftEventId != null) {
        final response = await apiService!.getInvoiceSummary(state.draftEventId!);
        final data = response['data'];

        // Parse invoice data from API
        final items = (data['items'] as List? ?? []).map((item) => InvoiceLineItem(
          description: item['name_en'] ?? item['name_ar'] ?? '',
          descriptionAr: item['name_ar'] ?? '',
          amount: _parseNum(item['price']),
        )).toList();

        final invoice = InvoiceSummaryModel(
          invoiceNumber: data['invoice_number'] ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
          basePrice: _parseNum(data['subtotal']),
          servicesTotal: 0,
          templateFee: 0,
          totalPrice: _parseNum(data['total']),
          taxRate: _parseNum(data['tax_rate']),
          taxAmount: _parseNum(data['tax_amount']),
          lineItems: items,
          createdAt: DateTime.now(),
          eventName: data['event']?['title'] ?? state.eventName,
          packageName: state.selectedPackage?.name,
          guestCount: _parseInt(data['guest_count']) ?? state.totalGuestCount,
        );

        emit(state.copyWith(
          isLoadingInvoice: false,
          invoiceSummary: invoice,
          // Never fall back to a made-up number: when Maktoob has not
          // configured one, WhatsApp sharing is simply unavailable.
          whatsappNumber: _nonBlank(data['whatsapp_number']),
        ));
      } else {
        // Generate invoice summary locally
        generateInvoiceSummary();

        emit(state.copyWith(isLoadingInvoice: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingInvoice: false,
        invoiceError: e.toString(),
      ));
    }
  }

  /// Save and send invoice via WhatsApp
  /// [openWhatsApp] false skips the invoice WhatsApp hand-off: paid events
  /// now go to the in-app payment screen instead.
  Future<void> saveAndSend({Uint8List? invoiceImage, bool openWhatsApp = true}) async {
    emit(state.copyWith(
      isSaving: true,
      isSaveAsDraft: false,
      saveSuccess: false,
      saveError: null,
    ));

    try {
      // Persist the event to the backend before sharing.
      if (apiService != null) {
        int eventId;

        // Step 1: Ensure a draft event exists.
        if (state.draftEventId == null) {
          final initResponse = await apiService!.initializeWizard(
            eventTypeId: state.selectedEventType?.id,
            customEventTypeName: state.customEventTypeName,
            templateId: state.selectedTemplate?.id,
            institutionId: state.institutionId,
          );
          eventId = initResponse['data']?['event_id'] as int? ?? 0;
          emit(state.copyWith(draftEventId: eventId));
        } else {
          eventId = state.draftEventId!;
        }

        // Step 2: Save event details.
        await _callSaveEventDetails(eventId);

        // Step 3: Add guests.
        // Always sync, so removing every guest clears them server-side too.
        await apiService!.addManualGuests(
          eventId,
          state.guests
              .map((g) => {'name': g.name, 'phone': g.phone})
              .toList(),
        );

        // Step 4: Save invitation configuration.
        final hasCompanions =
            state.partnerWithGuests != null && state.partnerWithGuests! > 0;
        await apiService!.saveInvitationConfig(
          eventId,
          defaultDeliveryMethod: 'whatsapp',
          allowCompanions: hasCompanions,
          maxCompanions: hasCompanions ? state.partnerWithGuests! : 0,
          requireResponse: true,
          responseDeadline: state.rsvpDeadline,
          // Sent only when typed; otherwise the saved message is kept.
          messageAr: (state.invitationMessage ?? '').trim().isEmpty
              ? null
              : state.invitationMessage!.trim(),
        );

        // Step 5: Save extra services.
        if (state.selectedServices.isNotEmpty) {
          await apiService!.saveExtraServices(
            eventId,
            state.selectedServices.map((s) => s.id).toList(),
            options: _serviceOptions(),
          );
        }

        // Step 6: Select package.
        if (state.selectedPackage != null) {
          await apiService!.selectPackage(
            eventId,
            packageId: state.selectedPackage!.isCustom
                ? null
                : state.selectedPackage!.id,
            isCustomPackage: state.selectedPackage!.isCustom,
            customGuestCount: state.selectedPackage!.isCustom
                ? state.customPackageLimit
                : null,
          );
        }

        // Step 7: Final save. Always commit as an active event (not a draft)
        // so the event is activated on submit; freemium events especially
        // must go live without waiting on an invoice/payment.
        final saveResponse = await apiService!.saveEvent(eventId, isDraft: false);
        final data = saveResponse['data'];
        final rawTotal = data is Map
            ? (data['invoice_total'] ??
                (data['event'] is Map ? data['event']['invoice_total'] : null))
            : null;

        // Approved institution with enough prepaid credits: activate now
        // (the backend deducts the balance) instead of the payment flow.
        final creditsCover = data is Map && data['credits_cover'] == true;
        if (creditsCover) {
          await apiService!.activateEvent(eventId);
        }

        emit(state.copyWith(
          savedEventId: eventId.toString(),
          savedInvoiceTotal:
              rawTotal == null ? null : double.tryParse(rawTotal.toString()),
          paidByCredits: creditsCover,
        ));
      } else {
        // No API service available (offline/fallback) — preserve prior behavior.
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Freemium (free) packages have no invoice — skip sharing it entirely.
      final isFreemium = state.selectedPackage?.isFree ?? false;

      // Try to open WhatsApp if service available (don't fail if WhatsApp fails)
      try {
        if (openWhatsApp &&
            !isFreemium &&
            !state.paidByCredits &&
            whatsAppService != null &&
            state.whatsappNumber != null) {
          final message = whatsAppService!.generateInvoiceMessage(
            eventName: state.eventName ?? '',
            packageName: state.selectedPackage?.nameAr ?? state.selectedPackage?.name ?? '',
            totalPrice: state.invoiceSummary?.totalPrice ?? 0,
            guestCount: state.totalGuestCount,
          );

          if (invoiceImage != null) {
            await whatsAppService!.openWhatsAppWithInvoice(
              phoneNumber: state.whatsappNumber!,
              invoiceImage: invoiceImage,
              message: message,
            );
          } else {
            await whatsAppService!.openWhatsApp(
              phoneNumber: state.whatsappNumber!,
              message: message,
            );
          }
        }
      } catch (whatsAppError) {
        // WhatsApp failed, but we still saved successfully
        debugPrint('WhatsApp error: $whatsAppError');
      }

      emit(state.copyWith(
        isSaving: false,
        saveSuccess: true,
      ));
    } catch (e) {
      final freeTrial = isFreeTrialRefusal(e);
      emit(state.copyWith(
        isSaving: false,
        saveError: freeTrial
            ? freeTrialRefusalMessage(e) ?? e.toString()
            : isInstitutionNotApproved(e)
                ? kInstitutionNotApprovedMessageKey
                : e.toString(),
        saveErrorIsFreeTrial: freeTrial,
      ));
    }
  }

  /// Load venues from API
  Future<void> loadVenues() async {
    emit(state.copyWith(isLoadingVenues: true));

    try {
      List<VenueModel> venues;

      // Venues are loaded as part of form fields, but we can also load them separately
      if (apiService != null && state.draftEventId != null) {
        final response = await apiService!.getEventFormFields(state.draftEventId!);
        final venuesData = response['data']['venues'] as List? ?? [];
        venues = venuesData.map((v) => VenueModel.fromJson(v)).toList();
      } else {
        venues = [];
      }

      emit(state.copyWith(
        isLoadingVenues: false,
        availableVenues: venues,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingVenues: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Load form fields for event type
  Future<void> loadFormFields() async {
    if (state.draftEventId == null) {
      return;
    }

    emit(state.copyWith(isLoadingFormFields: true));

    try {
      List<EventTypeFormField> formFields;
      List<VenueModel> venues = [];

      if (apiService != null) {
        final response = await apiService!.getEventFormFields(state.draftEventId!);
        final data = response['data'];

        // Parse form fields
        final fieldsData = data['form_fields'] as List? ?? [];
        formFields = EventTypeFormField.listFromJson(fieldsData);

        // Parse venues
        final venuesData = data['venues'] as List? ?? [];
        venues = venuesData.map((v) => VenueModel.fromJson(v)).toList();
      } else {
        formFields = [];
      }

      emit(state.copyWith(
        isLoadingFormFields: false,
        eventTypeFormFields: formFields,
        availableVenues: venues.isNotEmpty ? venues : state.availableVenues,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingFormFields: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ============ Legacy Methods (backward compatibility) ============

  /// Legacy: Generate share link (mock implementation)
  @Deprecated('Use new sharing flow instead')
  void generateShareLink() {
    final link = 'https://maktoob.app/invite/${state.savedEventId ?? 'preview'}';
    emit(state.copyWith(shareLink: link));
  }

  /// Legacy: Update location string
  @Deprecated('Use setCustomLocation instead')
  void updateLocation(String location) {
    // Create a simple custom location from the string
    emit(state.copyWith(
      customLocation: LocationModel(
        latitude: 31.5,
        longitude: 34.45,
        address: location,
        placeName: location,
      ),
    ));
  }

  /// Legacy: Update location address
  @Deprecated('Use setCustomLocation instead')
  void updateLocationAddress(String address) {
    if (state.customLocation != null) {
      emit(state.copyWith(
        customLocation: state.customLocation!.copyWith(address: address),
      ));
    } else {
      emit(state.copyWith(
        customLocation: LocationModel(
          latitude: 31.5,
          longitude: 34.45,
          address: address,
        ),
      ));
    }
  }

  /// Legacy: Update name at index (maps to eventName for index 0)
  @Deprecated('Use updateEventName instead')
  void updateName(int index, String name) {
    if (index == 0) {
      updateEventName(name);
    }
  }

  /// Legacy: Skip to confirmation step
  @Deprecated('Use goToStep instead')
  void skipToConfirmation() {
    emit(state.copyWith(currentStep: InvitationStep.confirmation));
  }

  /// Legacy: Submit invitation (maps to saveAndSubmit)
  @Deprecated('Use saveAndSubmit instead')
  Future<void> submitInvitation() async {
    await saveAndSubmit();
  }

  /// Legacy: Get WhatsApp URL for a phone number
  @Deprecated('Use WhatsAppService directly instead')
  String getWhatsAppUrl(String phoneNumber) {
    final cleanedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final message = 'Payment confirmation for event: ${state.eventName ?? "Event"}';
    return 'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}';
  }

  /// Legacy: Select event type from GoldenEventType
  @Deprecated('Use selectEventType(EventTypeModel) instead')
  void selectEventTypeFromGolden(GoldenEventType type) {
    final eventTypeModel = EventTypeModel(
      id: type.index + 1,
      name: type.name,
      nameAr: type.nameAr,
      emoji: type.emoji,
      gradientColors: type.gradientColors,
    );
    selectEventType(eventTypeModel);
  }

  /// Legacy: Select package by ID string
  @Deprecated('Use selectPackage(PackageModel) instead')
  void selectPackageById(String packageId) {
    final package = state.availablePackages.firstWhere(
      (p) => p.id.toString() == packageId,
      orElse: () => state.availablePackages.first,
    );
    selectPackage(package);
  }

  /// Legacy: Select template by ID string
  @Deprecated('Use selectTemplate(TemplateModel) instead')
  void selectTemplateById(String templateId) {
    final template = state.availableTemplates.firstWhere(
      (t) => t.id?.toString() == templateId,
      orElse: () => state.availableTemplates.first,
    );
    selectTemplate(template);
  }

  // ============ Helper Methods ============

  /// Parse number from various formats (String or num)
  static double _parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parse integer from various formats (String or int)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
