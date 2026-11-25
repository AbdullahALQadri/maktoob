import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/events/domain/entities/edit_request_entity.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/domain/repositories/events_repository.dart';
import 'package:maktoob/features/events/presentation/cubit/edit_event/edit_event_cubit.dart';
import 'package:maktoob/features/events/presentation/cubit/edit_event/edit_event_state.dart';

EventEntity _event(EventStatus status, {String? imageUrl}) => EventEntity(
      id: '7',
      name: 'أفراح آل القادري',
      type: 'wedding',
      date: '',
      time: '',
      venue: 'قاعة لاروزا',
      invitations: 0,
      responses: 0,
      attending: 0,
      status: status,
      imageUrl: imageUrl,
      details: const EventDetailsInfo(occasionAnswers: [
        OccasionAnswer(key: 'groom_name', labelAr: 'اسم العريس', labelEn: 'Groom', value: 'محمد'),
        OccasionAnswer(key: 'bride_name', labelAr: 'اسم العروس', labelEn: 'Bride', value: 'سارة'),
      ]),
    );

class _Repo extends Fake implements EventsRepository {
  UpdateEventParams? updated;
  UpdateEventParams? requested;

  @override
  Future<Either<Failure, EventEntity>> updateEvent(String eventId, UpdateEventParams params) async {
    updated = params;
    return Right(_event(EventStatus.pendingPayment));
  }

  @override
  Future<Either<Failure, EditRequestEntity>> submitEditRequest(String eventId, UpdateEventParams params) async {
    requested = params;
    return Left(ServerFailure(message: 'x'));
  }

  @override
  Future<Either<Failure, List<EditRequestEntity>>> getEditRequests(String eventId) async => const Right([]);
}

/// Same rule as the portal: unpaid is edited directly (names included),
/// active goes to the team as a request.
void main() {
  test('an unpaid event saves the names directly, every answer sent', () async {
    final repo = _Repo();
    final cubit = EditEventCubit(eventsRepository: repo)..initializeWithEvent(_event(EventStatus.pendingPayment));
    expect(cubit.state.editsDirectly, isTrue);

    cubit.updateAnswer('bride_name', ' سلمى ');
    expect(await cubit.saveChanges(), isTrue);

    expect(repo.requested, isNull);
    expect(repo.updated!.occasionAnswers, {'groom_name': 'محمد', 'bride_name': 'سلمى'});
    expect(cubit.state.status, EditEventStatus.saved);
    expect(cubit.state.redoDesign, isFalse, reason: 'No card yet.');
  });

  test('a card already drawn asks for the design again', () async {
    final cubit = EditEventCubit(eventsRepository: _Repo())
      ..initializeWithEvent(_event(EventStatus.pendingPayment, imageUrl: 'https://res.cloudinary.com/x/card.png'));
    cubit.updateAnswer('groom_name', 'أحمد');
    await cubit.saveChanges();
    expect(cubit.state.redoDesign, isTrue);
  });

  test('an active event sends a request and never the names', () async {
    final repo = _Repo();
    final cubit = EditEventCubit(eventsRepository: repo)..initializeWithEvent(_event(EventStatus.active));
    expect(cubit.state.editsDirectly, isFalse);

    cubit.updateAnswer('bride_name', 'سلمى');
    expect(cubit.state.hasChanges, isFalse, reason: 'Names are not part of a change request.');

    cubit.updateVenue('قاعة الأندلس');
    await cubit.saveChanges();
    expect(repo.updated, isNull);
    expect(repo.requested!.venue, 'قاعة الأندلس');
    expect(repo.requested!.occasionAnswers, isNull);
  });

  test('the rule matches the backend statuses', () {
    expect(_event(EventStatus.draft).detailsEditable, isTrue);
    expect(_event(EventStatus.pendingPayment).detailsEditable, isTrue);
    expect(_event(EventStatus.active).detailsEditable, isFalse);
    expect(_event(EventStatus.completed).detailsEditable, isFalse);
    expect(_event(EventStatus.cancelled).detailsEditable, isFalse);
  });
}
