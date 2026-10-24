import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/domain/entities/event_card.dart';
import 'package:maktoob/features/home/domain/entities/home_summary.dart';
import 'package:maktoob/features/home/presentation/widgets/home_events_section.dart';
import 'package:maktoob/features/home/presentation/widgets/home_first_visit.dart';
import 'package:maktoob/features/home/presentation/widgets/home_hero.dart';
import 'package:maktoob/features/home/presentation/widgets/home_kpis.dart';
import 'package:maktoob/features/institution/domain/entities/institution_entity.dart';
import 'package:maktoob/features/home/presentation/widgets/institution_notice.dart';

/// Home lays out without overflow from the smallest phone to a desktop
/// window, in Arabic (RTL) and English, with large system text.
const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('small phone, large text', Size(320, 568), 1.3),
  ('phone, very large text', Size(390, 844), 2.0),
  ('phone', Size(390, 844), 1.0),
  ('tablet', Size(768, 1024), 1.0),
  ('desktop', Size(1280, 800), 1.0),
];

EventCard _event(int id, {int? step, EventStatus status = EventStatus.active}) => EventCard(
      id: id,
      title: 'حفل زفاف أحمد وليلى في قاعة الروضة الكبرى',
      status: status,
      role: EventRole.owner,
      nextAction: step == null ? NextAction.viewResults : NextAction.chooseDesign,
      typeNameAr: 'زفاف',
      typeNameEn: 'Wedding',
      date: DateTime(2026, 10, 29, 19),
      invitations: 600,
      responded: 410,
      countdownDays: id * 4,
      stepNumber: step,
    );

final _summary = HomeSummary(
  totals: const HomeTotals(events: 6, activeEvents: 2, invitations: 12040, responses: 8734, responseRate: 72),
  nextEvent: _event(1, step: 3, status: EventStatus.draft),
  events: [_event(1, step: 3, status: EventStatus.draft), _event(2), _event(3)],
  gazaOffset: const Duration(hours: 2),
);

Widget _home() => Builder(
      builder: (context) => ListView(
        children: [
          HomeHero(summary: _summary, firstName: 'عبد الرحمن', orgLine: 'جمعية النور الخيرية · رصيد 300 دعوة', onCreate: () {}, onMyEvents: () {}, onAction: (_) {}),
          const InstitutionNotice(status: InstitutionStatus.pending, verification: InstitutionVerification(name: true), onComplete: _noop),
          HomeKpis(totals: _summary.totals),
          HomeEventsSection(events: _summary.events, onOpen: (_) {}, onViewAll: () {}),
          const HomeFirstVisit(),
        ],
      ),
    );

void _noop() {}

void main() {
  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final (name, size, textScale) in _viewports) {
      testWidgets('${locale.languageCode}: $name (${size.width.toInt()}×${size.height.toInt()} @ ${textScale}x)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.runAsync(() async {
          await tester.pumpWidget(MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizationsSetup.supportedLocales,
            localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
            home: Scaffold(body: _home()),
          ));
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(HomeHero), findsOneWidget);
      });
    }
  }
}
