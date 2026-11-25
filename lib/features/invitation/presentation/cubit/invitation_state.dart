
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/extra_service_model.dart';
import '../../data/models/invitation_draft_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/event_type_fields_models.dart';
import '../../data/models/package_model.dart';
import '../../data/models/template_venue_models.dart';
import '../../data/models/event_type_model.dart';

export '../../data/models/event_type_model.dart';
export '../../data/models/event_type_fields_models.dart';
export '../../data/models/package_model.dart';
export '../../data/models/template_venue_models.dart';

/// The wizard's screens, in the portal's order. The sixth step ("send")
/// is the event page itself, once the event is active.
enum InvitationStep {
  details,
  guests,
  design,
  settings,
  checkout;

  /// Key of the step's name (`home_step_<key>`), shared with the event page.
  String get key => name;
}

/// Status of invitation operations
enum InvitationStatus {
  initial,
  loading,
  success,
  failure,
}

/// Main state for the invitation feature
class InvitationState extends Equatable {
  // Navigation
  final InvitationStep currentStep;
  final InvitationStatus status;

  // Wizard tracking (from API after initialization)
  final int? draftEventId;

  // Loading states
  final bool isLoading;
  final bool isLoadingTemplates;
  final bool isLoadingServices;
  final bool isLoadingPackages;
  final bool isLoadingInvoice;
  final bool isLoadingExcel;
  final bool isLoadingCustomPrice;
  final bool isLoadingFormFields;

  // Save states
  final bool isSaving;
  final bool saveSuccess;
  final bool isSaveAsDraft;

  // Error states
  final String? servicesError;
  final String? packagesError;
  final String? invoiceError;
  final String? saveError;

  /// True when [saveError] is the backend's "free trial already used"
  /// refusal (422 errors.status), so the UI offers "choose a package".
  final bool saveErrorIsFreeTrial;

  /// Institution the event is created for (null = personal account).
  final int? institutionId;
  final String? institutionName;

  /// Known prepaid credit balance of that institution (owner only).
  final int? institutionCredits;

  /// The save response said the institution's credits pay for it, and the
  /// event was activated without the payment flow.
  final bool paidByCredits;

  // Page 1: Event Type Selection
  final List<EventTypeModel> availableEventTypes;
  final List<EventTypeGroupModel> availableEventTypeGroups;
  final EventTypeModel? selectedEventType;
  final String? customEventTypeName;
  final List<TemplateModel> availableTemplates;
  final TemplateModel? selectedTemplate;

  // Page 2: Event Details
  final String? eventName;
  final String? eventDescription;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final DateTime? eventEndDate;
  final TimeOfDay? eventEndTime;
  final VenueModel? selectedVenue;
  final LocationModel? customLocation;
  final int? partnerWithGuests;

  /// RSVP settings (optional): last day guests can answer, and a personal
  /// message shown on the invitation page.
  final DateTime? rsvpDeadline;
  final String? invitationMessage;

  /// How invitations go out (`whatsapp` | `email`) and whether guests are
  /// asked to confirm attendance.
  final String deliveryMethod;
  final bool requireResponse;
  final List<EventTypeFormField> eventTypeFormFields;
  final Map<String, dynamic> eventTypeFormData;

  // Preview & AI Generation
  final String? previewImageUrl;
  final int? generatingImageId;
  final String? generatedImageUrl;
  final String? generationError;

  // Page 4: Guest Management
  final List<GuestInfoModel> guests;
  final List<GuestInfoModel> contactsGuests;
  final List<GuestInfoModel> excelGuests;
  final List<GuestInfoModel> manualGuests;
  final Set<String> duplicatePhoneNumbers;

  // Page 5: Extra Services
  final List<ExtraServiceModel> availableServices;
  final List<ExtraServiceModel> selectedServices;

  // Page 6: Package Selection
  final List<PackageModel> availablePackages;

