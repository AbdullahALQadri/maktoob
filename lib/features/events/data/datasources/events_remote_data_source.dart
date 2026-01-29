import 'package:flutter/material.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/api/event_wizard_api_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/guest_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../../domain/entities/edit_request_entity.dart';
import '../models/edit_request_model.dart';
import '../models/event_model.dart';
import '../models/guest_model.dart';

abstract class EventsRemoteDataSource {
  /// Fetches all events from the remote server
  Future<List<EventModel>> getEvents();

  /// Fetches event details by id
  Future<EventModel> getEventDetails(String eventId);

  /// Fetches guests for an event
  Future<List<GuestModel>> getEventGuests(String eventId);

  /// Creates a new event
  Future<EventModel> createEvent(CreateEventParams params);

  /// Updates an event
  Future<EventModel> updateEvent(String eventId, UpdateEventParams params);

  /// Deletes an event
  Future<void> deleteEvent(String eventId);

  /// Filters events by status and search query
  Future<List<EventModel>> filterEvents({
    String? searchQuery,
    EventStatus? status,
  });

  /// Submits an edit request for an active event
  Future<EditRequestModel> submitEditRequest(
      String eventId, UpdateEventParams params);

  /// Gets edit requests for an event
  Future<List<EditRequestModel>> getEditRequests(String eventId);
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final ApiConsumer? apiConsumer;
  final EventWizardApiService? wizardApiService;

  EventsRemoteDataSourceImpl({
    this.apiConsumer,
    this.wizardApiService,
  });

  /// Check if API is available
  bool get _hasApi => apiConsumer != null;

  // Mock events data
  final List<EventModel> _mockEvents = [
    EventModel(
      id: '1',
      name: 'Annual Gala 2024',
      type: 'Corporate',
      date: 'Dec 15, 2024',
      time: '7:00 PM',
      venue: 'Grand Hotel Ballroom',
      venueAddress: '123 Luxury Ave, Downtown City',
      description: 'Join us for an elegant evening celebrating our company achievements.',
      invitations: 250,
      responses: 180,
      attending: 145,
      declined: 23,
      pending: 38,
      checkedIn: 45,
      status: EventStatus.active,
      eventDate: DateTime(2024, 12, 15, 19, 0),
      rsvpDeadline: DateTime(2024, 12, 10),
      packageName: 'Gold Package',
      packagePrice: '\$599',
      templateName: 'Elegant Gold',
      maxCompanions: 2,
      allowCompanions: true,
      gradient: [AppColors.purple500, AppColors.pink500],
      icon: Icons.celebration,
    ),
    EventModel(
      id: '2',
      name: 'Sarah & John Wedding',
      type: 'Wedding',
      date: 'Jan 20, 2025',
      time: '4:00 PM',
      venue: 'Beach Resort',
      invitations: 150,
      responses: 120,
      attending: 98,
      declined: 12,
      pending: 10,
      checkedIn: 0,
      status: EventStatus.active,
      eventDate: DateTime(2025, 1, 20, 16, 0),
      gradient: [AppColors.pink500, AppColors.rose500],
      icon: Icons.favorite,
    ),
    EventModel(
      id: '3',
      name: 'Tech Conference 2024',
      type: 'Conference',
      date: 'Nov 30, 2024',
      time: '9:00 AM',
      venue: 'Convention Center',
      invitations: 500,
      responses: 450,
      attending: 420,
      declined: 30,
      pending: 0,
      checkedIn: 420,
      status: EventStatus.completed,
      eventDate: DateTime(2024, 11, 30, 9, 0),
      gradient: [AppColors.blue500, AppColors.cyan500],
      icon: Icons.computer,
    ),
    EventModel(
      id: '4',
      name: 'Birthday Bash',
      type: 'Birthday',
      date: 'Feb 14, 2025',
      time: '6:00 PM',
      venue: 'Private Villa',
      invitations: 50,
      responses: 0,
      attending: 0,
      declined: 0,
      pending: 50,
      checkedIn: 0,
      status: EventStatus.draft,
      eventDate: DateTime(2025, 2, 14, 18, 0),
      gradient: [AppColors.amber500, AppColors.orange500],
      icon: Icons.cake,
    ),
    EventModel(
      id: '5',
      name: 'Charity Fundraiser',
      type: 'Charity',
      date: 'Mar 10, 2025',
      time: '5:00 PM',
      venue: 'Community Hall',
      invitations: 200,
      responses: 85,
      attending: 70,
      declined: 15,
      pending: 100,
      checkedIn: 0,
      status: EventStatus.active,
      eventDate: DateTime(2025, 3, 10, 17, 0),
      gradient: [AppColors.emerald500, AppColors.green600],
      icon: Icons.volunteer_activism,
    ),
    EventModel(
      id: '6',
      name: 'Graduation Ceremony',
      type: 'Graduation',
      date: 'Dec 1, 2024',
      time: '10:00 AM',
      venue: 'University Hall',
      invitations: 300,
      responses: 280,
      attending: 275,
      declined: 5,
      pending: 0,
      checkedIn: 275,
      status: EventStatus.completed,
      eventDate: DateTime(2024, 12, 1, 10, 0),
      gradient: [AppColors.indigo500, AppColors.purple500],
      icon: Icons.school,
    ),
  ];

