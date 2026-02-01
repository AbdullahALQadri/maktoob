import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/api/event_wizard_api_service.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../models/edit_request_model.dart';
import '../models/event_model.dart';
import '../models/guest_model.dart';

abstract class EventsRemoteDataSource {
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
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final ApiConsumer apiConsumer;
  final EventWizardApiService? wizardApiService;

  EventsRemoteDataSourceImpl({
    required this.apiConsumer,
    this.wizardApiService,
  });

  @override
  Future<List<EventModel>> getEvents() async {
    final response = await apiConsumer.get(Endpoints.events);
    final eventsData = response['data'] as List? ?? [];
    return eventsData.map((e) => EventModel.fromJson(e)).toList();
  }

  @override
  Future<EventModel> getEventDetails(String eventId) async {
    final response =
        await apiConsumer.get(Endpoints.event(int.parse(eventId)));
    return EventModel.fromJson(response['data']);
  }

  @override
  Future<List<GuestModel>> getEventGuests(String eventId) async {
    final response = await apiConsumer
        .get(Endpoints.eventInvitations(int.parse(eventId)));
    final guestsData = response['data'] as List? ?? [];
    return guestsData.map((g) => GuestModel.fromJson(g)).toList();
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
        if (params.name != null) 'title_ar': params.name,
        if (params.venueId != null) 'venue_id': params.venueId,
        if (params.venueAddress != null)
          'custom_venue_address_ar': params.venueAddress,
        if (params.description != null)
          'description_ar': params.description,
        if (params.eventDate != null)
          'event_date':
              params.eventDate!.toIso8601String().split('T')[0],
        if (params.status != null) 'status': params.status!.name,
        if (params.maxCompanions != null)
          'max_companions': params.maxCompanions,
        if (params.allowCompanions != null)
          'allow_companions': params.allowCompanions,
      },
    );
    return EventModel.fromJson(response['data']);
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
      queryParams['status'] = status.name;
    }
    final response =
        await apiConsumer.get(Endpoints.events, queryParameters: queryParams);
    final eventsData = response['data'] as List? ?? [];
    return eventsData.map((e) => EventModel.fromJson(e)).toList();
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
      body['event_date'] =
          params.eventDate!.toIso8601String().split('T')[0];
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

  String _formatTimeForApi(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
