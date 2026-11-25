import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/api/end_points.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/payment/data/models/upgrade_options_model.dart';
import 'package:maktoob/features/payment/domain/entities/upgrade_options.dart';
import 'package:maktoob/features/payment/domain/repositories/billing_repository.dart';
import 'package:maktoob/features/payment/domain/usecases/billing_usecases.dart';
import 'package:maktoob/features/payment/presentation/cubit/upgrade_cubit.dart';
import 'package:maktoob/features/payment/presentation/screens/upgrade_screen.dart';
import 'package:maktoob/features/payment/presentation/widgets/proforma_sheet.dart';

const _response = {
  'success': true,
  'data': {
    'current_limit': 1000,
    'has_pending_request': false,
    'packages': [
      {
        'id': 4,
        'name_ar': 'الباقة الذهبية',
        'name_en': 'Gold',
        'invitations_limit': 2000,
        'price_per_invitation': '0.25',
        'quote': {'current_limit': 1000, 'target_limit': 2000, 'difference': 400, 'total': '400.00'},
      },
    ],
    'custom': {'enabled': true, 'max_guests': 10000},
  },
};

class _Repo implements BillingRepository {
  final proformaCalls = <String>[];
  bool proformaFails = false;

  @override
  Future<Either<Failure, UpgradeOptions>> upgradeOptions(String eventId) async =>
      Right(UpgradeOptionsModel.options(_response));

  @override
  Future<Either<Failure, UpgradeQuote>> customUpgradeQuote(String eventId, int invitations) async =>
      Right(UpgradeQuote(currentLimit: 1000, targetLimit: invitations, total: 750));

  @override
  Future<Either<Failure, String>> proformaUrl(String eventId, {String? funder, String? reference}) async {
    proformaCalls.add('$eventId|$funder|$reference');
    return proformaFails
        ? const Left(ServerFailure(message: 'no'))
        : const Right('https://example.test/proforma/7?signature=abc');
  }
}

UpgradeCubit _cubit(_Repo repo) => UpgradeCubit(
      getOptions: GetUpgradeOptionsUseCase(repo),
      getCustomQuote: GetCustomUpgradeQuoteUseCase(repo),
      eventId: '7',
    );

Widget _app(Widget home, {Locale locale = const Locale('ar')}) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      home: home,
    );

void main() {
  test('reads the bigger packages with what is left to pay', () {
    final options = UpgradeOptionsModel.options(_response);
    expect(options.currentLimit, 1000);
    expect(options.customEnabled, isTrue);
    expect(options.packages.single.invitations, 2000);
    expect(options.packages.single.quote.total, 400);
    expect(options.packages.single.pricePerInvitation, 0.25);
  });

  test('a package or a typed number is chosen, never both', () async {
    final cubit = _cubit(_Repo());
    await cubit.load();
    expect(cubit.state.quote, isNull);

    cubit.selectPackage(4);
    expect(cubit.state.quote?.total, 400);
    expect(cubit.state.usesCustom, isFalse);

    // Not more than the event already has: refused before asking the server.
    await cubit.calculateCustom(900);
    expect(cubit.state.quote, isNull);
    expect(cubit.state.customError, 'upgrade_need_more');

    await cubit.calculateCustom(3000);
    expect(cubit.state.usesCustom, isTrue);
    expect(cubit.state.quote?.targetLimit, 3000);
    expect(cubit.state.packageId, isNull);

    cubit.selectPackage(4);
    expect(cubit.state.usesCustom, isFalse);
    await cubit.close();
  });

  test('the upgrade is sent to its own endpoint with its target', () {
    expect(Endpoints.paymentRequestUpgrade(packageId: 4), '/payment-requests/upgrade?target_package_id=4');
    expect(Endpoints.paymentRequestUpgrade(customInvitations: 3000), '/payment-requests/upgrade?custom_invitations=3000');
  });

  group('screens', () {
    const viewports = <(String, Size, double)>[
      ('small phone', Size(320, 568), 1.0),
      ('phone, very large text', Size(390, 844), 2.0),
      ('desktop', Size(1280, 800), 1.0),
    ];
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final (name, size, textScale) in viewports) {
        testWidgets('upgrade, ${locale.languageCode}: $name', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          final cubit = _cubit(_Repo());
          addTearDown(cubit.close);
          await tester.runAsync(() async {
            await cubit.load();
            await cubit.calculateCustom(3000);
            await tester.pumpWidget(_app(
              BlocProvider.value(value: cubit, child: const UpgradeScreen(eventId: '7', eventTitle: 'زفاف')),
              locale: locale,
            ));
            await Future<void>.delayed(const Duration(milliseconds: 200));
          });
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('upgrade_package_4')), findsOneWidget);
          expect(find.byKey(const Key('upgrade_continue')), findsOneWidget);
        });
      }
    }

    testWidgets('the pro-forma goes out with the funder and the reference', (tester) async {
      final repo = _Repo();
      Uri? opened;
      await tester.runAsync(() async {
        await tester.pumpWidget(_app(Scaffold(
          body: ProformaSheet(
            eventId: '7',
            getProformaUrl: GetProformaUrlUseCase(repo),
            open: (url) async {
              opened = url;
              return true;
            },
          ),
        )));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      await tester.enterText(find.byKey(const Key('proforma_funder')), 'UNDP');
      await tester.enterText(find.byKey(const Key('proforma_reference')), 'G-12');
      await tester.tap(find.byKey(const Key('proforma_open')));
      await tester.pump();
      await tester.pump();

      expect(repo.proformaCalls.single, '7|UNDP|G-12');
      expect(opened.toString(), contains('signature=abc'));
    });

    testWidgets('a pro-forma that cannot be prepared says so and stays open', (tester) async {
      final repo = _Repo()..proformaFails = true;
      await tester.runAsync(() async {
        await tester.pumpWidget(_app(Scaffold(
          body: ProformaSheet(eventId: '7', getProformaUrl: GetProformaUrlUseCase(repo), open: (_) async => true),
        )));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.tap(find.byKey(const Key('proforma_open')));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('proforma_failed')), findsOneWidget);
    });
  });
}
