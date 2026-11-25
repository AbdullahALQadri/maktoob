import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/staff/data/models/staff_models.dart';
import 'package:maktoob/features/staff/domain/entities/staff_entities.dart';
import 'package:maktoob/features/staff/domain/repositories/staff_repository.dart';
import 'package:maktoob/features/staff/domain/usecases/staff_usecases.dart';
import 'package:maktoob/features/staff/presentation/cubit/staff_load_cubit.dart';
import 'package:maktoob/features/staff/presentation/cubit/staff_request_cubit.dart';
import 'package:maktoob/features/staff/presentation/cubit/staff_session_cubit.dart';
import 'package:maktoob/features/staff/presentation/screens/staff_login_screen.dart';
import 'package:maktoob/features/staff/presentation/screens/staff_request_screen.dart';
import 'package:maktoob/features/staff/presentation/widgets/staff_clients_view.dart';
import 'package:maktoob/features/staff/presentation/widgets/staff_events_view.dart';
import 'package:maktoob/features/staff/presentation/widgets/staff_requests_view.dart';
import 'package:maktoob/features/staff/presentation/widgets/staff_today_view.dart';

const _request = StaffPaymentRequest(
  id: 5,
  amount: 400,
  status: 'pending',
  clientName: 'جمعية النور الخيرية للتنمية المجتمعية',
  clientPhone: '+970599123456',
  eventTitle: 'المؤتمر السنوي الثالث للعمل الأهلي في قطاع غزة',
  method: 'bank_transfer',
  originalCurrency: 'USD',
  originalAmount: 117,
  clientNotes: 'حوّلنا من حساب المكتب الرئيسي',
);

class _Repo implements StaffRepository {
  final decisions = <String>[];
  bool signedIn = false;
  bool refuse = false;

  @override
  StaffResult<StaffUser> signIn(String email, String password) async {
    if (password != 'secret') return const Left(AuthenticationFailure(message: 'Invalid credentials.'));
    signedIn = true;
    return const Right(StaffUser(name: 'منى', email: 'mona@maktoob.test'));
  }

  @override
  StaffResult<StaffUser?> restore() async => Right(signedIn ? const StaffUser(name: 'منى') : null);

  @override
  Future<void> signOut() async => signedIn = false;

  @override
  StaffResult<StaffToday> today() async => const Right(StaffToday(paymentRequestsPending: 3, eventsToday: 0));

  @override
  StaffResult<List<StaffPaymentRequest>> paymentRequests({String status = 'pending'}) async => const Right([_request]);

  @override
  StaffResult<StaffPaymentRequest> paymentRequest(int id) async => const Right(_request);

  @override
  StaffResult<Unit> approve(int id, {String? notes}) async {
    if (refuse) return const Left(ValidationFailure(message: 'This event has already been paid for.'));
    decisions.add('approve $id');
    return const Right(unit);
  }

  @override
  StaffResult<Unit> reject(int id, String reason) async {
    decisions.add('reject $id: $reason');
    return const Right(unit);
  }

  @override
  StaffResult<List<StaffClientRow>> clients({String search = ''}) async => Right([
        if ('عبد الرحمن'.contains(search) || search.isEmpty)
          const StaffClientRow(id: 1, name: 'عبد الرحمن محمد أبو شمالة', phone: '+970599000111', eventsCount: 4),
      ]);

  @override
  StaffResult<List<StaffEventRow>> events({String search = ''}) async => Right([
        StaffEventRow(id: 9, title: 'زفاف أحمد وليلى', status: 'active', date: DateTime(2026, 12, 4, 19), clientName: 'أحمد'),
      ]);
}

