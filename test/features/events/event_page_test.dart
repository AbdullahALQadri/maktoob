import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/events/domain/entities/event_card.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/domain/entities/event_follow_up.dart';
import 'package:maktoob/features/events/domain/entities/guest_entity.dart';
import 'package:maktoob/features/events/domain/repositories/event_add_ons_repository.dart';
import 'package:maktoob/features/events/domain/repositories/event_follow_up_repository.dart';
import 'package:maktoob/features/events/domain/repositories/events_repository.dart';
import 'package:maktoob/features/events/domain/usecases/event_follow_up_usecases.dart';
import 'package:maktoob/features/events/domain/usecases/get_event_add_ons_usecase.dart';
import 'package:maktoob/features/events/domain/usecases/request_event_add_on_usecase.dart';
import 'package:maktoob/features/events/domain/usecases/withdraw_event_add_on_usecase.dart';
import 'package:maktoob/features/events/domain/usecases/get_event_details_usecase.dart';
import 'package:maktoob/features/events/presentation/cubit/event_add_ons/event_add_ons_cubit.dart';
import 'package:maktoob/features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'package:maktoob/features/events/presentation/cubit/event_follow_up/event_follow_up_cubit.dart';
import 'package:maktoob/features/events/presentation/screens/event_details_screen.dart';
import 'package:maktoob/injection_container.dart' as di;

GuestEntity guest(String id, GuestStatus status, {String invitation = 'sent'}) => GuestEntity(
  id: id,
  name: 'ضيف رقم $id باسم طويل جداً للتجربة',
  email: '',
  phone: '+970599000$id',
  status: status,
  companions: status == GuestStatus.attending ? 2 : 0,
  isCheckedIn: false,
  invitationStatus: invitation,
);

class _Events extends Fake implements EventsRepository {
  _Events(this.status, this.date);

  final EventStatus status;
  final DateTime date;

  @override
  Future<Either<Failure, EventEntity>> getEventDetails(String eventId) async => Right(
    EventEntity(
      id: '7',
      name: 'حفل زفاف أحمد وليلى في قاعة الروضة الكبرى',
      type: 'wedding',
      date: '',
      time: '',
      venue: 'قاعة الروضة',
      venueAddress: 'غزة',
      invitations: 240,
      responses: 182,
      attending: 150,
      declined: 32,
      status: status,
      eventDate: date,
      invitationLimit: 300,
    ),
  );

  @override
  Future<Either<Failure, List<GuestEntity>>> getEventGuests(String eventId) async => Right([
    guest('1', GuestStatus.attending),
    guest('2', GuestStatus.declined),
    guest('3', GuestStatus.pending, invitation: 'failed'),
    guest('4', GuestStatus.pending, invitation: 'pending'),
  ]);

  @override
  Future<bool> hasPendingPaymentRequest(String eventId) async => false;
}

/// Extra services are not under test here: the card simply stays empty.
class _AddOns extends Fake implements EventAddOnsRepository {
  @override
  Future<Either<Failure, Never>> getAddOns(int eventId) async => const Left(NetworkFailure(message: 'offline'));
}

class _FollowUp extends Fake implements EventFollowUpRepository {
  @override
  Future<Either<Failure, List<ActivityItem>>> activity(String eventId) async =>
      const Right([ActivityItem(invitationId: 1, replied: true, reply: 'attending', name: 'ليلى', companions: 2)]);

  @override
  Future<Either<Failure, EventProgress>> progress(String eventId) async => const Right(
    EventProgress(
      inSetup: true,
      nextAction: NextAction.chooseDesign,
      steps: [
        SetupStep(key: 'details', done: true, current: false),
        SetupStep(key: 'guests', done: true, current: false),
        SetupStep(key: 'design', done: false, current: true),
        SetupStep(key: 'settings', done: false, current: false),
        SetupStep(key: 'checkout', done: false, current: false),
        SetupStep(key: 'send', done: false, current: false),
      ],
    ),
  );
}

Future<void> pumpPage(
  WidgetTester tester, {
  required Size size,
  double text = 1,
  Locale locale = const Locale('ar'),
  EventStatus status = EventStatus.active,
  DateTime? date,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = text;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final events = _Events(status, date ?? DateTime.now().add(const Duration(days: 14)));
  final followUp = _FollowUp();
  await di.sl.reset();
  final addOns = _AddOns();
  di.sl.registerFactory(
    () => EventAddOnsCubit(
      getAddOns: GetEventAddOnsUseCase(addOns),
      requestAddOn: RequestEventAddOnUseCase(addOns),
      withdrawAddOn: WithdrawEventAddOnUseCase(addOns),
    ),
  );
  di.sl.registerFactory(
    () => EventFollowUpCubit(
      getFollowUp: GetEventFollowUpUseCase(followUp),
      resendFailedInvitations: ResendFailedInvitationsUseCase(followUp),
      updateUnsentGuest: UpdateUnsentGuestUseCase(followUp),
    ),
  );
  await tester.runAsync(() async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) =>
            EventDetailsCubit(getEventDetailsUseCase: GetEventDetailsUseCase(events), eventsRepository: events),
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: EventDetailsScreen(eventId: '7', onBack: () {}),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => di.sl.reset());

  const sizes = <(String, Size, double)>[
    ('small phone, large text', Size(320, 568), 1.3),
    ('phone, very large text', Size(390, 844), 2.0),
    ('tablet', Size(768, 1024), 1.0),
    ('desktop', Size(1280, 800), 1.0),
  ];
  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final (name, size, text) in sizes) {
      testWidgets('${locale.languageCode}: a live event lays out on a $name', (tester) async {
        await pumpPage(tester, size: size, text: text, locale: locale);
        expect(tester.takeException(), isNull);
        expect(find.byType(TabBar), findsOneWidget);
      });
    }
  }

  testWidgets('a draft shows what is left and the next step', (tester) async {
    await pumpPage(tester, size: const Size(390, 844), status: EventStatus.draft);
    expect(find.text('ما تبقّى قبل الإرسال'), findsOneWidget);
    expect(find.text('اختر التصميم'), findsWidgets);
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('on the event day the page opens on the door', (tester) async {
    await pumpPage(tester, size: const Size(390, 844), date: DateTime.now());
    expect(find.text('فتح البوابة'), findsOneWidget);
  });

  testWidgets('the guest list can show only the invitations that did not arrive', (tester) async {
    await pumpPage(tester, size: const Size(390, 844));
    await tester.tap(find.byType(Tab).at(1)); // Overview · Guests · Door · Details
    await tester.pumpAndSettle();
    final notDelivered = find.byWidgetPredicate(
      (w) => w is ChoiceChip && ((w.label as Text).data ?? '').startsWith('لم تصل'),
    );
    final chipRow = find.ancestor(of: find.byType(ChoiceChip).first, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(notDelivered, 120, scrollable: chipRow);
    await tester.pumpAndSettle();
    await tester.tap(notDelivered);
    await tester.pumpAndSettle();
    expect(find.textContaining('ضيف رقم 3'), findsOneWidget);
    expect(find.textContaining('ضيف رقم 1'), findsNothing);
  });
}
