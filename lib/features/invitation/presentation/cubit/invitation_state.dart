// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/extra_service_model.dart';
import '../../data/models/invitation_draft_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/location_model.dart';
import 'event_type_model.dart';

export 'event_type_model.dart';

/// Steps in the 3-page event creation wizard
enum InvitationStep {
  // Modern 3-page wizard steps
  eventSetup, // Page 1: Event type + template + details + preview
  guestsAndServices, // Page 2: Guest management + extra services
  reviewAndSubmit, // Page 3: Package selection + invoice + submit

  // Legacy 7-page steps (for backward compatibility)
  @Deprecated('Use eventSetup instead')
  eventTypeSelection,
  @Deprecated('Use eventSetup instead')
  eventDetails,
  @Deprecated('Use eventSetup instead')
  invitationPreview,
  @Deprecated('Use guestsAndServices instead')
  guestManagement,
  @Deprecated('Use guestsAndServices instead')
  extraServices,
  @Deprecated('Use reviewAndSubmit instead')
  packageSelection,
  @Deprecated('Use reviewAndSubmit instead')
  invoiceSummary,

  // Legacy steps (for backward compatibility with old flow)
  @Deprecated('Use eventSetup instead')
  landing,
  @Deprecated('Use eventSetup instead')
  eventType,
  @Deprecated('Use eventSetup instead')
  creation,
  @Deprecated('Use guestsAndServices instead')
  guests,
  @Deprecated('Use reviewAndSubmit instead')
  share,
  @Deprecated('Use reviewAndSubmit instead')
  package,
  @Deprecated('Use reviewAndSubmit instead')
  payment,
  @Deprecated('Use reviewAndSubmit instead')
  confirmation,
}

/// Status of invitation operations
enum InvitationStatus {
  initial,
  loading,
  success,
  failure,
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// Occasion group (أفراح، مواليد، ...) used by the two-step type picker.
class EventTypeGroupModel extends Equatable {
  final int id;
  final String slug;
  final String nameAr;
  final String nameEn;
  final String? icon;
  final String? color;

  const EventTypeGroupModel({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    this.icon,
    this.color,
  });

  factory EventTypeGroupModel.fromJson(Map<String, dynamic> json) {
    final nameAr = _asString(json['name_ar']) ?? _asString(json['name']) ?? '';
    final nameEn = _asString(json['name_en']) ?? nameAr;
    return EventTypeGroupModel(
      id: _asInt(json['id']) ?? 0,
      slug: _asString(json['slug']) ?? '',
      nameAr: nameAr.isNotEmpty ? nameAr : nameEn,
      nameEn: nameEn,
      icon: _asString(json['icon']),
      color: _asString(json['color']),
    );
  }

  bool get isOther => slug == 'other';

  @override
  List<Object?> get props => [id, slug, nameAr, nameEn, icon, color];
}

/// One option of a `select` / `radio` form field.
class FormFieldOption extends Equatable {
  final String value;
  final String labelAr;
  final String labelEn;

  const FormFieldOption({
    required this.value,
    required this.labelAr,
    required this.labelEn,
  });

  /// Accepts `{value,label_ar,label_en}`, `{value,label}` or a plain string.
  static FormFieldOption? tryParse(dynamic raw) {
    if (raw is String || raw is num) {
      final v = raw.toString();
      return v.isEmpty ? null : FormFieldOption(value: v, labelAr: v, labelEn: v);
    }
    if (raw is Map) {
      final value = _asString(raw['value']) ??
          _asString(raw['key']) ??
          _asString(raw['label_en']) ??
          _asString(raw['label_ar']) ??
          _asString(raw['label']);
      if (value == null) return null;
      final ar = _asString(raw['label_ar']) ?? _asString(raw['label']) ?? value;
      final en = _asString(raw['label_en']) ?? _asString(raw['label']) ?? ar;
      return FormFieldOption(value: value, labelAr: ar, labelEn: en);
    }
    return null;
  }

