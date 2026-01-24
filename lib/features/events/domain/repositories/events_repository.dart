import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/event_entity.dart';
import '../entities/guest_entity.dart';

abstract class EventsRepository {
  /// Get all events
  Future<Either<Failure, List<EventEntity>>> getEvents();

  /// Get event details by id
  Future<Either<Failure, EventEntity>> getEventDetails(String eventId);

  /// Get guests for an event
  Future<Either<Failure, List<GuestEntity>>> getEventGuests(String eventId);

  /// Create a new event
  Future<Either<Failure, EventEntity>> createEvent(CreateEventParams params);

  /// Update an existing event
  Future<Either<Failure, EventEntity>> updateEvent(
      String eventId, UpdateEventParams params);

  /// Delete an event
  Future<Either<Failure, void>> deleteEvent(String eventId);

  /// Filter events by status and search query
  Future<Either<Failure, List<EventEntity>>> filterEvents({
    String? searchQuery,
    EventStatus? status,
  });

  /// Cache events locally
  Future<Either<Failure, void>> cacheEvents(List<EventEntity> events);

  /// Get cached events
  Future<Either<Failure, List<EventEntity>>> getCachedEvents();
}

class CreateEventParams {
  final String name;
  final String type;
  final int? eventTypeId;
  final DateTime eventDate;
  final String venue;
  final int? venueId;
  final String? venueAddress;
  final String? description;
  final int? packageId;
  final int? templateId;
  final int maxCompanions;
  final bool allowCompanions;
  final DateTime? rsvpDeadline;
  final List<GuestEntity>? guests;

  const CreateEventParams({
    required this.name,
    required this.type,
    this.eventTypeId,
    required this.eventDate,
    required this.venue,
    this.venueId,
    this.venueAddress,
    this.description,
    this.packageId,
    this.templateId,
    this.maxCompanions = 2,
    this.allowCompanions = true,
    this.rsvpDeadline,
    this.guests,
  });
}

class UpdateEventParams {
  final String? name;
  final String? type;
  final DateTime? eventDate;
  final String? venue;
  final int? venueId;
  final String? venueAddress;
  final String? description;
  final EventStatus? status;
  final int? maxCompanions;
  final bool? allowCompanions;
  final DateTime? rsvpDeadline;

  const UpdateEventParams({
    this.name,
    this.type,
    this.eventDate,
    this.venue,
    this.venueId,
    this.venueAddress,
    this.description,
    this.status,
    this.maxCompanions,
    this.allowCompanions,
    this.rsvpDeadline,
  });
}
