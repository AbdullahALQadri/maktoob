import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/extra_service_model.dart';
import '../../data/models/invitation_draft_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/location_model.dart';

/// Steps in the 7-page event creation wizard
enum InvitationStep {
  // New wizard steps (7-page flow)
  eventTypeSelection, // Page 1: Event type + template selection
  eventDetails, // Page 2: Event name, date, location, etc.
  invitationPreview, // Page 3: Template preview
  guestManagement, // Page 4: Guest management
  extraServices, // Page 5: Paid extra services
  packageSelection, // Page 6: Package selection
  invoiceSummary, // Page 7: Invoice & save

  // Legacy steps (for backward compatibility with old flow)
  @Deprecated('Use eventTypeSelection instead')
  landing,
  @Deprecated('Use eventTypeSelection instead')
  eventType,
  @Deprecated('Use eventDetails instead')
  creation,
  @Deprecated('Use guestManagement instead')
  guests,
  @Deprecated('Use invoiceSummary instead')
  share,
  @Deprecated('Use packageSelection instead')
  package,
  @Deprecated('Use invoiceSummary instead')
  payment,
  @Deprecated('Use invoiceSummary instead')
  confirmation,
}

/// Status of invitation operations
enum InvitationStatus {
  initial,
  loading,
  success,
  failure,
}

/// Event type model from API
class EventTypeModel extends Equatable {
  final int? id; // null for custom type
  final String name;
  final String nameAr;
  final String? iconUrl;
  final String? emoji;
  final List<Color>? gradientColors;

  const EventTypeModel({
    this.id,
    required this.name,
    required this.nameAr,
    this.iconUrl,
    this.emoji,
    this.gradientColors,
  });

  bool get isCustom => id == null;

  factory EventTypeModel.fromJson(Map<String, dynamic> json) {
    return EventTypeModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String? ?? json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      emoji: json['emoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_ar': nameAr,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (emoji != null) 'emoji': emoji,
    };
  }

  /// Create custom event type
  factory EventTypeModel.custom(String name) {
    return EventTypeModel(
      id: null,
      name: name,
      nameAr: name,
      emoji: '➕',
      gradientColors: const [Color(0xFF9333EA), Color(0xFFDB2777)],
    );
  }

  @override
  List<Object?> get props => [id, name, nameAr, iconUrl, emoji, gradientColors];
}

/// Template model from API
class TemplateModel extends Equatable {
  final int? id; // null for custom template
  final String name;
  final String nameAr;
  final String? previewUrl;
  final String? imageUrl; // Alias for previewUrl
  final bool isCustom;
  final bool hasExtraFee;
  final double? extraFeeAmount;

  const TemplateModel({
    this.id,
    required this.name,
    required this.nameAr,
    this.previewUrl,
    String? imageUrl,
    this.isCustom = false,
    this.hasExtraFee = false,
    this.extraFeeAmount,
  }) : imageUrl = imageUrl ?? previewUrl;

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String? ?? json['name'] as String,
      previewUrl: json['preview_url'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
      hasExtraFee: json['has_extra_fee'] as bool? ?? false,
      extraFeeAmount: (json['extra_fee_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_ar': nameAr,
      if (previewUrl != null) 'preview_url': previewUrl,
      'is_custom': isCustom,
      'has_extra_fee': hasExtraFee,
      if (extraFeeAmount != null) 'extra_fee_amount': extraFeeAmount,
    };
  }

  /// Create custom template placeholder
  factory TemplateModel.customPlaceholder() {
    return const TemplateModel(
      id: null,
      name: 'Custom Template',
      nameAr: 'قالب مخصص',
      isCustom: true,
      hasExtraFee: true,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, nameAr, previewUrl, isCustom, hasExtraFee, extraFeeAmount];
}

/// Venue model from API
class VenueModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final String? address;
  final double? latitude;
  final double? longitude;

  const VenueModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String? ?? json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [id, name, nameAr, address, latitude, longitude];
}

/// Package model from API
class PackageModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final double price;
  final int? invitationLimit; // null for unlimited or custom
  final bool isCustom;
  final int? minInvitations;
  final List<String> features;
  final List<String> featuresAr;
  final bool isHighlighted;

