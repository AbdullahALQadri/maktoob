import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/config/routes/app_routes.dart';
import 'package:maktoob/features/events/data/models/event_model.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/presentation/widgets/all_events_card_widget.dart';

EventModel _event(String status, {Object? total}) => EventModel.fromJson({
      'id': 5,
      'title': 'زفاف',
      'status': status,
      'event_date': '2026-11-01',
      if (total != null) 'invoice_total': total,
    });

void main() {
  group('EventStatus parsing', () {
    test('covers every backend status', () {
      expect(_event('draft').status, EventStatus.draft);
      expect(_event('pending_payment').status, EventStatus.pendingPayment);
      expect(_event('active').status, EventStatus.active);
      expect(_event('completed').status, EventStatus.completed);
      expect(_event('cancelled').status, EventStatus.cancelled);
      expect(_event('something_new').status, EventStatus.draft);
    });

    test('apiValue round-trips the backend values', () {
      for (final s in EventStatus.values) {
        expect(EventStatusApi.parse(s.apiValue), s);
      }
      expect(EventStatus.pendingPayment.apiValue, 'pending_payment');
    });

    test('pending payment and cancelled are inactive', () {
      expect(_event('pending_payment').isPendingPayment, isTrue);
      expect(_event('pending_payment').isInactive, isTrue);
      expect(_event('cancelled').isInactive, isTrue);
      expect(_event('active').isInactive, isFalse);
    });
  });

  group('event card', () {
    Future<List<Object?>> pumpCard(WidgetTester tester, EventEntity event) async {
      final pushed = <Object?>[];
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          onGenerateRoute: (settings) {
            if (settings.name == Routes.payment) pushed.add(settings.arguments);
            return MaterialPageRoute(builder: (_) => const SizedBox());
          },
          home: Scaffold(
            body: SingleChildScrollView(child: AllEventsCardWidget(event: event, index: 0)),
          ),
        ));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();
      return pushed;
    }

    testWidgets('pending payment shows the badge and a pay action', (tester) async {
      final pushed = await pumpCard(tester, _event('pending_payment', total: '150.00'));

      expect(find.text('بانتظار الدفع'), findsOneWidget);
      final pay = find.byKey(const Key('event_card_pay_5'));
      expect(pay, findsOneWidget);

      await tester.ensureVisible(pay);
      await tester.tap(pay);
      await tester.pumpAndSettle();

      final args = pushed.single as Map;
      expect(args['eventId'], '5');
      expect(args['amount'], 150.0);
      expect(args['eventTitle'], 'زفاف');
    });

    testWidgets('active and cancelled events have no pay action', (tester) async {
      await pumpCard(tester, _event('active'));
      expect(find.byKey(const Key('event_card_pay_5')), findsNothing);

      await pumpCard(tester, _event('cancelled'));
      expect(find.text('ملغاة'), findsOneWidget);
      expect(find.byKey(const Key('event_card_pay_5')), findsNothing);
    });
  });
}