  final List<GuestModel> _mockGuests = [
    GuestModel(
      id: '1',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@email.com',
      phone: '+1 234 567 8901',
      status: GuestStatus.attending,
      companions: 1,
      isCheckedIn: true,
      avatarColor: AppColors.purple500,
    ),
    GuestModel(
      id: '2',
      name: 'Michael Chen',
      email: 'michael.chen@email.com',
      phone: '+1 234 567 8902',
      status: GuestStatus.attending,
      companions: 2,
      isCheckedIn: true,
      avatarColor: AppColors.blue500,
    ),
    GuestModel(
      id: '3',
      name: 'Emily Rodriguez',
      email: 'emily.rodriguez@email.com',
      phone: '+1 234 567 8903',
      status: GuestStatus.pending,
      companions: 0,
      isCheckedIn: false,
      avatarColor: AppColors.emerald500,
    ),
    GuestModel(
      id: '4',
      name: 'David Kim',
      email: 'david.kim@email.com',
      phone: '+1 234 567 8904',
      status: GuestStatus.declined,
      companions: 0,
      isCheckedIn: false,
      avatarColor: AppColors.amber500,
    ),
    GuestModel(
      id: '5',
      name: 'Jessica Williams',
      email: 'jessica.williams@email.com',
      phone: '+1 234 567 8905',
      status: GuestStatus.attending,
      companions: 1,
      isCheckedIn: false,
      avatarColor: AppColors.pink500,
    ),
    GuestModel(
      id: '6',
      name: 'Robert Taylor',
      email: 'robert.taylor@email.com',
      phone: '+1 234 567 8906',
      status: GuestStatus.attending,
      companions: 0,
      isCheckedIn: true,
      avatarColor: AppColors.cyan500,
    ),
    GuestModel(
      id: '7',
      name: 'Amanda Martinez',
      email: 'amanda.martinez@email.com',
      phone: '+1 234 567 8907',
      status: GuestStatus.pending,
      companions: 2,
      isCheckedIn: false,
      avatarColor: AppColors.indigo500,
    ),
    GuestModel(
      id: '8',
      name: 'Christopher Brown',
      email: 'christopher.brown@email.com',
      phone: '+1 234 567 8908',
      status: GuestStatus.attending,
      companions: 1,
      isCheckedIn: true,
      avatarColor: AppColors.orange500,
    ),
  ];

  @override
  Future<List<EventModel>> getEvents() async {
    if (_hasApi) {
      try {
        final response = await apiConsumer!.get(Endpoints.events);
        final eventsData = response['data'] as List? ?? [];
        return eventsData.map((e) => EventModel.fromJson(e)).toList();
      } catch (e) {
        // Fall back to mock on error
        return _mockEvents;
      }
    }
    // Simulate network delay for mock data
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockEvents;
  }

