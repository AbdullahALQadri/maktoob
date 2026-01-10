import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event_entity.dart';
import '../entities/guest_entity.dart';
import '../repositories/events_repository.dart';

class GetEventDetailsUseCase
    implements UseCase<EventDetailsResult, GetEventDetailsParams> {
  final EventsRepository repository;

  GetEventDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, EventDetailsResult>> call(
      GetEventDetailsParams params) async {
    final eventResult = await repository.getEventDetails(params.eventId);

    return eventResult.fold(
      (failure) => Left(failure),
      (event) async {
        final guestsResult = await repository.getEventGuests(params.eventId);
        return guestsResult.fold(
          (failure) => Left(failure),
          (guests) => Right(EventDetailsResult(event: event, guests: guests)),
        );
      },
    );
  }
}

class GetEventDetailsParams extends Equatable {
  final String eventId;

  const GetEventDetailsParams({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class EventDetailsResult extends Equatable {
  final EventEntity event;
  final List<GuestEntity> guests;

  const EventDetailsResult({
    required this.event,
    required this.guests,
  });

  @override
  List<Object?> get props => [event, guests];
}
