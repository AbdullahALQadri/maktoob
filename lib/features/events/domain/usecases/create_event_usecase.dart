import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event_entity.dart';
import '../entities/guest_entity.dart';
import '../repositories/events_repository.dart';

class CreateEventUseCase implements UseCase<EventEntity, CreateEventUseCaseParams> {
  final EventsRepository repository;

  CreateEventUseCase(this.repository);

  @override
  Future<Either<Failure, EventEntity>> call(CreateEventUseCaseParams params) async {
    // Validate required fields
    if (params.name.isEmpty) {
      return const Left(ValidationFailure(message: 'Event name is required'));
    }

    if (params.type.isEmpty) {
      return const Left(ValidationFailure(message: 'Event type is required'));
    }

    if (params.venue.isEmpty) {
      return const Left(ValidationFailure(message: 'Venue is required'));
    }

    if (params.packageId == null) {
      return const Left(ValidationFailure(message: 'Package selection is required'));
    }

    final createParams = CreateEventParams(
      name: params.name,
      type: params.type,
      eventTypeId: params.eventTypeId,
      eventDate: params.eventDate,
      venue: params.venue,
      venueId: params.venueId,
      venueAddress: params.venueAddress,
      description: params.description,
      packageId: params.packageId,
      templateId: params.templateId,
      maxCompanions: params.maxCompanions,
      allowCompanions: params.allowCompanions,
      rsvpDeadline: params.rsvpDeadline,
      guests: params.guests,
    );

    return await repository.createEvent(createParams);
  }
}

class CreateEventUseCaseParams extends Equatable {
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

  const CreateEventUseCaseParams({
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

  @override
  List<Object?> get props => [
        name,
        type,
        eventTypeId,
        eventDate,
        venue,
        venueId,
        venueAddress,
        description,
        packageId,
        templateId,
        maxCompanions,
        allowCompanions,
        rsvpDeadline,
        guests,
      ];
}
