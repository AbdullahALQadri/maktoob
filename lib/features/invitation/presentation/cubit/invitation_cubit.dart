import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/event_wizard_api_service.dart';
import '../../data/models/extra_service_model.dart';
import '../../data/models/invitation_draft_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/location_model.dart';
import '../../data/services/excel_parser_service.dart';
import '../../data/services/invoice_generator.dart';
import '../../data/services/whatsapp_service.dart';
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
  Future<void> initializeWizard({int? draftEventId}) async {
    emit(state.copyWith(
      isLoading: true,
      draftEventId: draftEventId,
    ));

    try {
      List<EventTypeModel> eventTypes;

      if (apiService != null) {
        // Load event types from API
        final response = await apiService!.getEventTypes();
        final eventTypesData = response['data']['event_types'] as List;
        eventTypes = eventTypesData.map((e) => EventTypeModel.fromJson(e)).toList();
      } else {
        // Fallback to mock data
        eventTypes = [
          const EventTypeModel(id: 1, name: 'Wedding', nameAr: 'زفاف'),
          const EventTypeModel(id: 2, name: 'Birthday', nameAr: 'عيد ميلاد'),
          const EventTypeModel(id: 3, name: 'Engagement', nameAr: 'خطوبة'),
          const EventTypeModel(id: 4, name: 'Graduation', nameAr: 'تخرج'),
          const EventTypeModel(id: 5, name: 'Conference', nameAr: 'مؤتمر'),
        ];
      }

      emit(state.copyWith(
        isLoading: false,
        availableEventTypes: eventTypes,
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
      final eventData = response['data']['event'];
      // Populate state from draft data
      if (eventData != null) {
        emit(state.copyWith(
          draftEventId: eventData['id'],
          eventName: eventData['title_ar'],
          // Add more fields as needed
        ));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to load draft: ${e.toString()}'));
    }
  }

  /// Load templates for selected event type
  Future<void> loadTemplatesForEventType(int eventTypeId) async {
    emit(state.copyWith(isLoadingTemplates: true));

    try {
      List<TemplateModel> templates;

      if (apiService != null) {
        final response = await apiService!.getTemplatesForEventType(eventTypeId);
        final templatesData = response['data']['templates'] as List;
        templates = templatesData.map((t) => TemplateModel.fromJson(t)).toList();
      } else {
        // Fallback to mock data
        templates = [
          const TemplateModel(id: 1, name: 'Classic', nameAr: 'كلاسيكي', imageUrl: ''),
          const TemplateModel(id: 2, name: 'Modern', nameAr: 'عصري', imageUrl: ''),
          const TemplateModel(id: 3, name: 'Elegant', nameAr: 'أنيق', imageUrl: ''),
        ];
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

  /// Navigate to the next step
  void nextStep() {
    final nextStepMap = {
      // New wizard steps
      InvitationStep.eventTypeSelection: InvitationStep.eventDetails,
      InvitationStep.eventDetails: InvitationStep.invitationPreview,
      InvitationStep.invitationPreview: InvitationStep.guestManagement,
      InvitationStep.guestManagement: InvitationStep.extraServices,
      InvitationStep.extraServices: InvitationStep.packageSelection,
      InvitationStep.packageSelection: InvitationStep.invoiceSummary,
      InvitationStep.invoiceSummary: InvitationStep.invoiceSummary,
      // Legacy steps (for backward compatibility)
      InvitationStep.landing: InvitationStep.eventType,
      InvitationStep.eventType: InvitationStep.creation,
      InvitationStep.creation: InvitationStep.guests,
      InvitationStep.guests: InvitationStep.share,
      InvitationStep.share: InvitationStep.package,
      InvitationStep.package: InvitationStep.payment,
      InvitationStep.payment: InvitationStep.confirmation,
      InvitationStep.confirmation: InvitationStep.confirmation,
    };

    // Special case: Skip preview if custom type or uploaded template
    if (state.currentStep == InvitationStep.eventDetails) {
      if (state.shouldSkipPreview) {
        emit(state.copyWith(currentStep: InvitationStep.guestManagement));
        return;
      }
    }

    final next = nextStepMap[state.currentStep];
    if (next != null) {
      emit(state.copyWith(currentStep: next));
    }
  }

  /// Navigate to the previous step
  void previousStep() {
    final prevStepMap = {
      // New wizard steps
      InvitationStep.eventTypeSelection: InvitationStep.eventTypeSelection,
      InvitationStep.eventDetails: InvitationStep.eventTypeSelection,
      InvitationStep.invitationPreview: InvitationStep.eventDetails,
      InvitationStep.guestManagement: InvitationStep.invitationPreview,
      InvitationStep.extraServices: InvitationStep.guestManagement,
      InvitationStep.packageSelection: InvitationStep.extraServices,
      InvitationStep.invoiceSummary: InvitationStep.packageSelection,
      // Legacy steps (for backward compatibility)
      InvitationStep.landing: InvitationStep.landing,
      InvitationStep.eventType: InvitationStep.landing,
      InvitationStep.creation: InvitationStep.eventType,
      InvitationStep.guests: InvitationStep.creation,
      InvitationStep.share: InvitationStep.guests,
      InvitationStep.package: InvitationStep.share,
      InvitationStep.payment: InvitationStep.package,
      InvitationStep.confirmation: InvitationStep.payment,
    };

    // Special case: Skip preview if custom type or uploaded template
    if (state.currentStep == InvitationStep.guestManagement) {
      if (state.shouldSkipPreview) {
        emit(state.copyWith(currentStep: InvitationStep.eventDetails));
        return;
      }
    }

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

  /// Select an event type
  void selectEventType(EventTypeModel eventType) {
    emit(state.copyWith(
      selectedEventType: eventType,
      // Clear template selection when event type changes
      clearSelectedTemplate: true,
      clearUploadedTemplate: true,
      availableTemplates: [],
    ));
  }

  /// Set custom event type name (for custom type)
  void setCustomEventTypeName(String name) {
    emit(state.copyWith(
      customEventTypeName: name,
      selectedEventType: EventTypeModel.custom(name),
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

  String _normalizePhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    return cleaned;
  }

  // ============ Page 5: Extra Services ============

  /// Set available services from API
  void setAvailableServices(List<ExtraServiceModel> services) {
    emit(state.copyWith(availableServices: services));
  }

  /// Toggle service selection
  void toggleService(ExtraServiceModel service) {
    final currentSelected = List<ExtraServiceModel>.from(state.selectedServices);
    final existingIndex = currentSelected.indexWhere((s) => s.id == service.id);

    if (existingIndex >= 0) {
      currentSelected.removeAt(existingIndex);
    } else {
      currentSelected.add(service);
    }

    emit(state.copyWith(selectedServices: currentSelected));
  }

  /// Check if a service is selected
  bool isServiceSelected(int serviceId) {
    return state.selectedServices.any((s) => s.id == serviceId);
  }

  // ============ Page 6: Package Selection ============

  /// Set available packages from API
  void setAvailablePackages(List<PackageModel> packages) {
    emit(state.copyWith(availablePackages: packages));
  }

  /// Select a package
  void selectPackage(PackageModel package) {
    emit(state.copyWith(
      selectedPackage: package,
      packageValidationError: false,
    ));
    _validatePackageLimit();
  }

  /// Set custom package invitation limit
  void setCustomPackageLimit(int limit) {
    emit(state.copyWith(customPackageLimit: limit));
    // TODO: Call API to get price for custom limit
  }

  /// Set custom package price (from API)
  void setCustomPackagePrice(double price) {
    emit(state.copyWith(customPackagePrice: price));
  }

  /// Validate package limit against guest count
  void _validatePackageLimit() {
    if (state.selectedPackage == null) return;

    final isExceeded = state.isPackageLimitExceeded;
    emit(state.copyWith(packageValidationError: isExceeded));
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
      servicesTotal += service.price;
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
    emit(state.copyWith(whatsappNumber: number));
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
        // Save event as draft
        final response = await apiService!.saveEvent(
          state.draftEventId!,
          isDraft: true,
        );

        emit(state.copyWith(
          isSaving: false,
          saveSuccess: true,
          isSaveAsDraft: true,
          status: InvitationStatus.success,
          savedEventId: response['data']['event']['id'].toString(),
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
          );
          eventId = initResponse['data']['event_id'];
          emit(state.copyWith(draftEventId: eventId));
        } else {
          eventId = state.draftEventId!;
        }

        // Step 2: Save event details
        await apiService!.saveEventDetails(
          eventId,
          titleAr: state.eventName ?? 'حدث جديد',
          titleEn: state.eventName,
          descriptionAr: state.eventDescription,
          eventDate: state.eventDate ?? DateTime.now().add(const Duration(days: 30)),
          eventTime: state.eventTime != null
              ? '${state.eventTime!.hour.toString().padLeft(2, '0')}:${state.eventTime!.minute.toString().padLeft(2, '0')}'
              : null,
          venueId: state.selectedVenue?.id,
          customVenueNameAr: state.customLocation?.placeName,
          customVenueAddressAr: state.customLocation?.address,
          customVenueLat: state.customLocation?.latitude,
          customVenueLng: state.customLocation?.longitude,
          partnerCount: state.partnerWithGuests,
          eventTypeFormValues: state.eventTypeFormData,
        );

        // Step 3: Add guests
        if (state.guests.isNotEmpty) {
          await apiService!.addManualGuests(
            eventId,
            state.guests.map((g) => {
              'name': g.name,
              'phone': g.phone,
            }).toList(),
          );
        }

        // Step 4: Save invitation configuration
        await apiService!.saveInvitationConfig(
          eventId,
          defaultDeliveryMethod: 'whatsapp',
          allowCompanions: true,
          maxCompanions: 2,
          requireResponse: true,
        );

        // Step 5: Save extra services
        if (state.selectedServices.isNotEmpty) {
          await apiService!.saveExtraServices(
            eventId,
            state.selectedServices.map((s) => s.id).toList(),
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
        final saveResponse = await apiService!.saveEvent(eventId, isDraft: false);

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
        eventName: state.eventName ?? 'حدث',
        packageName: state.selectedPackage?.name ?? 'Unknown',
        guestCount: state.totalGuestCount,
        eventType: state.selectedEventType?.name,
      );

      emit(state.copyWith(generatedInvoiceImage: invoiceImageFile));

      // Read file bytes for WhatsApp sharing
      final invoiceImageBytes = await invoiceImageFile.readAsBytes();

      // Generate message
      final message = whatsAppService!.generateInvoiceMessage(
        eventName: state.eventName ?? 'حدث',
        packageName: state.selectedPackage?.name ?? 'Unknown',
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

  // ============ Page 3: Load Preview ============

  /// Load preview from API
  Future<void> loadPreview() async {
    if (state.shouldSkipPreview) return;

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
        // Mock preview URL
        previewUrl = 'https://example.com/preview/${state.selectedTemplate?.id ?? 1}';
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
        errorMessage: 'فشل في قراءة ملف الإكسل: $e',
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
        // Fallback to mock data
        services = [
          const ExtraServiceModel(
            id: 1,
            name: 'Photography',
            nameAr: 'تصوير فوتوغرافي',
            price: 500,
            eventTypeId: 1,
          ),
          const ExtraServiceModel(
            id: 2,
            name: 'Video Recording',
            nameAr: 'تصوير فيديو',
            price: 800,
            eventTypeId: 1,
          ),
          const ExtraServiceModel(
            id: 3,
            name: 'Decoration',
            nameAr: 'تزيين القاعة',
            price: 300,
            eventTypeId: 1,
          ),
          const ExtraServiceModel(
            id: 4,
            name: 'Music',
            nameAr: 'موسيقى',
            price: 400,
            eventTypeId: 1,
          ),
        ];
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

      if (apiService != null && state.draftEventId != null) {
        final response = await apiService!.getPackages(state.draftEventId!);
        final packagesData = response['data']['packages'] as List? ?? [];
        packages = packagesData.map((p) => PackageModel.fromJson(p)).toList();
      } else {
        // Fallback to mock data
        packages = [
          PackageModel(
            id: 1,
            name: 'Basic',
            nameAr: 'الأساسية',
            price: 100,
            invitationLimit: 50,
            features: ['50 دعوة', 'قالب أساسي', 'دعم فني'],
          ),
          PackageModel(
            id: 2,
            name: 'Standard',
            nameAr: 'القياسية',
            price: 200,
            invitationLimit: 150,
            features: ['150 دعوة', 'قوالب متعددة', 'دعم فني 24/7', 'تقارير'],
          ),
          PackageModel(
            id: 3,
            name: 'Premium',
            nameAr: 'المميزة',
            price: 400,
            invitationLimit: 500,
            features: ['500 دعوة', 'جميع القوالب', 'دعم VIP', 'تقارير متقدمة', 'تخصيص كامل'],
          ),
          PackageModel(
            id: 4,
            name: 'Custom',
            nameAr: 'مخصصة',
            price: 0,
            invitationLimit: null,
            features: ['عدد دعوات مخصص', 'تسعير حسب العدد'],
            isCustom: true,
          ),
        ];
      }

      emit(state.copyWith(
        isLoadingPackages: false,
        availablePackages: packages,
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
      // TODO: Call API to calculate price
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock calculation: 2 ILS per invitation
      final price = limit * 2.0;

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
          amount: (item['price'] as num?)?.toDouble() ?? 0,
        )).toList();

        final invoice = InvoiceSummaryModel(
          invoiceNumber: data['invoice_number'] ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
          basePrice: (data['subtotal'] as num?)?.toDouble() ?? 0,
          servicesTotal: 0,
          templateFee: 0,
          totalPrice: (data['total'] as num?)?.toDouble() ?? 0,
          lineItems: items,
          createdAt: DateTime.now(),
          eventName: data['event']?['title'] ?? state.eventName,
          packageName: state.selectedPackage?.name,
          guestCount: data['guest_count'] ?? state.totalGuestCount,
        );

        emit(state.copyWith(
          isLoadingInvoice: false,
          invoiceSummary: invoice,
          whatsappNumber: data['whatsapp_number'] ?? '+972599999999',
        ));
      } else {
        // Generate invoice summary locally
        generateInvoiceSummary();

        emit(state.copyWith(
          isLoadingInvoice: false,
          whatsappNumber: '+972599999999',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingInvoice: false,
        invoiceError: e.toString(),
      ));
    }
  }

  /// Save and send invoice via WhatsApp
  Future<void> saveAndSend({Uint8List? invoiceImage}) async {
    emit(state.copyWith(
      isSaving: true,
      isSaveAsDraft: false,
      saveSuccess: false,
      saveError: null,
    ));

    try {
      // Save to API
      // TODO: Call API to save event
      await Future.delayed(const Duration(milliseconds: 500));

      // Try to open WhatsApp if service available (don't fail if WhatsApp fails)
      try {
        if (whatsAppService != null && state.whatsappNumber != null) {
          final message = whatsAppService!.generateInvoiceMessage(
            eventName: state.eventName ?? 'حدث',
            packageName: state.selectedPackage?.nameAr ?? 'غير محدد',
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
      emit(state.copyWith(
        isSaving: false,
        saveError: e.toString(),
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
        // Fallback to mock data
        venues = [
          const VenueModel(id: 1, name: 'Grand Hall', nameAr: 'قاعة الكبرى', address: 'غزة'),
          const VenueModel(id: 2, name: 'Garden Palace', nameAr: 'قصر الحدائق', address: 'خانيونس'),
          const VenueModel(id: 3, name: 'Beach Resort', nameAr: 'منتجع الشاطئ', address: 'دير البلح'),
        ];
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
        formFields = fieldsData.map((f) => EventTypeFormField.fromJson(f)).toList();

        // Parse venues
        final venuesData = data['venues'] as List? ?? [];
        venues = venuesData.map((v) => VenueModel.fromJson(v)).toList();
      } else {
        // Fallback to mock data
        formFields = <EventTypeFormField>[
          const EventTypeFormField(
            key: 'groom_name',
            label: 'Groom Name',
            labelAr: 'اسم العريس',
            type: 'text',
            required: true,
          ),
          const EventTypeFormField(
            key: 'bride_name',
            label: 'Bride Name',
            labelAr: 'اسم العروس',
            type: 'text',
            required: true,
          ),
        ];
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
}
