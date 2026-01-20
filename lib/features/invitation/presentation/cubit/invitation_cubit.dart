import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final ExcelParserService? excelParserService;
  final WhatsAppService? whatsAppService;
  final InvoiceGenerator? invoiceGenerator;

  InvitationCubit({
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
      // TODO: Load event types from API
      // For now, use mock data
      await Future.delayed(const Duration(milliseconds: 300));

      final mockEventTypes = [
        const EventTypeModel(id: 1, name: 'Wedding', nameAr: 'زفاف'),
        const EventTypeModel(id: 2, name: 'Birthday', nameAr: 'عيد ميلاد'),
        const EventTypeModel(id: 3, name: 'Engagement', nameAr: 'خطوبة'),
        const EventTypeModel(id: 4, name: 'Graduation', nameAr: 'تخرج'),
        const EventTypeModel(id: 5, name: 'Conference', nameAr: 'مؤتمر'),
      ];

      emit(state.copyWith(
        isLoading: false,
        availableEventTypes: mockEventTypes,
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
    // TODO: Load draft data from API
    // This would populate the state with saved draft values
  }

  /// Load templates for selected event type
  Future<void> loadTemplatesForEventType(int eventTypeId) async {
    emit(state.copyWith(isLoadingTemplates: true));

    try {
      // TODO: Call API to get templates
      await Future.delayed(const Duration(milliseconds: 300));

      final mockTemplates = [
        const TemplateModel(id: 1, name: 'Classic', nameAr: 'كلاسيكي', imageUrl: ''),
        const TemplateModel(id: 2, name: 'Modern', nameAr: 'عصري', imageUrl: ''),
        const TemplateModel(id: 3, name: 'Elegant', nameAr: 'أنيق', imageUrl: ''),
      ];

      emit(state.copyWith(
        isLoadingTemplates: false,
        availableTemplates: mockTemplates,
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
      uploadedTemplateDescription: null,
    ));
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

  /// Set custom location from Google Maps
  void setCustomLocation(LocationModel location) {
    emit(state.copyWith(
      customLocation: location,
      clearSelectedVenue: true,
    ));
  }

  /// Update partner with guests count
  void updatePartnerWithGuests(int? count) {
    emit(state.copyWith(partnerWithGuests: count));
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
    emit(state.copyWith(status: InvitationStatus.loading));

    try {
      // TODO: Call API to save draft
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(
        status: InvitationStatus.success,
        savedEventId: 'draft_${DateTime.now().millisecondsSinceEpoch}',
      ));
    } catch (e) {
      emit(state.copyWith(
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

      // TODO: Call API to save event
      await Future.delayed(const Duration(milliseconds: 800));

      final eventId = 'EVT-${DateTime.now().millisecondsSinceEpoch}';

      emit(state.copyWith(
        status: InvitationStatus.success,
        savedEventId: eventId,
        invitationId: eventId,
      ));
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
      // TODO: Call API to get preview
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock preview URL
      final previewUrl = 'https://example.com/preview/${state.selectedTemplate?.id ?? 1}';

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
      // TODO: Call API to get services based on event type
      await Future.delayed(const Duration(milliseconds: 400));

      final mockServices = [
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

      emit(state.copyWith(
        isLoadingServices: false,
        availableServices: mockServices,
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
      // TODO: Call API to get packages
      await Future.delayed(const Duration(milliseconds: 400));

      final mockPackages = [
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

      emit(state.copyWith(
        isLoadingPackages: false,
        availablePackages: mockPackages,
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
      // Generate invoice summary
      generateInvoiceSummary();

      // TODO: Optionally load WhatsApp number from API
      await Future.delayed(const Duration(milliseconds: 300));

      emit(state.copyWith(
        isLoadingInvoice: false,
        whatsappNumber: '+972599999999', // Mock WhatsApp number
      ));
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
      await Future.delayed(const Duration(milliseconds: 800));

      // Open WhatsApp if service available
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
      // TODO: Call API to get venues
      await Future.delayed(const Duration(milliseconds: 300));

      final mockVenues = [
        const VenueModel(id: 1, name: 'Grand Hall', nameAr: 'قاعة الكبرى', address: 'غزة'),
        const VenueModel(id: 2, name: 'Garden Palace', nameAr: 'قصر الحدائق', address: 'خانيونس'),
        const VenueModel(id: 3, name: 'Beach Resort', nameAr: 'منتجع الشاطئ', address: 'دير البلح'),
      ];

      emit(state.copyWith(
        isLoadingVenues: false,
        availableVenues: mockVenues,
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
    if (state.selectedEventType == null || state.selectedEventType!.id == null) {
      return;
    }

    emit(state.copyWith(isLoadingFormFields: true));

    try {
      // TODO: Call API to get form fields
      await Future.delayed(const Duration(milliseconds: 300));

      final mockFields = <EventTypeFormField>[
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

      emit(state.copyWith(
        isLoadingFormFields: false,
        eventTypeFormFields: mockFields,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingFormFields: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