  /// Backend `free_trial_available`: this phone has not used its one free
  /// invitation yet.
  final bool freeTrialAvailable;

  /// Backend `suggested_package_id`: cheapest package that fits all guests.
  final int? suggestedPackageId;
  final PackageModel? selectedPackage;
  final int? customPackageLimit;
  final double? customPackagePrice;
  final bool packageValidationError;

  // Page 7: Invoice
  final InvoiceSummaryModel? invoiceSummary;
  final String? savedEventId;
  /// The backend's own invoice total from the final save (authoritative).
  final double? savedInvoiceTotal;
  final String? whatsappNumber;

  // Results & Errors
  final String? invitationId;
  final String? errorMessage;

  const InvitationState({
    // Navigation
    this.currentStep = InvitationStep.details,
    this.status = InvitationStatus.initial,
    // Wizard tracking
    this.draftEventId,
    // Loading states
    this.isLoading = false,
    this.isLoadingTemplates = false,
    this.isLoadingServices = false,
    this.isLoadingPackages = false,
    this.isLoadingInvoice = false,
    this.isLoadingExcel = false,
    this.isLoadingCustomPrice = false,
    this.isLoadingFormFields = false,
    // Save states
    this.isSaving = false,
    this.saveSuccess = false,
    this.isSaveAsDraft = false,
    // Error states
    this.servicesError,
    this.packagesError,
    this.invoiceError,
    this.saveError,
    this.saveErrorIsFreeTrial = false,
    this.institutionId,
    this.institutionName,
    this.institutionCredits,
    this.paidByCredits = false,
    // Page 1
    this.availableEventTypes = const [],
    this.availableEventTypeGroups = const [],
    this.selectedEventType,
    this.customEventTypeName,
    this.availableTemplates = const [],
    this.selectedTemplate,
    // Page 2
    this.eventName,
    this.eventDescription,
    this.eventDate,
    this.eventTime,
    this.eventEndDate,
    this.eventEndTime,
    this.selectedVenue,
    this.customLocation,
    this.partnerWithGuests,
    this.rsvpDeadline,
    this.invitationMessage,
    this.deliveryMethod = 'whatsapp',
    this.requireResponse = true,
    this.eventTypeFormFields = const [],
    this.eventTypeFormData = const {},
    // Preview & AI Generation
    this.previewImageUrl,
    this.generatingImageId,
    this.generatedImageUrl,
    this.generationError,
    // Page 4
    this.guests = const [],
    this.contactsGuests = const [],
    this.excelGuests = const [],
    this.manualGuests = const [],
    this.duplicatePhoneNumbers = const {},
    // Page 5
    this.availableServices = const [],
    this.selectedServices = const [],
    // Page 6
    this.availablePackages = const [],
    this.freeTrialAvailable = true,
    this.suggestedPackageId,
    this.selectedPackage,
    this.customPackageLimit,
    this.customPackagePrice,
    this.packageValidationError = false,
    // Page 7
    this.invoiceSummary,
    this.savedEventId,
    this.savedInvoiceTotal,
    this.whatsappNumber,
    // Results
    this.invitationId,
    this.errorMessage,
  });

  /// Initial state
  factory InvitationState.initial() => const InvitationState();

  /// Review step: the institution's prepaid balance covers the chosen paid
  /// package, so activation deducts credits instead of asking for payment.
  /// (Backend is authoritative; `credits_cover` on save confirms it.)
  bool get creditsCoverSelectedPackage {
    final pkg = selectedPackage;
    final credits = institutionCredits;
    if (institutionId == null || credits == null || pkg == null || pkg.isFree) {
      return false;
    }
    final needed = pkg.isCustom ? (customPackageLimit ?? 0) : (pkg.invitationLimit ?? 0);
    return needed > 0 && credits >= needed;
  }

  /// Total guest count from all sources
  int get totalGuestCount => guests.length;