  @override
  List<Object?> get props => [value, labelAr, labelEn];
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
    // Gallery designs carry `title` instead of `name`.
    final name = json['name'] as String? ?? json['title'] as String? ?? '';
    // The API may return the image URL under different field names
    final previewUrl = json['preview_url'] as String? ??
        json['image_url'] as String? ??
        json['image'] as String? ??
        json['thumbnail'] as String? ??
        json['thumbnail_url'] as String? ??
        json['photo'] as String?;
    return TemplateModel(
      id: json['id'] as int?,
      name: name,
      nameAr: json['name_ar'] as String? ?? name,
      previewUrl: previewUrl,
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
    final name = json['name'] as String? ?? '';
    return VenueModel(
      id: json['id'] as int? ?? 0,
      name: name,
      nameAr: json['name_ar'] as String? ?? name,
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

  /// False for the free trial when this phone already used it (backend
  /// `is_available`); such a package is shown but cannot be selected.
  final bool isAvailable;

  /// Price after the institution discount (backend `final_price`).
  final double? finalPrice;
  final double discountPercent;

  /// A private package assigned to this institution only.
  final bool isPrivate;

  /// Price of one invitation (backend `price_per_invitation`); null for free
  /// or unlimited packages. Bigger packages cost less per invitation.
  final double? pricePerInvitation;

  /// Saving vs the dearest per-invitation package (backend
  /// `volume_saving_percent`); 0 when none.
  final int volumeSavingPercent;

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
    this.isAvailable = true,
    this.finalPrice,
    this.discountPercent = 0,
    this.isPrivate = false,
    this.pricePerInvitation,
    this.volumeSavingPercent = 0,
  });

  /// What the client actually pays (discounted when applicable).
  double get effectivePrice => finalPrice ?? price;

  bool get hasDiscount => finalPrice != null && finalPrice! < price;

  bool get hasUnlimitedInvitations => invitationLimit == null || invitationLimit == -1;

  /// Free / freemium package: a non-custom package with no price.
  /// Such events skip invoicing and are activated immediately.
  bool get isFree => !isCustom && price <= 0;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    // API returns name_en/name_ar, fallback to name for compatibility
    final nameEn = json['name_en'] as String? ?? json['name'] as String?;
    final nameAr = json['name_ar'] as String?;

    // Parse price from various formats (String or num)
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // Parse features from JSON string or list
    List<String> features = [];
    List<String> featuresAr = [];
    final featuresRaw = json['features'];
    if (featuresRaw is String) {
      // Features is a JSON string like {"ar":["..."],"en":["..."]}
      try {
        final parsed = jsonDecode(featuresRaw) as Map<String, dynamic>;
        features = (parsed['en'] as List?)?.map((e) => e.toString()).toList() ?? [];
        featuresAr = (parsed['ar'] as List?)?.map((e) => e.toString()).toList() ?? [];
      } catch (_) {
        // Ignore parsing errors
      }
    } else if (featuresRaw is List) {
      features = featuresRaw.map((e) => e.toString()).toList();
    }
    // Override featuresAr if provided separately
    if (json['features_ar'] is List) {
      featuresAr = (json['features_ar'] as List).map((e) => e.toString()).toList();
    }