  @override
  Future<EventModel> getEventDetails(String eventId) async {
    if (_hasApi) {
      try {
        final response = await apiConsumer!.get(Endpoints.event(int.parse(eventId)));
        return EventModel.fromJson(response['data']);
      } catch (e) {
        // Fall back to mock on error
        final event = _mockEvents.firstWhere(
          (e) => e.id == eventId,
          orElse: () => throw Exception('Event not found'),
        );
        return event;
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
    final event = _mockEvents.firstWhere(
      (e) => e.id == eventId,
      orElse: () => throw Exception('Event not found'),
    );
    return event;
  }

  @override
  Future<List<GuestModel>> getEventGuests(String eventId) async {
    if (_hasApi) {
      try {
        final response = await apiConsumer!.get(Endpoints.eventInvitations(int.parse(eventId)));
        final guestsData = response['data'] as List? ?? [];
        return guestsData.map((g) => GuestModel.fromJson(g)).toList();
      } catch (e) {
        // Fall back to mock on error
        return _mockGuests;
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockGuests;
  }

  @override
  Future<EventModel> createEvent(CreateEventParams params) async {
    if (wizardApiService != null) {
      try {
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
            params.guests!.map((g) => {'name': g.name, 'phone': g.phone}).toList(),
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
          await wizardApiService!.selectPackage(eventId, packageId: params.packageId);
        }

        // Step 6: Save as draft or submit
        final saveResponse = await wizardApiService!.saveEvent(eventId, isDraft: true);

        return EventModel.fromJson(saveResponse['data']['event'] ?? saveResponse['data']);
      } catch (e) {
        // Fall back to mock on error
        return _createMockEvent(params);
      }
    }

    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return _createMockEvent(params);
  }

  EventModel _createMockEvent(CreateEventParams params) {
    return EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: params.name,
      type: params.type,
      date: _formatDate(params.eventDate),
      time: _formatTime(params.eventDate),
      venue: params.venue,
      venueAddress: params.venueAddress,
      description: params.description,
      invitations: params.guests?.length ?? 0,
      responses: 0,
      attending: 0,
      declined: 0,
      pending: params.guests?.length ?? 0,
      checkedIn: 0,
      status: EventStatus.draft,
      eventDate: params.eventDate,
      rsvpDeadline: params.rsvpDeadline,
      maxCompanions: params.maxCompanions,
      allowCompanions: params.allowCompanions,
      gradient: [AppColors.purple500, AppColors.pink500],
      icon: Icons.event,
    );
  }

  @override
  Future<EventModel> updateEvent(String eventId, UpdateEventParams params) async {
    if (_hasApi) {
      try {
        final response = await apiConsumer!.put(
          Endpoints.event(int.parse(eventId)),
          body: {
            if (params.name != null) 'title_ar': params.name,
            if (params.venue != null) 'venue_id': params.venueId,
            if (params.venueAddress != null) 'custom_venue_address_ar': params.venueAddress,
            if (params.description != null) 'description_ar': params.description,
            if (params.eventDate != null) 'event_date': params.eventDate!.toIso8601String().split('T')[0],
            if (params.status != null) 'status': params.status!.name,
            if (params.maxCompanions != null) 'max_companions': params.maxCompanions,
            if (params.allowCompanions != null) 'allow_companions': params.allowCompanions,
          },
        );
        return EventModel.fromJson(response['data']);
      } catch (e) {
        // Fall back to mock on error
      }
    }

    await Future.delayed(const Duration(milliseconds: 100));

    final index = _mockEvents.indexWhere((e) => e.id == eventId);
    if (index == -1) {
      throw Exception('Event not found');
    }

    final existingEvent = _mockEvents[index];
    final updatedEvent = existingEvent.copyWith(
      name: params.name ?? existingEvent.name,
      type: params.type ?? existingEvent.type,
      venue: params.venue ?? existingEvent.venue,
      venueAddress: params.venueAddress ?? existingEvent.venueAddress,
      description: params.description ?? existingEvent.description,
      status: params.status ?? existingEvent.status,
      eventDate: params.eventDate ?? existingEvent.eventDate,
      rsvpDeadline: params.rsvpDeadline ?? existingEvent.rsvpDeadline,
      maxCompanions: params.maxCompanions ?? existingEvent.maxCompanions,
      allowCompanions: params.allowCompanions ?? existingEvent.allowCompanions,
    );

    return updatedEvent;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    if (_hasApi) {
      try {
        await apiConsumer!.delete(Endpoints.event(int.parse(eventId)));
        return;
      } catch (e) {
        // Fall back to mock behavior
      }
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<EventModel>> filterEvents({
    String? searchQuery,
    EventStatus? status,
  }) async {
    if (_hasApi) {
      try {
        final queryParams = <String, dynamic>{};
        if (searchQuery != null && searchQuery.isNotEmpty) {
          queryParams['search'] = searchQuery;
        }
        if (status != null) {
          queryParams['status'] = status.name;
        }
        final response = await apiConsumer!.get(Endpoints.events, queryParameters: queryParams);
        final eventsData = response['data'] as List? ?? [];
        return eventsData.map((e) => EventModel.fromJson(e)).toList();
      } catch (e) {
        // Fall back to mock on error
      }
    }

    await Future.delayed(const Duration(milliseconds: 100));

    return _mockEvents.where((event) {
      final matchesSearch = searchQuery == null ||
          searchQuery.isEmpty ||
          event.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.type.toLowerCase().contains(searchQuery.toLowerCase()) ||
          event.venue.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = status == null || event.status == status;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String? _formatTimeForApi(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  // Mock edit requests storage
  final List<EditRequestModel> _mockEditRequests = [
    EditRequestModel(
      id: '101',
      eventId: '1',
      changes: {'name': 'Annual Gala 2025', 'venue': 'Royal Palace'},
      status: EditRequestStatus.approved,
      createdAt: DateTime(2024, 12, 1),
      adminNote: 'Approved - venue confirmed',
    ),
    EditRequestModel(
      id: '102',
      eventId: '1',
      changes: {'description': 'Updated description for the gala event'},
      status: EditRequestStatus.rejected,
      createdAt: DateTime(2024, 12, 5),
      adminNote: 'Description too vague, please provide more details',
    ),
    EditRequestModel(
      id: '103',
      eventId: '2',
      changes: {'venue': 'Mountain Resort', 'venueAddress': '456 Mountain Rd'},
      status: EditRequestStatus.pending,
      createdAt: DateTime(2025, 1, 10),
    ),
  ];

  @override
  Future<EditRequestModel> submitEditRequest(
      String eventId, UpdateEventParams params) async {
    if (_hasApi) {
      try {
        final body = <String, dynamic>{};
        if (params.name != null) body['name'] = params.name;
        if (params.venue != null) body['venue'] = params.venue;
        if (params.venueAddress != null) body['venue_address'] = params.venueAddress;
        if (params.description != null) body['description'] = params.description;
        if (params.eventDate != null) {
          body['event_date'] = params.eventDate!.toIso8601String().split('T')[0];
        }
        if (params.maxCompanions != null) body['max_companions'] = params.maxCompanions;
        if (params.allowCompanions != null) body['allow_companions'] = params.allowCompanions;
        if (params.rsvpDeadline != null) {
          body['rsvp_deadline'] = params.rsvpDeadline!.toIso8601String().split('T')[0];
        }

        final response = await apiConsumer!.post(
          Endpoints.eventEditRequests(int.parse(eventId)),
          body: body,
        );
        return EditRequestModel.fromJson(response['data']);
      } catch (e) {
        // Fall back to mock
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));

    final changes = <String, dynamic>{};
    if (params.name != null) changes['name'] = params.name;
    if (params.venue != null) changes['venue'] = params.venue;
    if (params.venueAddress != null) changes['venueAddress'] = params.venueAddress;
    if (params.description != null) changes['description'] = params.description;
    if (params.eventDate != null) changes['eventDate'] = params.eventDate!.toIso8601String();
    if (params.maxCompanions != null) changes['maxCompanions'] = params.maxCompanions;
    if (params.allowCompanions != null) changes['allowCompanions'] = params.allowCompanions;
    if (params.rsvpDeadline != null) changes['rsvpDeadline'] = params.rsvpDeadline!.toIso8601String();

    final newRequest = EditRequestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: eventId,
      changes: changes,
      status: EditRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    _mockEditRequests.add(newRequest);
    return newRequest;
  }

  @override
  Future<List<EditRequestModel>> getEditRequests(String eventId) async {
    if (_hasApi) {
      try {
        final response = await apiConsumer!.get(
          Endpoints.eventEditRequests(int.parse(eventId)),
        );
        final data = response['data'] as List? ?? [];
        return data.map((e) => EditRequestModel.fromJson(e)).toList();
      } catch (e) {
        // Fall back to mock
      }
    }

    await Future.delayed(const Duration(milliseconds: 100));
    return _mockEditRequests.where((r) => r.eventId == eventId).toList();
  }
}
