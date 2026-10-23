import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/domain/entities/guest_entity.dart';
import 'package:maktoob/features/events/domain/repositories/events_repository.dart';
import 'package:maktoob/features/events/domain/usecases/get_event_details_usecase.dart';
import 'package:maktoob/features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'package:maktoob/features/events/presentation/widgets/guest_invitation_sheet.dart';

const _event = EventEntity(
  id: '7',
  name: 'Wedding',
  type: 'wedding',
  date: '',
  time: '',
  venue: '',
  invitations: 2,
  responses: 0,
  attending: 0,
  status: EventStatus.active,
);

GuestEntity _guest(String id, String? invitationStatus) => GuestEntity(
      id: id,
      name: 'G$id',
      email: '',
      phone: '0599',
      status: GuestStatus.pending,
      companions: 0,
      isCheckedIn: false,
      invitationStatus: invitationStatus,
    );

class _FakeRepo extends Fake implements EventsRepository {
  final calls = <String>[];
  Map<String, dynamic> addResult = {'created': 1, 'sent': 0};
  EventStatus status = EventStatus.active;

  @override
  Future<Either<Failure, EventEntity>> getEventDetails(String eventId) async => Right(
        EventEntity(
          id: _event.id,
          name: _event.name,
          type: _event.type,
          date: '',
          time: '',
          venue: '',
          invitations: 2,
          responses: 0,
          attending: 0,
          status: status,
        ),
      );

  @override
  Future<Either<Failure, List<GuestEntity>>> getEventGuests(String eventId) async =>
      Right([_guest('1', 'pending'), _guest('2', 'sent')]);

  @override
  Future<bool> hasPendingPaymentRequest(String eventId) async => false;

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendInvitations(String eventId, String method) async {
    calls.add('send:$eventId:$method');
    return const Right({'dispatched': 1});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addGuests(
      String eventId, List<Map<String, String>> guests) async {
    calls.add('add:${guests.length}');
    return Right(addResult);
  }

  @override
  Future<Either<Failure, EventEntity>> updateEvent(String eventId, UpdateEventParams params) async {
    calls.add('update:${params.status?.apiValue}');
    status = params.status ?? status;
    return getEventDetails(eventId);
  }
}

void main() {
  late _FakeRepo repo;
  late EventDetailsCubit cubit;

  setUp(() async {
    repo = _FakeRepo();
    cubit = EventDetailsCubit(
      getEventDetailsUseCase: GetEventDetailsUseCase(repo),
      eventsRepository: repo,
    );
    await cubit.loadEventDetails('7');
  });

  tearDown(() => cubit.close());

  test('counts only invitations that have not gone out', () {
    expect(cubit.state.unsentCount, 1);
  });

  test('send invitations calls the API and shows a notice', () async {
    final ok = await cubit.sendInvitations('whatsapp');
    expect(ok, isTrue);
    expect(repo.calls, ['send:7:whatsapp']);
    expect(cubit.state.notice, 'event_invitations_sent');
    expect(cubit.state.noticeCount, 1);
    expect(cubit.state.isBusy, isFalse);
  });

  test('adding a guest after the first send says it was sent', () async {
    repo.addResult = {'created': 1, 'sent': 1};
    await cubit.addGuests([
      {'name': 'A', 'phone': '0599123456'},
    ]);
    expect(cubit.state.notice, 'event_guests_added_sent');
  });

  test('an invalid phone surfaces a translated error key', () async {
    repo.addResult = {'created': 0, 'sent': 0, 'invalid_phones': ['12']};
    await cubit.addGuests([
      {'name': 'A', 'phone': '12'},
    ]);
    expect(cubit.state.errorMessage, 'event_guests_invalid_phone');
  });

  test('cancel sends status cancelled and reloads', () async {
    await cubit.cancelEvent();
    expect(repo.calls, ['update:cancelled']);
    expect(cubit.state.event!.status, EventStatus.cancelled);
    expect(cubit.state.event!.canManageGuests, isFalse);
  });

  test('resend is offered only for invitations that already went out', () {
    expect(GuestInvitationSheet.canResend(_guest('1', 'pending')), isFalse);
    expect(GuestInvitationSheet.canResend(_guest('2', 'sent')), isTrue);
    expect(GuestInvitationSheet.canResend(_guest('3', 'responded')), isFalse);
  });
}
