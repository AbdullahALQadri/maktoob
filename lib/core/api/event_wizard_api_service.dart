import 'dart:io';

import 'api_consumer.dart';
import 'end_points.dart';

/// Service for Event Wizard API calls
class EventWizardApiService {
  final ApiConsumer _apiConsumer;

  EventWizardApiService({required this._apiConsumer});

  // ============================================================
  // PAGE 1: Event Type & Template Selection
  // ============================================================

  /// Get all event types with templates
  Future<Map<String, dynamic>> getEventTypes() async {
    final response = await _apiConsumer.get(Endpoints.wizardEventTypes);
    return response as Map<String, dynamic>;
  }

  /// Ready-made designs for an event type (the public gallery; there is no
  /// wizard templates route).
  Future<Map<String, dynamic>> getTemplatesForEventType(int eventTypeId) async {
    final response = await _apiConsumer.get(
      Endpoints.publicTemplates,
      queryParameters: {'event_type_id': eventTypeId},
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
    int? institutionId,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardInitialize,
      body: {
        // Owner / manager creating on behalf of an approved institution.
        'institution_id': ?institutionId,
        'event_type_id': ?eventTypeId,
        'custom_event_type_name': ?customEventTypeName,
        // Designs come from the public gallery (ai_generated_images); the
        // server links a gallery image as the event's design by this key.
        'ai_generated_image_id': ?templateId,
      },
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 2: Event Details
  // ============================================================

  static String _dateTime(DateTime d, String? hhmm) {
    final day = d.toIso8601String().split('T')[0];
    return hhmm == null || hhmm.isEmpty ? day : '$day $hhmm';
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
    DateTime? eventEndDate,
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
    final response = await _apiConsumer.put(
      Endpoints.wizardSaveDetails(eventId),
      body: {
        // Backend unified title_ar/title_en -> title and description_* ->
        // description (migration 2026_07_01); event_date/end_date are datetimes.
        'title': titleAr,
        'description': ?descriptionAr,
        // event_date/end_date are datetimes: send "YYYY-MM-DD HH:MM".
        'event_date': _dateTime(eventDate, eventTime),
        // Always sent: null clears an end the host took away (one day again).
        'end_date': eventEndDate?.toIso8601String().substring(0, 16).replaceFirst('T', ' '),
        'venue_id': ?venueId,
        'custom_venue_name_ar': ?customVenueNameAr,
        'custom_venue_name_en': ?customVenueNameEn,
        'custom_venue_address_ar': ?customVenueAddressAr,
        'custom_venue_address_en': ?customVenueAddressEn,
        'custom_venue_lat': ?customVenueLat,
        'custom_venue_lng': ?customVenueLng,
        'partner_count': ?partnerCount,
        'event_type_form_values': ?eventTypeFormValues,
      },
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 3: Invitation Preview
  // ============================================================

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
    List<String>? moodTags,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardGeneratePrompt(eventId),
      body: {
        if (basePrompt != null && basePrompt.isNotEmpty) 'base_prompt': basePrompt,
        if (freeformPrompt != null && freeformPrompt.isNotEmpty) 'prompt': freeformPrompt,
        'event_type_id': eventTypeId,
        if (formValues.isNotEmpty) 'form_values': formValues,
        if (customPrompt != null && customPrompt.isNotEmpty) 'custom_prompt': customPrompt,
        if (moodTags != null && moodTags.isNotEmpty) 'mood_tags': moodTags,
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

  /// Upload a custom (non-AI) image to use as the event design.
  /// Returns { image_id, status: "completed", image_url, source: "upload" }.
  Future<Map<String, dynamic>> uploadCustomDesign(
    int eventId,
    File image,
  ) async {
    final response = await _apiConsumer.postWithImage(
      Endpoints.wizardUploadDesign(eventId),
      params: _FileParams(image),
    );
    return response as Map<String, dynamic>;
  }

  /// Save the generated AI image as the event cover
  Future<Map<String, dynamic>> saveAiImageToEvent(
    int eventId, {
    required int imageId,
  }) async {
    final response = await _apiConsumer.put(
      Endpoints.wizardSaveAiImage(eventId),
      body: {'ai_generated_image_id': imageId},
    );
    return response as Map<String, dynamic>;
  }

  // ============================================================
  // PAGE 4: Guest Management
  // ============================================================

  /// Sync the wizard guest list. The wizard always sends its whole list, so
  /// `replace` lets the server drop guests the host removed (they would
  /// otherwise still be invited at save).
  Future<Map<String, dynamic>> addManualGuests(
    int eventId,
    List<Map<String, String>> guests,
  ) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardGuestsManual(eventId),
      body: {'guests': guests, 'replace': true},
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
    final response = await _apiConsumer.put(
      Endpoints.wizardInvitationConfig(eventId),
      body: {
        'default_delivery_method': defaultDeliveryMethod,
        'message_ar': ?messageAr,
        'message_en': ?messageEn,
        'refusal_message_ar': ?refusalMessageAr,
        'refusal_message_en': ?refusalMessageEn,
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
    List<int> serviceIds, {
    Map<String, int>? options,
  }) async {
    final response = await _apiConsumer.post(
      Endpoints.wizardServices(eventId),
      body: {
        'service_ids': serviceIds,
        // service id => level id; a service with levels defaults to its cheapest.
        if (options != null && options.isNotEmpty) 'service_options': options,
      },
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
        'package_id': ?packageId,
        'is_custom_package': isCustomPackage,
        'custom_guest_count': ?customGuestCount,
        'custom_service_ids': ?customServiceIds,
        'custom_channels': ?customChannels,
        'custom_features': ?customFeatures,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// Server price of a custom package for [guestCount] invitations. The
  /// same calculation backs the custom package chosen at selectPackage.
  Future<Map<String, dynamic>> calculateCustomPackage(int guestCount) async {
    final response = await _apiConsumer.post(
      Endpoints.customPackageCalculate,
      body: {'guest_count': guestCount},
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
