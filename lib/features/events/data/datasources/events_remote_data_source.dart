import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/api/event_wizard_api_service.dart';
import '../../../../core/api/paginated_fetch.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../models/edit_request_model.dart';
import '../models/event_model.dart';
import '../models/guest_model.dart';

abstract class EventsRemoteDataSource {
  Future<bool> hasPendingPaymentRequest(String eventId);
  Future<List<EventModel>> getEvents();
  Future<EventModel> getEventDetails(String eventId);
  Future<List<GuestModel>> getEventGuests(String eventId);
  Future<EventModel> createEvent(CreateEventParams params);
  Future<EventModel> updateEvent(String eventId, UpdateEventParams params);
  Future<void> deleteEvent(String eventId);
  Future<List<EventModel>> filterEvents({
    String? searchQuery,
    EventStatus? status,
  });
  Future<EditRequestModel> submitEditRequest(
      String eventId, UpdateEventParams params);
  Future<List<EditRequestModel>> getEditRequests(String eventId);

  /// Sends every pending invitation on [method]. Returns `{dispatched, ...}`.
  Future<Map<String, dynamic>> sendInvitations(String eventId, String method);

  /// Adds guests to a live event. Returns `{created, sent, duplicates, invalid_phones, over_limit_count}`.
  Future<Map<String, dynamic>> addGuests(String eventId, List<Map<String, String>> guests);

  Future<void> resendInvitation(String invitationId);
  Future<void> removeInvitation(String invitationId);
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final ApiConsumer apiConsumer;
  final EventWizardApiService? wizardApiService;

  EventsRemoteDataSourceImpl({
    required this.apiConsumer,
    this.wizardApiService,
  });

  /// `GET /payment-requests?status=pending` → `{payment_requests: [{event_id, ...}]}`.
  @override
  Future<bool> hasPendingPaymentRequest(String eventId) async {
    final response = await apiConsumer.get(
      Endpoints.paymentRequests,
      queryParameters: {'status': 'pending', 'per_page': 100},
    );
    final list = response is Map
        ? (response['payment_requests'] ?? response['data'])
        : null;
    if (list is! List) return false;
    return list.any((r) =>
        r is Map &&
        '${r['event_id'] ?? (r['event'] is Map ? r['event']['id'] : '')}' == eventId);
  }

  @override
  Future<List<EventModel>> getEvents() async {
    return _fetchAllEvents(const {});
  }

  /// GET /events returns the raw Laravel paginator ({data, current_page,
  /// last_page, ...}). Walk every page (bounded) so hosts with more events
  /// than one page don't silently lose the rest.
  Future<List<EventModel>> _fetchAllEvents(Map<String, dynamic> query) {
    return Pagination.fetchAll(
      apiConsumer,
      Endpoints.events,
      query: query,
      perPage: 50,
      maxPages: 20,
      parse: EventModel.fromJson,
    );
  }

  @override
  Future<EventModel> getEventDetails(String eventId) async {
    final response =
        await apiConsumer.get(Endpoints.event(int.parse(eventId)));
    // API returns {"event": {...}} for single event details
    final json = Map<String, dynamic>.from((response['event'] ?? response['data']) as Map);
    // Door attendance lives in GET /events/{id}/statistics
    // ({statistics: {checked_in, checked_in_companions, attendees}}).
    // Best effort: details still load if it fails.
    try {
      final stats = await apiConsumer.get(Endpoints.eventStatistics(int.parse(eventId)));
      final s = stats is Map ? (stats['statistics'] ?? stats['data']) : null;
      if (s is Map) json.addAll(mergeDoorStatistics(s));
    } catch (_) {}
    return EventModel.fromJson(json);
  }

  /// The statistics fields that override the event payload.
  /// Also maps the RSVP counts, which the event payload doesn't carry.
  static Map<String, dynamic> mergeDoorStatistics(Map stats) {
    int n(String k) => stats[k] is num ? (stats[k] as num).toInt() : int.tryParse('${stats[k]}') ?? 0;
    return {
      for (final k in const ['checked_in', 'checked_in_companions', 'attendees'])
        if (stats[k] != null) k: stats[k],
      if (stats['responded'] != null) 'responses': n('responded'),
      if (stats['attending'] != null) 'attending': n('attending'),
      if (stats['not_attending'] != null) 'declined': n('not_attending'),
      if (stats['total_invitations'] != null)
        'pending': (n('total_invitations') - n('responded')).clamp(0, 1 << 30),
    };
  }

  @override
  Future<List<GuestModel>> getEventGuests(String eventId) {
    // GET /events/{id}/invitations is a Resource collection
    // ({data, links, meta{last_page}}, 15 per page by default). Walk the
    // pages so hosts with large guest lists see every guest.
    return Pagination.fetchAll(
      apiConsumer,
      Endpoints.eventInvitations(int.parse(eventId)),
      perPage: 200,
      maxPages: 50,
      parse: GuestModel.fromJson,
    );
  }

