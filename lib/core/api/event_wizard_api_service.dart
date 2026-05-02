import 'dart:io';

import '../api/api_consumer.dart';
import '../api/end_points.dart';

/// Service for Event Wizard API calls
class EventWizardApiService {
  final ApiConsumer _apiConsumer;

  EventWizardApiService({required ApiConsumer apiConsumer})
      : _apiConsumer = apiConsumer;

  // ============================================================
  // PAGE 1: Event Type & Template Selection
  // ============================================================

  /// Get all event types with templates
  Future<Map<String, dynamic>> getEventTypes() async {
    final response = await _apiConsumer.get(Endpoints.wizardEventTypes);
    return response as Map<String, dynamic>;
  }

  /// Get templates for specific event type
  Future<Map<String, dynamic>> getTemplatesForEventType(int eventTypeId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardEventTypeTemplates(eventTypeId),
    );
    return response as Map<String, dynamic>;
  }

  /// Create custom event type
  Future<Map<String, dynamic>> createCustomEventType({
    required String nameAr,
    String? nameEn,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardCustomEventType,
      body: {
        'name_ar': nameAr,
        'name_en': nameEn,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Initialize wizard - creates draft event
  Future<Map<String, dynamic>> initializeWizard({
    int? eventTypeId,
    String? customEventTypeName,
    int? templateId,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardInitialize,
      body: {
        if (eventTypeId != null) 'event_type_id': eventTypeId,
        if (customEventTypeName != null)
          'custom_event_type_name': customEventTypeName,
        if (templateId != null) 'template_id': templateId,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Submit custom template (file upload or description)
  Future<Map<String, dynamic>> submitCustomTemplate({
    required int eventId,
    File? uploadFile,
    String? description,
  }) async {
    final response = await _apiConsumer.postWithImage(
      Endpoints.wizardCustomTemplate(eventId),
      body: {
        if (description != null) 'description': description,
      },
      params: uploadFile != null ? _FileParams(uploadFile) : null,
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 2: Event Details
  // ============================================================

  /// Get form fields for event details
  Future<Map<String, dynamic>> getEventFormFields(int eventId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardFormFields(eventId),
    );
    return response as Map<String, dynamic>;
  }

  /// Save event details
  Future<Map<String, dynamic>> saveEventDetails(
    int eventId, {
    required String titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    required DateTime eventDate,
    String? eventTime,
    int? venueId,
    String? customVenueNameAr,
    String? customVenueNameEn,
    String? customVenueAddressAr,
    String? customVenueAddressEn,
    double? customVenueLat,
    double? customVenueLng,
    int? partnerCount,
    Map<String, dynamic>? eventTypeFormValues,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardSaveDetails(eventId),
      body: {
        'title_ar': titleAr,
        if (titleEn != null) 'title_en': titleEn,
        if (descriptionAr != null) 'description_ar': descriptionAr,
        if (descriptionEn != null) 'description_en': descriptionEn,
        'event_date': eventDate.toIso8601String().split('T')[0],
        if (eventTime != null) 'event_time': eventTime,
        if (venueId != null) 'venue_id': venueId,
        if (customVenueNameAr != null) 'custom_venue_name_ar': customVenueNameAr,
        if (customVenueNameEn != null) 'custom_venue_name_en': customVenueNameEn,
        if (customVenueAddressAr != null)
          'custom_venue_address_ar': customVenueAddressAr,
        if (customVenueAddressEn != null)
          'custom_venue_address_en': customVenueAddressEn,
        if (customVenueLat != null) 'custom_venue_lat': customVenueLat,
        if (customVenueLng != null) 'custom_venue_lng': customVenueLng,
        if (partnerCount != null) 'partner_count': partnerCount,
        if (eventTypeFormValues != null)
          'event_type_form_values': eventTypeFormValues,
      },
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 3: Invitation Preview
  // ============================================================

  /// Get invitation preview
  Future<Map<String, dynamic>> getInvitationPreview(int eventId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardPreview(eventId),
    );
    return response as Map<String, dynamic>;
  }

  /// Generate AI template image
  Future<Map<String, dynamic>> generateTemplate(
    int eventId, {
    String? prompt,
    String? basePrompt,
    int? eventTypeId,
    Map<String, dynamic>? formValues,
    String? customPrompt,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardGenerateTemplate(eventId),
      body: {
        if (prompt != null) 'prompt': prompt,
        if (basePrompt != null) 'base_prompt': basePrompt,
        if (eventTypeId != null) 'event_type_id': eventTypeId,
        if (formValues != null) 'form_values': formValues,
        if (customPrompt != null) 'custom_prompt': customPrompt,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Poll AI generation status
  Future<Map<String, dynamic>> getGenerationStatus(
    int eventId,
    int imageId,
  ) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardGenerationStatus(eventId, imageId),
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // AI DESIGN STUDIO — Two-step generation
  // ============================================================

  /// Gallery: get completed AI images filtered by event type
  Future<Map<String, dynamic>> getAiGalleryImages({int? eventTypeId}) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardAiImages,
      queryParameters: eventTypeId != null ? {'event_type_id': eventTypeId} : null,
    );
    return response as Map<String, dynamic>;
  }

  /// Get dynamic AI form fields for an event type
  Future<Map<String, dynamic>> getAiFormFields(int eventTypeId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardAiFormFields(eventTypeId),
    );
    return response as Map<String, dynamic>;
  }

  /// Step 1: Generate Arabic prompt text (no image yet)
  /// Returns { image_id, status: "processing" } — poll generation-status next
  Future<Map<String, dynamic>> generatePrompt(
    int eventId, {
    String? basePrompt,    // Tab 1: from selected gallery image (internal)
    String? freeformPrompt, // Tab 2: user typed prompt
    required int eventTypeId,
    required Map<String, String> formValues,
    String? customPrompt,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardGeneratePrompt(eventId),
      body: {
        if (basePrompt != null && basePrompt.isNotEmpty) 'base_prompt': basePrompt,
        if (freeformPrompt != null && freeformPrompt.isNotEmpty) 'prompt': freeformPrompt,
        'event_type_id': eventTypeId,
        if (formValues.isNotEmpty) 'form_values': formValues,
        if (customPrompt != null && customPrompt.isNotEmpty) 'custom_prompt': customPrompt,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Step 2: Confirm reviewed prompt and generate the actual image
  /// Returns { image_id, status: "processing" } — poll generation-status next
  Future<Map<String, dynamic>> confirmGenerate(
    int eventId, {
    required int imageId,
    required String promptText,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardConfirmGenerate(eventId),
      body: {
        'image_id': imageId,
        'prompt_text': promptText,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Save the generated AI image as the event cover
  Future<Map<String, dynamic>> saveAiImageToEvent(
    int eventId, {
    required int imageId,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardSaveAiImage(eventId),
      body: {'ai_generated_image_id': imageId},
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 4: Guest Management
  // ============================================================

  /// Get guests for event
  Future<Map<String, dynamic>> getGuests(int eventId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardGuests(eventId),
    );
    return response as Map<String, dynamic>;
  }

  /// Import guests from contacts
  Future<Map<String, dynamic>> importFromContacts(
    int eventId,
    List<Map<String, String>> contacts,
  ) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardGuestsContacts(eventId),
      body: {'contacts': contacts},
    );
    return response as Map<String, dynamic>;
  }

  /// Import guests from Excel
  Future<Map<String, dynamic>> importFromExcel(
    int eventId,
    File excelFile,
  ) async {
    final response = await _apiConsumer.postWithImage(
      Endpoints.wizardGuestsExcel(eventId),
      params: _FileParams(excelFile),
    );
    return response as Map<String, dynamic>;
  }

  /// Add guests manually
  Future<Map<String, dynamic>> addManualGuests(
    int eventId,
    List<Map<String, String>> guests,
  ) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardGuestsManual(eventId),
      body: {'guests': guests},
    );
    return response as Map<String, dynamic>;
  }

  /// Remove a guest
  Future<Map<String, dynamic>> removeGuest(int eventId, int guestId) async {
    final response = await _apiConsumer.delete(
      Endpoints.wizardGuestDelete(eventId, guestId),
    );
    return response as Map<String, dynamic>;
  }

  /// Remove duplicate guests
  Future<Map<String, dynamic>> removeDuplicates(int eventId) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardGuestsRemoveDuplicates(eventId),
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 4.5: Invitation Configuration
  // ============================================================

  /// Save invitation configuration
  Future<Map<String, dynamic>> saveInvitationConfig(
    int eventId, {
    required String defaultDeliveryMethod,
    String? messageAr,
    String? messageEn,
    String? refusalMessageAr,
    String? refusalMessageEn,
    bool allowCompanions = false,
    int maxCompanions = 0,
    bool requireResponse = true,
    DateTime? responseDeadline,
    bool askReasonEnabled = true,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardInvitationConfig(eventId),
      body: {
        'default_delivery_method': defaultDeliveryMethod,
        if (messageAr != null) 'message_ar': messageAr,
        if (messageEn != null) 'message_en': messageEn,
        if (refusalMessageAr != null) 'refusal_message_ar': refusalMessageAr,
        if (refusalMessageEn != null) 'refusal_message_en': refusalMessageEn,
        'allow_companions': allowCompanions,
        'max_companions': maxCompanions,
        'require_response': requireResponse,
        if (responseDeadline != null)
          'response_deadline': responseDeadline.toIso8601String().split('T')[0],
        'ask_reason_enabled': askReasonEnabled,
      },
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 5: Extra Services
  // ============================================================

  /// Get extra services for event
  Future<Map<String, dynamic>> getExtraServices(int eventId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardServices(eventId),
    );
    return response as Map<String, dynamic>;
  }

  /// Save selected extra services
  Future<Map<String, dynamic>> saveExtraServices(
    int eventId,
    List<int> serviceIds,
  ) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardServices(eventId),
      body: {'service_ids': serviceIds},
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 6: Packages
  // ============================================================

  /// Get packages
  Future<Map<String, dynamic>> getPackages(int eventId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardPackages(eventId),
    );
    return response as Map<String, dynamic>;
  }

  /// Select package
  Future<Map<String, dynamic>> selectPackage(
    int eventId, {
    int? packageId,
    bool isCustomPackage = false,
    int? customGuestCount,
    List<int>? customServiceIds,
    List<String>? customChannels,
    List<String>? customFeatures,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardSelectPackage(eventId),
      body: {
        if (packageId != null) 'package_id': packageId,
        'is_custom_package': isCustomPackage,
        if (customGuestCount != null) 'custom_guest_count': customGuestCount,
        if (customServiceIds != null) 'custom_service_ids': customServiceIds,
        if (customChannels != null) 'custom_channels': customChannels,
        if (customFeatures != null) 'custom_features': customFeatures,
      },
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 7: Invoice & Save
  // ============================================================

  /// Get invoice summary
  Future<Map<String, dynamic>> getInvoiceSummary(int eventId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardInvoice(eventId),
    );
    return response as Map<String, dynamic>;
  }

  /// Save event (final submission or draft)
  Future<Map<String, dynamic>> saveEvent(
    int eventId, {
    bool isDraft = false,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardSave(eventId),
      body: {'action': isDraft ? 'draft' : 'save'},
    );
    return response as Map<String, dynamic>;
  }

  /// Get wizard state
  Future<Map<String, dynamic>> getWizardState(int eventId) async {
    final response = await _apiConsumer.get(
      Endpoints.wizardState(eventId),
    );
    return response as Map<String, dynamic>;
  }

  /// Activate event (after payment - converts draft guests to invitations)
  Future<Map<String, dynamic>> activateEvent(int eventId) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardActivate(eventId),
    );
    return response as Map<String, dynamic>;
  }
}

/// Helper class for file uploads
class _FileParams {
  final File image;
  _FileParams(this.image);
}