  const PackageModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    this.invitationLimit,
    this.isCustom = false,
    this.minInvitations,
    this.features = const [],
    this.featuresAr = const [],
    this.isHighlighted = false,
  });

  bool get hasUnlimitedInvitations => invitationLimit == null || invitationLimit == -1;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String? ?? json['name'] as String,
      price: (json['price'] as num).toDouble(),
      invitationLimit: json['invitation_limit'] as int?,
      isCustom: json['is_custom'] as bool? ?? false,
      minInvitations: json['min_invitations'] as int?,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      featuresAr: (json['features_ar'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isHighlighted: json['is_highlighted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'price': price,
      if (invitationLimit != null) 'invitation_limit': invitationLimit,
      'is_custom': isCustom,
      if (minInvitations != null) 'min_invitations': minInvitations,
      'features': features,
      'features_ar': featuresAr,
      'is_highlighted': isHighlighted,
    };
  }

  PackageModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    double? price,
    int? invitationLimit,
    bool? isCustom,
    int? minInvitations,
    List<String>? features,
    List<String>? featuresAr,
    bool? isHighlighted,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      price: price ?? this.price,
      invitationLimit: invitationLimit ?? this.invitationLimit,
      isCustom: isCustom ?? this.isCustom,
      minInvitations: minInvitations ?? this.minInvitations,
      features: features ?? this.features,
      featuresAr: featuresAr ?? this.featuresAr,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        price,
        invitationLimit,
        isCustom,
        minInvitations,
        features,
        featuresAr,
        isHighlighted,
      ];
}

/// Form field definition from API
class EventTypeFormField extends Equatable {
  final String key;
  final String label;
  final String labelAr;
  final String type; // text, number, date, etc.
  final bool isRequired;
  final bool required; // Alias for isRequired
  final String? hint;
  final String? hintAr;

  const EventTypeFormField({
    required this.key,
    required this.label,
    required this.labelAr,
    required this.type,
    bool isRequired = false,
    bool? required,
    this.hint,
    this.hintAr,
  }) : isRequired = required ?? isRequired,
       required = required ?? isRequired;