  @override
  Future<EventModel> createEvent(CreateEventParams params) async {
    if (wizardApiService != null) {
      // Step 1: Initialize wizard
      final initResponse = await wizardApiService!.initializeWizard(
        eventTypeId: params.eventTypeId,
        templateId: params.templateId,
      );
      final eventId = initResponse['data']['event_id'] as int;

      // Step 2: Save event details
      await wizardApiService!.saveEventDetails(
        eventId,
        titleAr: params.name,
        eventDate: params.eventDate,
        eventTime: _formatTimeForApi(params.eventDate),
        venueId: params.venueId,
        customVenueNameAr: params.venue,
        customVenueAddressAr: params.venueAddress,
      );

      // Step 3: Add guests if any
      if (params.guests != null && params.guests!.isNotEmpty) {
        await wizardApiService!.addManualGuests(
          eventId,
          params.guests!
              .map((g) => {'name': g.name, 'phone': g.phone})
              .toList(),
        );
      }

      // Step 4: Save invitation config
      await wizardApiService!.saveInvitationConfig(
        eventId,
        defaultDeliveryMethod: 'whatsapp',
        allowCompanions: params.allowCompanions,
        maxCompanions: params.maxCompanions,
      );

      // Step 5: Select package if provided
      if (params.packageId != null) {
        await wizardApiService!
            .selectPackage(eventId, packageId: params.packageId);
      }

      // Step 6: Save as draft
      final saveResponse =
          await wizardApiService!.saveEvent(eventId, isDraft: true);

      return EventModel.fromJson(
          saveResponse['data']['event'] ?? saveResponse['data']);
    }

    // Fallback: direct API call
    final response = await apiConsumer.post(
      Endpoints.events,
      body: {
        'title_ar': params.name,
        'event_date':
            params.eventDate.toIso8601String().split('T')[0],
        'event_time': _formatTimeForApi(params.eventDate),
        if (params.venueId != null) 'venue_id': params.venueId,
        if (params.venue.isNotEmpty) 'custom_venue_name_ar': params.venue,
        if (params.venueAddress != null)
          'custom_venue_address_ar': params.venueAddress,
        if (params.description != null)
          'description_ar': params.description,
      },
    );
    return EventModel.fromJson(response['data']);
  }

  @override
  Future<EventModel> updateEvent(
      String eventId, UpdateEventParams params) async {
    final response = await apiConsumer.put(
      Endpoints.event(int.parse(eventId)),
      body: {
        if (params.name != null) 'title': params.name,
        if (params.venueId != null) 'venue_id': params.venueId,
        if (params.venue != null) 'custom_venue_name_ar': params.venue,
        if (params.venueAddress != null)
          'custom_venue_address_ar': params.venueAddress,
        if (params.description != null) 'description': params.description,
        if (params.eventDate != null)
          // Date + time; a date-only value reset the time to 00:00.
          'event_date': _formatDateTimeForApi(params.eventDate!),
        if (params.rsvpDeadline != null)
          'response_deadline':
              params.rsvpDeadline!.toIso8601String().split('T')[0],
        if (params.status != null) 'status': params.status!.apiValue,
        if (params.maxCompanions != null)
          'max_companions': params.maxCompanions,
        if (params.allowCompanions != null)
          'allow_companions': params.allowCompanions,
      },
    );
    // API returns {"event": {...}} for update response
    return EventModel.fromJson(response['event'] ?? response['data']);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await apiConsumer.delete(Endpoints.event(int.parse(eventId)));
  }

  @override
  Future<List<EventModel>> filterEvents({
    String? searchQuery,
    EventStatus? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }
    if (status != null) {
      queryParams['status'] = status.apiValue;
    }
    return _fetchAllEvents(queryParams);
  }

  @override
  Future<EditRequestModel> submitEditRequest(
      String eventId, UpdateEventParams params) async {
    final body = <String, dynamic>{};
    if (params.name != null) body['name'] = params.name;
    if (params.venue != null) body['venue'] = params.venue;
    if (params.venueAddress != null) {
      body['venue_address'] = params.venueAddress;
    }
    if (params.description != null) {
      body['description'] = params.description;
    }
    if (params.eventDate != null) {
      body['event_date'] = _formatDateTimeForApi(params.eventDate!);
    }
    if (params.maxCompanions != null) {
      body['max_companions'] = params.maxCompanions;
    }
    if (params.allowCompanions != null) {
      body['allow_companions'] = params.allowCompanions;
    }
    if (params.rsvpDeadline != null) {
      body['rsvp_deadline'] =
          params.rsvpDeadline!.toIso8601String().split('T')[0];
    }

    final response = await apiConsumer.post(
      Endpoints.eventEditRequests(int.parse(eventId)),
      body: body,
    );
    return EditRequestModel.fromJson(response['data']);
  }

  @override
  Future<List<EditRequestModel>> getEditRequests(String eventId) async {
    final response = await apiConsumer.get(
      Endpoints.eventEditRequests(int.parse(eventId)),
    );
    final data = response['data'] as List? ?? [];
    return data.map((e) => EditRequestModel.fromJson(e)).toList();
  }

  String _formatDateTimeForApi(DateTime date) {
    return '${date.toIso8601String().split('T')[0]} ${_formatTimeForApi(date)}';
  }

  String _formatTimeForApi(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Future<Map<String, dynamic>> sendInvitations(String eventId, String method) async {
    final response = await apiConsumer.post(
      Endpoints.eventSendInvitations(int.parse(eventId)),
      body: {'delivery_method': method},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  @override
  Future<Map<String, dynamic>> addGuests(String eventId, List<Map<String, String>> guests) async {
    final response = await apiConsumer.post(
      Endpoints.eventGuestsAdd(int.parse(eventId)),
      body: {'guests': guests},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  @override
  Future<void> resendInvitation(String invitationId) async {
    await apiConsumer.post(Endpoints.invitationResend(int.parse(invitationId)));
  }

  @override
  Future<void> removeInvitation(String invitationId) async {
    await apiConsumer.delete(Endpoints.invitation(int.parse(invitationId)));
  }
}