    return PackageModel(
      id: json['id'] as int? ?? 0,
      name: nameEn ?? nameAr ?? '',
      nameAr: nameAr ?? nameEn ?? '',
      price: parsePrice(json['price']),
      // API uses invitations_limit, code expects invitation_limit
      invitationLimit: json['invitations_limit'] as int? ?? json['invitation_limit'] as int?,
      isCustom: json['is_custom'] as bool? ?? false,
      minInvitations: json['min_invitations'] as int?,
      features: features,
      featuresAr: featuresAr,
      isHighlighted: json['is_highlighted'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      finalPrice: json['final_price'] == null ? null : parsePrice(json['final_price']),
      discountPercent: parsePrice(json['discount_percent']),
      isPrivate: json['is_private'] == true || json['is_private'] == 1,
      pricePerInvitation: json['price_per_invitation'] == null ? null : parsePrice(json['price_per_invitation']),
      volumeSavingPercent: parsePrice(json['volume_saving_percent']).round(),
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
      isAvailable: isAvailable,
      finalPrice: finalPrice,
      discountPercent: discountPercent,
      isPrivate: isPrivate,
      pricePerInvitation: pricePerInvitation,
      volumeSavingPercent: volumeSavingPercent,
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
        pricePerInvitation,
        volumeSavingPercent,
      ];
}

/// Form field definition from API
class EventTypeFormField extends Equatable {
  final String key;
  final String label; // English label
  final String labelAr;
  final String type; // text, textarea, number, date, time, select, checkbox, radio
  final bool isRequired;
  final bool required; // Alias for isRequired
  final String? hint; // English placeholder
  final String? hintAr;
  final List<FormFieldOption> options;
  final int sortOrder;

  const EventTypeFormField({
    required this.key,
    required this.label,
    required this.labelAr,
    required this.type,
    bool isRequired = false,
    bool? required,
    this.hint,
    this.hintAr,
    this.options = const [],
    this.sortOrder = 0,
  }) : isRequired = required ?? isRequired,
       required = required ?? isRequired;

  factory EventTypeFormField.fromJson(Map<String, dynamic> json) {
    final key = _asString(json['field_key']) ?? _asString(json['key']) ?? '';
    final labelAr = _asString(json['label_ar']) ?? _asString(json['label']) ?? key;
    final labelEn = _asString(json['label_en']) ?? _asString(json['label']) ?? labelAr;
    final hintAr = _asString(json['placeholder_ar']) ??
        _asString(json['hint_ar']) ??
        _asString(json['placeholder']);
    final hintEn = _asString(json['placeholder_en']) ??
        _asString(json['hint']) ??
        _asString(json['placeholder']);

    var rawOptions = json['options'];
    if (rawOptions is Map) rawOptions = rawOptions.values.toList();
    final options = rawOptions is List
        ? rawOptions.map(FormFieldOption.tryParse).whereType<FormFieldOption>().toList()
        : const <FormFieldOption>[];

    return EventTypeFormField(
      key: key,
      label: labelEn,
      labelAr: labelAr,
      type: _asString(json['field_type']) ?? _asString(json['type']) ?? 'text',
      isRequired: _asBool(json['is_required'] ?? json['required']),
      hint: hintEn,
      hintAr: hintAr,
      options: options,
      sortOrder: _asInt(json['sort_order']) ?? 0,
    );
  }

  /// Parses a list of fields, dropping ones without a key, sorted by sort_order.
  static List<EventTypeFormField> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final fields = raw
        .whereType<Map>()
        .map((m) => EventTypeFormField.fromJson(Map<String, dynamic>.from(m)))
        .where((f) => f.key.isNotEmpty)
        .toList();
    fields.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return fields;
  }

  String localizedLabel(bool isEnglish) => isEnglish ? label : labelAr;

  String? localizedHint(bool isEnglish) => isEnglish ? (hint ?? hintAr) : (hintAr ?? hint);

  @override
  List<Object?> get props =>
      [key, label, labelAr, type, isRequired, hint, hintAr, options, sortOrder];
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
  final File? uploadedTemplateFile;
  final String? uploadedTemplateDescription;

  // Page 2: Event Details
  final String? eventName;
  final String? eventDescription;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final DateTime? eventEndDate;
  final TimeOfDay? eventEndTime;
  final List<VenueModel> availableVenues;
  final VenueModel? selectedVenue;
  final LocationModel? customLocation;
  final int? partnerWithGuests;

  /// RSVP settings (optional): last day guests can answer, and a personal
  /// message shown on the invitation page.
  final DateTime? rsvpDeadline;
  final String? invitationMessage;
  final List<EventTypeFormField> eventTypeFormFields;
  final Map<String, dynamic> eventTypeFormData;