Widget _app(Widget home, Locale locale) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      home: home,
    );

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('phone, very large text', Size(390, 844), 2.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  test('reads the admin answers: text decimals, a queue the member may not see', () {
    final today = StaffModels.today({'payment_requests_pending': 2, 'identities_pending': null});
    expect(today.paymentRequestsPending, 2);
    expect(today.identitiesPending, isNull);

    final request = StaffModels.paymentRequest({
      'id': 5,
      'amount': '400.00',
      'status': 'pending',
      'kind': 'upgrade',
      'target_invitations': 2000,
      'payment_method': 'wallet',
      'client': {'name': 'سارة', 'phone': '+970599123456'},
      'event': {'title': 'زفاف'},
    }, imageUrls: ['https://example.test/r.jpg']);
    expect(request.amount, 400);
    expect(request.isUpgrade, isTrue);
    expect(request.imageUrls.single, contains('r.jpg'));
    expect(StaffModels.client({'id': 1, 'name': 'x', 'is_verified': 1, 'account_type': 'institution'}).isInstitution, isTrue);
  });

  test('the team signs in, is found again on this phone, and signs out', () async {
    final repo = _Repo();
    final session = StaffSessionCubit(
      signIn: SignInStaffUseCase(repo),
      restore: RestoreStaffUseCase(repo),
      signOut: SignOutStaffUseCase(repo),
    );
    await session.open();
    expect(session.state.checking, isFalse);
    expect(session.state.user, isNull);

    await session.enter('mona@maktoob.test', 'wrong');
    expect(session.state.user, isNull);
    expect(session.state.error, isNotEmpty);

    await session.enter(' mona@maktoob.test ', 'secret');
    expect(session.state.user?.name, 'منى');

    await session.open(); // the app was reopened
    expect(session.state.user, isNotNull);

    await session.leave();
    expect(session.state.user, isNull);
    await session.close();
  });

  test('a request is approved once, or refused only with a reason', () async {
    final repo = _Repo();
    StaffRequestCubit cubit() => StaffRequestCubit(
          getRequest: GetStaffPaymentRequestUseCase(repo),
          review: ReviewStaffPaymentRequestUseCase(repo),
          id: 5,
        );

    final approving = cubit();
    await approving.load();
    await approving.approve();
    await approving.approve(); // a second tap changes nothing
    expect(approving.state.reviewed, isTrue);
    expect(repo.decisions, ['approve 5']);

    final rejecting = cubit();
    await rejecting.load();
    await rejecting.reject('   ');
    expect(rejecting.state.reviewed, isNull);
    expect(rejecting.state.message, 'staff_reason_required');
    await rejecting.reject(' الإيصال غير واضح ');
    expect(rejecting.state.reviewed, isFalse);
    expect(repo.decisions.last, 'reject 5: الإيصال غير واضح');

    // The server refuses (already paid): staff see why and nothing is marked done.
    repo.refuse = true;
    final refused = cubit();
    await refused.load();
    await refused.approve();
    expect(refused.state.reviewed, isNull);
    expect(refused.state.message, contains('already been paid'));
    await approving.close();
    await rejecting.close();
    await refused.close();
  });

  group('layout', () {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final (name, size, textScale) in _viewports) {
        testWidgets('${locale.languageCode}: $name', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final repo = _Repo();
          final session = StaffSessionCubit(
            signIn: SignInStaffUseCase(repo),
            restore: RestoreStaffUseCase(repo),
            signOut: SignOutStaffUseCase(repo),
          );
          final today = StaffLoadCubit<StaffToday>((_) => repo.today());
          final requests = StaffLoadCubit<List<StaffPaymentRequest>>((_) => repo.paymentRequests());
          final clients = StaffLoadCubit<List<StaffClientRow>>((search) => repo.clients(search: search));
          final events = StaffLoadCubit<List<StaffEventRow>>((search) => repo.events(search: search));
          final request = StaffRequestCubit(
            getRequest: GetStaffPaymentRequestUseCase(repo),
            review: ReviewStaffPaymentRequestUseCase(repo),
            id: 5,
          );
          for (final cubit in <Cubit<dynamic>>[session, today, requests, clients, events, request]) {
            addTearDown(cubit.close);
          }
          await tester.runAsync(() async {
            await session.open();
            await today.load();
            await requests.load();
            await clients.load();
            await events.load();
            await request.load();
          });

          Future<void> show(Widget page) async {
            await tester.runAsync(() async {
              await tester.pumpWidget(_app(page, locale));
              await Future<void>.delayed(const Duration(milliseconds: 200));
            });
            await tester.pump();
            expect(tester.takeException(), isNull);
          }

          await show(BlocProvider.value(value: session, child: const StaffLoginScreen()));
          expect(find.byKey(const Key('staff_enter')), findsOneWidget);

          await show(Scaffold(body: StaffTodayView(onOpenPayments: () {}, cubit: today)));
          expect(find.byKey(const Key('staff_today_payments')), findsOneWidget);
          expect(find.byKey(const Key('staff_today_identities')), findsNothing);

          await show(Scaffold(body: BlocProvider.value(value: requests, child: const StaffRequestsList())));
          expect(find.byKey(const Key('staff_request_5')), findsOneWidget);

          await show(Scaffold(body: BlocProvider.value(value: clients, child: const StaffClientsList())));
          expect(find.byKey(const Key('staff_client_1')), findsOneWidget);

          await show(Scaffold(body: BlocProvider.value(value: events, child: const StaffEventsList())));
          expect(find.byKey(const Key('staff_event_9')), findsOneWidget);

          await show(BlocProvider.value(value: request, child: const StaffRequestScreen()));
          expect(find.byKey(const Key('staff_approve')), findsOneWidget);
          expect(find.byKey(const Key('staff_reject')), findsOneWidget);
        });
      }
    }
  });
}