  /// Check if package limit is exceeded
  bool get isPackageLimitExceeded {
    if (selectedPackage == null) return false;
    // Custom packages: user defines the limit, check against customPackageLimit
    if (selectedPackage!.isCustom) {
      // No limit set yet, or limit < 1, or limit < guest count → invalid
      if (customPackageLimit == null || customPackageLimit! < 1) return true;
      return totalGuestCount > customPackageLimit!;
    }
    if (selectedPackage!.hasUnlimitedInvitations) return false;
    final limit = selectedPackage!.invitationLimit;
    if (limit == null) return false;
    return totalGuestCount > limit;
  }

  /// Copy with method for immutable state updates
  InvitationState copyWith({
    // Navigation
    InvitationStep? currentStep,
    InvitationStatus? status,
    // Wizard tracking
    int? draftEventId,
    // Loading states
    bool? isLoading,
    bool? isLoadingTemplates,
    bool? isLoadingServices,
    bool? isLoadingPackages,
    bool? isLoadingInvoice,
    bool? isLoadingExcel,
    bool? isLoadingCustomPrice,
    bool? isLoadingFormFields,
    // Save states
    bool? isSaving,
    bool? saveSuccess,
    bool? isSaveAsDraft,
    // Error states
    String? servicesError,
    String? packagesError,
    String? invoiceError,
    String? saveError,
    bool saveErrorIsFreeTrial = false,
    int? institutionId,
    String? institutionName,
    int? institutionCredits,
    bool clearInstitution = false,
    bool? paidByCredits,
    // Page 1
    List<EventTypeModel>? availableEventTypes,
    List<EventTypeGroupModel>? availableEventTypeGroups,
    EventTypeModel? selectedEventType,
    String? customEventTypeName,
    List<TemplateModel>? availableTemplates,
    TemplateModel? selectedTemplate,
    // Page 2
    String? eventName,
    String? eventDescription,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    DateTime? eventEndDate,
    TimeOfDay? eventEndTime,
    bool clearEventEndDate = false,
    VenueModel? selectedVenue,
    LocationModel? customLocation,
    int? partnerWithGuests,
    DateTime? rsvpDeadline,
    bool clearRsvpDeadline = false,
    String? invitationMessage,
    String? deliveryMethod,
    bool? requireResponse,
    List<EventTypeFormField>? eventTypeFormFields,
    Map<String, dynamic>? eventTypeFormData,
    // Preview & AI Generation
    String? previewImageUrl,
    int? generatingImageId,
    String? generatedImageUrl,
    String? generationError,
    bool clearGeneratedImage = false,
    bool clearGenerationError = false,
    // Page 4
    List<GuestInfoModel>? guests,
    List<GuestInfoModel>? contactsGuests,
    List<GuestInfoModel>? excelGuests,
    List<GuestInfoModel>? manualGuests,
    Set<String>? duplicatePhoneNumbers,
    // Page 5
    List<ExtraServiceModel>? availableServices,
    List<ExtraServiceModel>? selectedServices,
    // Page 6
    List<PackageModel>? availablePackages,
    bool? freeTrialAvailable,
    int? suggestedPackageId,
    PackageModel? selectedPackage,
    int? customPackageLimit,
    double? customPackagePrice,
    bool? packageValidationError,
    // Page 7
    InvoiceSummaryModel? invoiceSummary,
    String? savedEventId,
    double? savedInvoiceTotal,
    String? whatsappNumber,
    // Results
    String? invitationId,
    String? errorMessage,
    // Clear flags
    bool clearSelectedEventType = false,
    bool clearSelectedTemplate = false,
    bool clearSelectedVenue = false,
    bool clearCustomLocation = false,
    bool clearPartnerWithGuests = false,
    bool clearSelectedPackage = false,
    bool clearError = false,
  }) {
    return InvitationState(
      // Navigation
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      // Wizard tracking
      draftEventId: draftEventId ?? this.draftEventId,
      // Loading states
      isLoading: isLoading ?? this.isLoading,
      isLoadingTemplates: isLoadingTemplates ?? this.isLoadingTemplates,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isLoadingPackages: isLoadingPackages ?? this.isLoadingPackages,
      isLoadingInvoice: isLoadingInvoice ?? this.isLoadingInvoice,
      isLoadingExcel: isLoadingExcel ?? this.isLoadingExcel,
      isLoadingCustomPrice: isLoadingCustomPrice ?? this.isLoadingCustomPrice,
      isLoadingFormFields: isLoadingFormFields ?? this.isLoadingFormFields,
      // Save states
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      isSaveAsDraft: isSaveAsDraft ?? this.isSaveAsDraft,
      // Error states
      servicesError: servicesError,
      packagesError: packagesError,
      invoiceError: invoiceError,
      saveError: saveError,
      saveErrorIsFreeTrial: saveError != null && saveErrorIsFreeTrial,
      institutionId: clearInstitution ? null : (institutionId ?? this.institutionId),
      institutionName: clearInstitution ? null : (institutionName ?? this.institutionName),
      institutionCredits:
          clearInstitution ? null : (institutionCredits ?? this.institutionCredits),
      paidByCredits: paidByCredits ?? this.paidByCredits,
      // Page 1
      availableEventTypes: availableEventTypes ?? this.availableEventTypes,
      availableEventTypeGroups:
          availableEventTypeGroups ?? this.availableEventTypeGroups,
      selectedEventType: clearSelectedEventType
          ? null
          : (selectedEventType ?? this.selectedEventType),
      customEventTypeName: customEventTypeName ?? this.customEventTypeName,
      availableTemplates: availableTemplates ?? this.availableTemplates,
      selectedTemplate: clearSelectedTemplate
          ? null
          : (selectedTemplate ?? this.selectedTemplate),
      // Page 2
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      eventEndDate: clearEventEndDate ? null : (eventEndDate ?? this.eventEndDate),
      eventEndTime: eventEndTime ?? this.eventEndTime,
      selectedVenue:
          clearSelectedVenue ? null : (selectedVenue ?? this.selectedVenue),
      customLocation:
          clearCustomLocation ? null : (customLocation ?? this.customLocation),
      partnerWithGuests:
          clearPartnerWithGuests ? null : (partnerWithGuests ?? this.partnerWithGuests),
      rsvpDeadline: clearRsvpDeadline ? null : (rsvpDeadline ?? this.rsvpDeadline),
      invitationMessage: invitationMessage ?? this.invitationMessage,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      requireResponse: requireResponse ?? this.requireResponse,
      eventTypeFormFields: eventTypeFormFields ?? this.eventTypeFormFields,
      eventTypeFormData: eventTypeFormData ?? this.eventTypeFormData,
      // Preview & AI Generation
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      generatingImageId: generatingImageId ?? this.generatingImageId,
      generatedImageUrl: clearGeneratedImage
          ? null
          : (generatedImageUrl ?? this.generatedImageUrl),
      generationError: clearGenerationError
          ? null
          : (generationError ?? this.generationError),
      // Page 4
      guests: guests ?? this.guests,
      contactsGuests: contactsGuests ?? this.contactsGuests,
      excelGuests: excelGuests ?? this.excelGuests,
      manualGuests: manualGuests ?? this.manualGuests,
      duplicatePhoneNumbers:
          duplicatePhoneNumbers ?? this.duplicatePhoneNumbers,
      // Page 5
      availableServices: availableServices ?? this.availableServices,
      selectedServices: selectedServices ?? this.selectedServices,
      // Page 6
      availablePackages: availablePackages ?? this.availablePackages,
      freeTrialAvailable: freeTrialAvailable ?? this.freeTrialAvailable,
      suggestedPackageId: suggestedPackageId ?? this.suggestedPackageId,
      selectedPackage: clearSelectedPackage
          ? null
          : (selectedPackage ?? this.selectedPackage),
      customPackageLimit: customPackageLimit ?? this.customPackageLimit,
      customPackagePrice: customPackagePrice ?? this.customPackagePrice,
      packageValidationError:
          packageValidationError ?? this.packageValidationError,
      // Page 7
      invoiceSummary: invoiceSummary ?? this.invoiceSummary,
      savedEventId: savedEventId ?? this.savedEventId,
      savedInvoiceTotal: savedInvoiceTotal ?? this.savedInvoiceTotal,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      // Results
      invitationId: invitationId ?? this.invitationId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // ============ Validation Helpers ============

  /// The occasion is chosen (the design has its own step now).
  bool get canProceedFromEventType {
    if (selectedEventType == null) return false;
    return !(selectedEventType!.isCustom && (customEventTypeName?.isEmpty ?? true));
  }

  /// Required per-type fields that are still empty.
  List<EventTypeFormField> get missingRequiredFormFields {
    return eventTypeFormFields.where((f) {
      if (!f.isRequired) return false;
      final v = eventTypeFormData[f.key];
      if (v == null) return true;
      if (v is String) return v.trim().isEmpty;
      if (v is bool) return f.type == 'checkbox' && !v;
      return false;
    }).toList();
  }

  /// Check if page 2 is complete
  bool get canProceedFromEventDetails {
    // Title is optional: the backend writes one from the occasion's names.
    if (eventDate == null) return false;
    if (eventTime == null) return false;
    // Business types: an end time, when given, must be after the start
    // (on a later last day it may be any time).
    if (selectedEventType?.hasEndTime == true && eventEndTime != null && eventEndDate == null) {
      final start = eventTime!.hour * 60 + eventTime!.minute;
      final end = eventEndTime!.hour * 60 + eventEndTime!.minute;
      if (end <= start) return false;
    }
    // Location is optional
    return true;
  }

  /// Check if page 6 is complete
  bool get canProceedFromPackage {
    if (selectedPackage == null) return false;
    return !isPackageLimitExceeded;
  }

  // ============ Legacy Getters (backward compatibility) ============

  @override
  List<Object?> get props => [
        // Navigation
        currentStep,
        status,
        // Wizard tracking
        draftEventId,
        // Loading states
        isLoading,
        isLoadingTemplates,
        isLoadingServices,
        isLoadingPackages,
        isLoadingInvoice,
        isLoadingExcel,
        isLoadingCustomPrice,
        isLoadingFormFields,
        // Save states
        isSaving,
        saveSuccess,
        isSaveAsDraft,
        // Error states
        servicesError,
        packagesError,
        invoiceError,
        saveError,
        saveErrorIsFreeTrial,
        institutionId,
        institutionName,
        institutionCredits,
        paidByCredits,
        // Page 1
        availableEventTypes,
        availableEventTypeGroups,
        selectedEventType,
        customEventTypeName,
        availableTemplates,
        selectedTemplate,
        // Page 2
        eventName,
        eventDescription,
        eventDate,
        eventTime,
        eventEndDate,
        eventEndTime,
        selectedVenue,
        customLocation,
        partnerWithGuests,
        rsvpDeadline,
        invitationMessage,
        deliveryMethod,
        requireResponse,
        eventTypeFormFields,
        eventTypeFormData,
        // Preview & AI Generation
        previewImageUrl,
        generatingImageId,
        generatedImageUrl,
        generationError,
        // Page 4
        guests,
        contactsGuests,
        excelGuests,
        manualGuests,
        duplicatePhoneNumbers,
        // Page 5
        availableServices,
        selectedServices,
        // Page 6
        availablePackages,
        freeTrialAvailable,
        suggestedPackageId,
        selectedPackage,
        customPackageLimit,
        customPackagePrice,
        packageValidationError,
        // Page 7
        invoiceSummary,
        savedEventId,
        savedInvoiceTotal,
        whatsappNumber,
        // Results
        invitationId,
        errorMessage,
      ];
}