  // Preview & AI Generation
  final String? previewImageUrl;
  final bool isGeneratingImage;
  final int? generatingImageId;
  final String? generatedImageUrl;
  final String? generationError;

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
  final File? generatedInvoiceImage;

  // Results & Errors
  final String? shareLink;
  final String? invitationId;
  final String? errorMessage;

  const InvitationState({
    // Navigation
    this.currentStep = InvitationStep.eventSetup,
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
    this.uploadedTemplateFile,
    this.uploadedTemplateDescription,
    // Page 2
    this.eventName,
    this.eventDescription,
    this.eventDate,
    this.eventTime,
    this.eventEndDate,
    this.eventEndTime,
    this.availableVenues = const [],
    this.selectedVenue,
    this.customLocation,
    this.partnerWithGuests,
    this.rsvpDeadline,
    this.invitationMessage,
    this.eventTypeFormFields = const [],
    this.eventTypeFormData = const {},
    // Preview & AI Generation
    this.previewImageUrl,
    this.isGeneratingImage = false,
    this.generatingImageId,
    this.generatedImageUrl,
    this.generationError,
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
    this.generatedInvoiceImage,
    // Results
    this.shareLink,
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

  /// Check if event type is custom
  bool get isCustomEventType => selectedEventType?.isCustom ?? false;

  /// Check if template is custom (uploaded)
  bool get isCustomTemplate =>
      (selectedTemplate?.isCustom ?? false) || uploadedTemplateFile != null;

  /// Should skip preview page
  /// Skip only if custom event type or custom template without uploaded image
  /// (e.g., only description sent to admin). Show preview if an image was uploaded.
  bool get shouldSkipPreview =>
      isCustomEventType ||
      (isCustomTemplate && uploadedTemplateFile == null);

  /// Total guest count from all sources
  int get totalGuestCount => guests.length;

  /// Alias for totalGuestCount (backward compatibility)
  @Deprecated('Use totalGuestCount instead')
  int get totalGuests => totalGuestCount;

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
    File? uploadedTemplateFile,
    String? uploadedTemplateDescription,
    // Page 2
    String? eventName,
    String? eventDescription,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    DateTime? eventEndDate,
    TimeOfDay? eventEndTime,
    bool clearEventEndDate = false,
    List<VenueModel>? availableVenues,
    VenueModel? selectedVenue,
    LocationModel? customLocation,
    int? partnerWithGuests,
    DateTime? rsvpDeadline,
    bool clearRsvpDeadline = false,
    String? invitationMessage,
    List<EventTypeFormField>? eventTypeFormFields,
    Map<String, dynamic>? eventTypeFormData,
    // Preview & AI Generation
    String? previewImageUrl,
    bool? isGeneratingImage,
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
    GuestInfoModel? currentGuestInput,
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
      eventEndDate: clearEventEndDate ? null : (eventEndDate ?? this.eventEndDate),
      eventEndTime: eventEndTime ?? this.eventEndTime,
      availableVenues: availableVenues ?? this.availableVenues,
      selectedVenue:
          clearSelectedVenue ? null : (selectedVenue ?? this.selectedVenue),
      customLocation:
          clearCustomLocation ? null : (customLocation ?? this.customLocation),
      partnerWithGuests:
          clearPartnerWithGuests ? null : (partnerWithGuests ?? this.partnerWithGuests),
      rsvpDeadline: clearRsvpDeadline ? null : (rsvpDeadline ?? this.rsvpDeadline),
      invitationMessage: invitationMessage ?? this.invitationMessage,
      eventTypeFormFields: eventTypeFormFields ?? this.eventTypeFormFields,
      eventTypeFormData: eventTypeFormData ?? this.eventTypeFormData,
      // Preview & AI Generation
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      isGeneratingImage: isGeneratingImage ?? this.isGeneratingImage,
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
      currentGuestInput: currentGuestInput ?? this.currentGuestInput,
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
      generatedInvoiceImage:
          generatedInvoiceImage ?? this.generatedInvoiceImage,
      // Results
      shareLink: shareLink ?? this.shareLink,
      invitationId: invitationId ?? this.invitationId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // ============ Validation Helpers ============

  /// Check if Page 1 (Event Type + AI Design) is complete.
  /// Accepts any of: AI-generated image, an uploaded file, a freeform description.
  /// (The legacy template selection is no longer part of the wizard UI.)
  bool get canProceedFromEventType {
    if (selectedEventType == null) return false;
    if (selectedEventType!.isCustom && (customEventTypeName?.isEmpty ?? true)) {
      return false;
    }
    return (generatedImageUrl?.isNotEmpty ?? false)
        || uploadedTemplateFile != null
        || (uploadedTemplateDescription?.isNotEmpty ?? false);
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
      // Modern 3-page wizard
      case InvitationStep.eventSetup:
        return 0.33;
      case InvitationStep.guestsAndServices:
        return 0.66;
      case InvitationStep.reviewAndSubmit:
        return 1.0;
      // Legacy 7-page steps → map to closest modern step
      case InvitationStep.eventTypeSelection:
      case InvitationStep.eventDetails:
      case InvitationStep.invitationPreview:
      case InvitationStep.landing:
      case InvitationStep.eventType:
      case InvitationStep.creation:
        return 0.33;
      case InvitationStep.guestManagement:
      case InvitationStep.extraServices:
      case InvitationStep.guests:
        return 0.66;
      case InvitationStep.packageSelection:
      case InvitationStep.invoiceSummary:
      case InvitationStep.share:
      case InvitationStep.package:
      case InvitationStep.payment:
      case InvitationStep.confirmation:
        return 1.0;
    }
  }

  /// Get step number (1-3)
  int get stepNumber {
    switch (currentStep) {
      case InvitationStep.eventSetup:
      case InvitationStep.eventTypeSelection:
      case InvitationStep.eventDetails:
      case InvitationStep.invitationPreview:
      case InvitationStep.landing:
      case InvitationStep.eventType:
      case InvitationStep.creation:
        return 1;
      case InvitationStep.guestsAndServices:
      case InvitationStep.guestManagement:
      case InvitationStep.extraServices:
      case InvitationStep.guests:
        return 2;
      case InvitationStep.reviewAndSubmit:
      case InvitationStep.packageSelection:
      case InvitationStep.invoiceSummary:
      case InvitationStep.share:
      case InvitationStep.package:
      case InvitationStep.payment:
      case InvitationStep.confirmation:
        return 3;
    }
  }

  /// Total steps
  int get totalSteps => 3;

  /// Guest statistics
  int get confirmedGuests =>
      guests.where((g) => g.status == GuestStatus.confirmed).length;
  int get declinedGuests =>
      guests.where((g) => g.status == GuestStatus.declined).length;
  int get pendingGuests =>
      guests.where((g) => g.status == GuestStatus.pending).length;

  /// Services total price
  double get servicesTotalPrice =>
      selectedServices.fold(0, (sum, s) => sum + s.effectivePrice);

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
        uploadedTemplateFile,
        uploadedTemplateDescription,
        // Page 2
        eventName,
        eventDescription,
        eventDate,
        eventTime,
        eventEndDate,
        eventEndTime,
        availableVenues,
        selectedVenue,
        customLocation,
        partnerWithGuests,
        rsvpDeadline,
        invitationMessage,
        eventTypeFormFields,
        eventTypeFormData,
        // Preview & AI Generation
        previewImageUrl,
        isGeneratingImage,
        generatingImageId,
        generatedImageUrl,
        generationError,
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
        generatedInvoiceImage,
        // Results
        shareLink,
        invitationId,
        errorMessage,
      ];
}