  factory EventTypeFormField.fromJson(Map<String, dynamic> json) {
    return EventTypeFormField(
      key: json['key'] as String,
      label: json['label'] as String,
      labelAr: json['label_ar'] as String? ?? json['label'] as String,
      type: json['type'] as String? ?? 'text',
      isRequired: json['is_required'] as bool? ?? false,
      hint: json['hint'] as String?,
      hintAr: json['hint_ar'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [key, label, labelAr, type, isRequired, hint, hintAr];
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
  final bool isLoadingPreview;
  final bool isLoadingServices;
  final bool isLoadingPackages;
  final bool isLoadingInvoice;
  final bool isLoadingExcel;
  final bool isLoadingCustomPrice;
  final bool isLoadingVenues;
  final bool isLoadingFormFields;

  // Save states
  final bool isSaving;
  final bool saveSuccess;
  final bool isSaveAsDraft;

  // Error states
  final String? previewError;
  final String? servicesError;
  final String? packagesError;
  final String? invoiceError;
  final String? saveError;

  // Page 1: Event Type Selection
  final List<EventTypeModel> availableEventTypes;
  final EventTypeModel? selectedEventType;
  final String? customEventTypeName;
  final List<TemplateModel> availableTemplates;
  final TemplateModel? selectedTemplate;
  final File? uploadedTemplateFile;
  final String? uploadedTemplateDescription;

  // Page 2: Event Details
  final String? eventName;
  final String? eventDescription;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final List<VenueModel> availableVenues;
  final VenueModel? selectedVenue;
  final LocationModel? customLocation;
  final int? partnerWithGuests;
  final List<EventTypeFormField> eventTypeFormFields;
  final Map<String, dynamic> eventTypeFormData;

  // Page 3: Preview
  final String? previewImageUrl;

  // Page 4: Guest Management
  final List<GuestInfoModel> guests;
  final List<GuestInfoModel> contactsGuests;
  final List<GuestInfoModel> excelGuests;
  final List<GuestInfoModel> manualGuests;
  final Set<String> duplicatePhoneNumbers;
  final GuestInfoModel currentGuestInput;

  // Page 5: Extra Services
  final List<ExtraServiceModel> availableServices;
  final List<ExtraServiceModel> selectedServices;

  // Page 6: Package Selection
  final List<PackageModel> availablePackages;
  final PackageModel? selectedPackage;
  final int? customPackageLimit;
  final double? customPackagePrice;
  final bool packageValidationError;

  // Page 7: Invoice
  final InvoiceSummaryModel? invoiceSummary;
  final String? savedEventId;
  final String? whatsappNumber;
  final File? generatedInvoiceImage;

  // Results & Errors
  final String? shareLink;
  final String? invitationId;
  final String? errorMessage;

  const InvitationState({
    // Navigation
    this.currentStep = InvitationStep.eventTypeSelection,
    this.status = InvitationStatus.initial,
    // Wizard tracking
    this.draftEventId,
    // Loading states
    this.isLoading = false,
    this.isLoadingTemplates = false,
    this.isLoadingPreview = false,
    this.isLoadingServices = false,
    this.isLoadingPackages = false,
    this.isLoadingInvoice = false,
    this.isLoadingExcel = false,
    this.isLoadingCustomPrice = false,
    this.isLoadingVenues = false,
    this.isLoadingFormFields = false,
    // Save states
    this.isSaving = false,
    this.saveSuccess = false,
    this.isSaveAsDraft = false,
    // Error states
    this.previewError,
    this.servicesError,
    this.packagesError,
    this.invoiceError,
    this.saveError,
    // Page 1
    this.availableEventTypes = const [],
    this.selectedEventType,
    this.customEventTypeName,
    this.availableTemplates = const [],
    this.selectedTemplate,
    this.uploadedTemplateFile,
    this.uploadedTemplateDescription,
    // Page 2
    this.eventName,
    this.eventDescription,
    this.eventDate,
    this.eventTime,
    this.availableVenues = const [],
    this.selectedVenue,
    this.customLocation,
    this.partnerWithGuests,
    this.eventTypeFormFields = const [],
    this.eventTypeFormData = const {},
    // Page 3
    this.previewImageUrl,
    // Page 4
    this.guests = const [],
    this.contactsGuests = const [],
    this.excelGuests = const [],
    this.manualGuests = const [],
    this.duplicatePhoneNumbers = const {},
    this.currentGuestInput = const GuestInfoModel(name: ''),
    // Page 5
    this.availableServices = const [],
    this.selectedServices = const [],
    // Page 6
    this.availablePackages = const [],
    this.selectedPackage,
    this.customPackageLimit,
    this.customPackagePrice,
    this.packageValidationError = false,
    // Page 7
    this.invoiceSummary,
    this.savedEventId,
    this.whatsappNumber,
    this.generatedInvoiceImage,
    // Results
    this.shareLink,
    this.invitationId,
    this.errorMessage,
  });

  /// Initial state
  factory InvitationState.initial() => const InvitationState();

  /// Check if event type is custom
  bool get isCustomEventType => selectedEventType?.isCustom ?? false;

  /// Check if template is custom (uploaded)
  bool get isCustomTemplate =>
      selectedTemplate?.isCustom ?? false || uploadedTemplateFile != null;

  /// Should skip preview page
  bool get shouldSkipPreview => isCustomEventType || isCustomTemplate;

  /// Total guest count from all sources
  int get totalGuestCount => guests.length;

  /// Alias for totalGuestCount (backward compatibility)
  @Deprecated('Use totalGuestCount instead')
  int get totalGuests => totalGuestCount;

  /// Check if package limit is exceeded
  bool get isPackageLimitExceeded {
    if (selectedPackage == null) return false;
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
    bool? isLoadingPreview,
    bool? isLoadingServices,
    bool? isLoadingPackages,
    bool? isLoadingInvoice,
    bool? isLoadingExcel,
    bool? isLoadingCustomPrice,
    bool? isLoadingVenues,
    bool? isLoadingFormFields,
    // Save states
    bool? isSaving,
    bool? saveSuccess,
    bool? isSaveAsDraft,
    // Error states
    String? previewError,
    String? servicesError,
    String? packagesError,
    String? invoiceError,
    String? saveError,
    // Page 1
    List<EventTypeModel>? availableEventTypes,
    EventTypeModel? selectedEventType,
    String? customEventTypeName,
    List<TemplateModel>? availableTemplates,
    TemplateModel? selectedTemplate,
    File? uploadedTemplateFile,
    String? uploadedTemplateDescription,
    // Page 2
    String? eventName,
    String? eventDescription,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    List<VenueModel>? availableVenues,
    VenueModel? selectedVenue,
    LocationModel? customLocation,
    int? partnerWithGuests,
    List<EventTypeFormField>? eventTypeFormFields,
    Map<String, dynamic>? eventTypeFormData,
    // Page 3
    String? previewImageUrl,
    // Page 4
    List<GuestInfoModel>? guests,
    List<GuestInfoModel>? contactsGuests,
    List<GuestInfoModel>? excelGuests,
    List<GuestInfoModel>? manualGuests,
    Set<String>? duplicatePhoneNumbers,
    GuestInfoModel? currentGuestInput,
    // Page 5
    List<ExtraServiceModel>? availableServices,
    List<ExtraServiceModel>? selectedServices,
    // Page 6
    List<PackageModel>? availablePackages,
    PackageModel? selectedPackage,
    int? customPackageLimit,
    double? customPackagePrice,
    bool? packageValidationError,
    // Page 7
    InvoiceSummaryModel? invoiceSummary,
    String? savedEventId,
    String? whatsappNumber,
    File? generatedInvoiceImage,
    // Results
    String? shareLink,
    String? invitationId,
    String? errorMessage,
    // Clear flags
    bool clearSelectedEventType = false,
    bool clearSelectedTemplate = false,
    bool clearUploadedTemplate = false,
    bool clearUploadedTemplateDescription = false,
    bool clearSelectedVenue = false,
    bool clearCustomLocation = false,
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
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isLoadingPackages: isLoadingPackages ?? this.isLoadingPackages,
      isLoadingInvoice: isLoadingInvoice ?? this.isLoadingInvoice,
      isLoadingExcel: isLoadingExcel ?? this.isLoadingExcel,
      isLoadingCustomPrice: isLoadingCustomPrice ?? this.isLoadingCustomPrice,
      isLoadingVenues: isLoadingVenues ?? this.isLoadingVenues,
      isLoadingFormFields: isLoadingFormFields ?? this.isLoadingFormFields,
      // Save states
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      isSaveAsDraft: isSaveAsDraft ?? this.isSaveAsDraft,
      // Error states
      previewError: previewError,
      servicesError: servicesError,
      packagesError: packagesError,
      invoiceError: invoiceError,
      saveError: saveError,
      // Page 1
      availableEventTypes: availableEventTypes ?? this.availableEventTypes,
      selectedEventType: clearSelectedEventType
          ? null
          : (selectedEventType ?? this.selectedEventType),
      customEventTypeName: customEventTypeName ?? this.customEventTypeName,
      availableTemplates: availableTemplates ?? this.availableTemplates,
      selectedTemplate: clearSelectedTemplate
          ? null
          : (selectedTemplate ?? this.selectedTemplate),
      uploadedTemplateFile: clearUploadedTemplate
          ? null
          : (uploadedTemplateFile ?? this.uploadedTemplateFile),
      uploadedTemplateDescription: clearUploadedTemplateDescription
          ? null
          : (uploadedTemplateDescription ?? this.uploadedTemplateDescription),
      // Page 2
      eventName: eventName ?? this.eventName,
      eventDescription: eventDescription ?? this.eventDescription,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      availableVenues: availableVenues ?? this.availableVenues,
      selectedVenue:
          clearSelectedVenue ? null : (selectedVenue ?? this.selectedVenue),
      customLocation:
          clearCustomLocation ? null : (customLocation ?? this.customLocation),
      partnerWithGuests: partnerWithGuests ?? this.partnerWithGuests,
      eventTypeFormFields: eventTypeFormFields ?? this.eventTypeFormFields,
      eventTypeFormData: eventTypeFormData ?? this.eventTypeFormData,
      // Page 3
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      // Page 4
      guests: guests ?? this.guests,
      contactsGuests: contactsGuests ?? this.contactsGuests,
      excelGuests: excelGuests ?? this.excelGuests,
      manualGuests: manualGuests ?? this.manualGuests,
      duplicatePhoneNumbers:
          duplicatePhoneNumbers ?? this.duplicatePhoneNumbers,
      currentGuestInput: currentGuestInput ?? this.currentGuestInput,
      // Page 5
      availableServices: availableServices ?? this.availableServices,
      selectedServices: selectedServices ?? this.selectedServices,
      // Page 6
      availablePackages: availablePackages ?? this.availablePackages,
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
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      generatedInvoiceImage:
          generatedInvoiceImage ?? this.generatedInvoiceImage,
      // Results
      shareLink: shareLink ?? this.shareLink,
      invitationId: invitationId ?? this.invitationId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // ============ Validation Helpers ============

  /// Check if page 1 is complete
  bool get canProceedFromEventType {
    if (selectedEventType == null) return false;
    if (selectedEventType!.isCustom && (customEventTypeName?.isEmpty ?? true)) {
      return false;
    }
    // Must have template selected, uploaded file, OR description for custom
    return selectedTemplate != null ||
        uploadedTemplateFile != null ||
        (uploadedTemplateDescription?.isNotEmpty ?? false);
  }

  /// Check if page 2 is complete
  bool get canProceedFromEventDetails {
    if (eventName == null || eventName!.isEmpty) return false;
    if (eventDate == null) return false;
    // Must have location (venue or custom)
    if (selectedVenue == null && customLocation == null) return false;
    return true;
  }

  /// Check if page 4 is complete
  bool get canProceedFromGuests => guests.isNotEmpty;
  bool get canProceedFromGuestManagement => guests.isNotEmpty;

  /// Check if page 6 is complete
  bool get canProceedFromPackage {
    if (selectedPackage == null) return false;
    return !isPackageLimitExceeded;
  }
  bool get canProceedFromPackageSelection => canProceedFromPackage;

  /// Get all guests from all sources (combined)
  List<GuestInfoModel> get allGuests => guests;

  /// Get progress percentage (0.0 - 1.0)
  double get progressPercentage {
    switch (currentStep) {
      case InvitationStep.eventTypeSelection:
        return 0.14;
      case InvitationStep.eventDetails:
        return 0.28;
      case InvitationStep.invitationPreview:
        return 0.42;
      case InvitationStep.guestManagement:
        return 0.57;
      case InvitationStep.extraServices:
        return 0.71;
      case InvitationStep.packageSelection:
        return 0.85;
      case InvitationStep.invoiceSummary:
        return 1.0;
      // Legacy steps (for backward compatibility)
      case InvitationStep.landing:
        return 0.0;
      case InvitationStep.eventType:
        return 0.14;
      case InvitationStep.creation:
        return 0.28;
      case InvitationStep.guests:
        return 0.42;
      case InvitationStep.share:
        return 0.57;
      case InvitationStep.package:
        return 0.71;
      case InvitationStep.payment:
        return 0.85;
      case InvitationStep.confirmation:
        return 1.0;
    }
  }

  /// Get step number (1-7)
  int get stepNumber {
    switch (currentStep) {
      case InvitationStep.eventTypeSelection:
        return 1;
      case InvitationStep.eventDetails:
        return 2;
      case InvitationStep.invitationPreview:
        return 3;
      case InvitationStep.guestManagement:
        return 4;
      case InvitationStep.extraServices:
        return 5;
      case InvitationStep.packageSelection:
        return 6;
      case InvitationStep.invoiceSummary:
        return 7;
      // Legacy steps (for backward compatibility)
      case InvitationStep.landing:
        return 1;
      case InvitationStep.eventType:
        return 2;
      case InvitationStep.creation:
        return 3;
      case InvitationStep.guests:
        return 4;
      case InvitationStep.share:
        return 5;
      case InvitationStep.package:
        return 6;
      case InvitationStep.payment:
        return 7;
      case InvitationStep.confirmation:
        return 8;
    }
  }

  /// Total steps
  int get totalSteps => 7;

  /// Guest statistics
  int get confirmedGuests =>
      guests.where((g) => g.status == GuestStatus.confirmed).length;
  int get declinedGuests =>
      guests.where((g) => g.status == GuestStatus.declined).length;
  int get pendingGuests =>
      guests.where((g) => g.status == GuestStatus.pending).length;

  /// Services total price
  double get servicesTotalPrice =>
      selectedServices.fold(0, (sum, s) => sum + s.price);

  // ============ Legacy Getters (backward compatibility) ============

  /// Legacy: Get event type as GoldenEventType (maps from selectedEventType)
  @Deprecated('Use selectedEventType instead')
  GoldenEventType? get eventType {
    if (selectedEventType == null) return null;
    // Map EventTypeModel to GoldenEventType by name
    switch (selectedEventType!.name.toLowerCase()) {
      case 'birthday':
        return GoldenEventType.birthday;
      case 'wedding':
        return GoldenEventType.wedding;
      case 'aqiqah':
        return GoldenEventType.aqiqah;
      case 'store opening':
      case 'storeopening':
        return GoldenEventType.storeOpening;
      default:
        return GoldenEventType.custom;
    }
  }

  /// Legacy: Get names list (maps from eventName)
  @Deprecated('Use eventName instead')
  List<String> get names => eventName != null ? [eventName!] : [];

  /// Legacy: Get location string (maps from selectedVenue or customLocation)
  @Deprecated('Use selectedVenue or customLocation instead')
  String? get location =>
      selectedVenue?.name ?? customLocation?.placeName ?? customLocation?.address;

  /// Legacy: Get location address
  @Deprecated('Use selectedVenue or customLocation instead')
  String? get locationAddress =>
      selectedVenue?.address ?? customLocation?.address;

  /// Legacy: Get selected template ID as string
  @Deprecated('Use selectedTemplate instead')
  String? get selectedTemplateId => selectedTemplate?.id?.toString();

  /// Legacy: Get selected package ID as string
  @Deprecated('Use selectedPackage instead')
  String? get selectedPackageId => selectedPackage?.id.toString();

  /// Legacy: Check if free plan is selected
  @Deprecated('Use selectedPackage?.price == 0 instead')
  bool get isFreePlanSelected => selectedPackage?.price == 0;

  /// Legacy: Check if can proceed from creation step
  @Deprecated('Use canProceedFromEventDetails instead')
  bool get canProceedFromCreation => canProceedFromEventDetails;

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
        isLoadingPreview,
        isLoadingServices,
        isLoadingPackages,
        isLoadingInvoice,
        isLoadingExcel,
        isLoadingCustomPrice,
        isLoadingVenues,
        isLoadingFormFields,
        // Save states
        isSaving,
        saveSuccess,
        isSaveAsDraft,
        // Error states
        previewError,
        servicesError,
        packagesError,
        invoiceError,
        saveError,
        // Page 1
        availableEventTypes,
        selectedEventType,
        customEventTypeName,
        availableTemplates,
        selectedTemplate,
        uploadedTemplateFile,
        uploadedTemplateDescription,
        // Page 2
        eventName,
        eventDescription,
        eventDate,
        eventTime,
        availableVenues,
        selectedVenue,
        customLocation,
        partnerWithGuests,
        eventTypeFormFields,
        eventTypeFormData,
        // Page 3
        previewImageUrl,
        // Page 4
        guests,
        contactsGuests,
        excelGuests,
        manualGuests,
        duplicatePhoneNumbers,
        currentGuestInput,
        // Page 5
        availableServices,
        selectedServices,
        // Page 6
        availablePackages,
        selectedPackage,
        customPackageLimit,
        customPackagePrice,
        packageValidationError,
        // Page 7
        invoiceSummary,
        savedEventId,
        whatsappNumber,
        generatedInvoiceImage,
        // Results
        shareLink,
        invitationId,
        errorMessage,
      ];
}
