import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/events/domain/entities/event_card.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/domain/entities/event_page.dart';
import 'package:maktoob/features/events/domain/repositories/my_events_repository.dart';
import 'package:maktoob/features/events/domain/usecases/get_my_events_usecase.dart';
import 'package:maktoob/features/events/presentation/cubit/my_events/my_events_cubit.dart';
import 'package:maktoob/features/events/presentation/screens/my_events_screen.dart';
import 'package:maktoob/features/events/presentation/widgets/event_row_tile.dart';

/// My events lays out from the smallest phone to a desktop window, in
/// Arabic and English, with large text, and opens the tapped event.
class _Repository implements MyEventsRepository {
  @override
  Future<Either<Failure, EventPage>> getPage({EventStatus? status, String query = '', int page = 1}) async => Right(
    EventPage(
      items: [
        for (var i = 1; i <= 4; i++)
          EventCard(
            id: i,
            title: 'حفل زفاف أحمد وليلى في قاعة الروضة الكبرى $i',
            status: i.isEven ? EventStatus.active : EventStatus.draft,
            role: i == 3 ? EventRole.manager : EventRole.owner,
            nextAction: i.isEven ? NextAction.viewResults : NextAction.chooseDesign,
            date: DateTime(2026, 10, 29, 19),
            invitations: 600,
            responded: 410,
            countdownDays: 5,
            stepNumber: i.isEven ? null : 3,
          ),
      ],
      page: 1,
      lastPage: 1,
      counts: const EventCounts(
        all: 41,
        byStatus: {EventStatus.draft: 2, EventStatus.active: 30, EventStatus.cancelled: 1},
      ),
    ),
  );
}

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('small phone, large text', Size(320, 568), 1.3),
  ('phone, very large text', Size(390, 844), 2.0),
  ('tablet', Size(768, 1024), 1.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final (name, size, textScale) in _viewports) {
      testWidgets('${locale.languageCode}: $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final opened = <String>[];

        await tester.runAsync(() async {
          await tester.pumpWidget(
            BlocProvider(
              create: (_) => MyEventsCubit(getPage: GetMyEventsUseCase(_Repository())),
              child: MaterialApp(
                locale: locale,
                supportedLocales: AppLocalizationsSetup.supportedLocales,
                localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
                home: MyEventsScreen(onOpenEvent: opened.add),
              ),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.textContaining('41'), findsWidgets);
        if (size.width < 600) {
          expect(find.byType(EventRowTile), findsWidgets);
          await tester.tap(find.byType(EventRowTile).first);
          expect(opened, ['1']);
        }
      });
    }
  }
}
