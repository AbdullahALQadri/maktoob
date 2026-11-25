import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/payment/data/models/my_payments_model.dart';
import 'package:maktoob/features/payment/domain/entities/my_payments.dart';
import 'package:maktoob/features/payment/domain/repositories/my_payments_repository.dart';
import 'package:maktoob/features/payment/domain/usecases/get_my_payments_usecase.dart';
import 'package:maktoob/features/payment/presentation/cubit/my_payments_cubit.dart';
import 'package:maktoob/features/payment/presentation/screens/my_payments_screen.dart';

/// "My payments": the `GET /payments/overview` contract, and the screen in
/// Arabic and English from a small phone with large text to a desktop.
const _json = {
  'success': true,
  'message': 'ok',
  'data': {
    'paid_total': '99.00',
    'payments': [
      {
        'id': 7,
        'receipt_number': 'INV-20261112-0003',
        'event_id': 34,
        'event_title': 'عزومة وسهرة عائلية',
        'amount': 99,
        'currency': 'ILS',
        'method': 'wallet',
        'wallet_provider': 'Jawwal Pay',
        'reference': 'W-1',
        'status': 'paid',
        'paid_at': '2026-11-12T15:58:00+02:00',
        'receipt_url': 'https://maktoob.social/receipts/7?signature=x',
      },
    ],
    'due': [
      {'event_id': 35, 'event_title': 'حفل تخرج سارة من كلية الهندسة في الجامعة الإسلامية', 'amount': 250.5},
    ],
    'requests': [
      {
        'id': 3,
        'request_number': 'PR-0003',
        'event_id': 36,
        'event_title': 'ورشة',
        'amount': 120,
        'status': 'rejected',
        'admin_notes': 'الصورة غير واضحة',
        'created_at': '2026-11-10T10:00:00+02:00',
      },
    ],
  },
};

class _Repository implements MyPaymentsRepository {
  @override
  Future<Either<Failure, MyPayments>> getMyPayments() async => Right(MyPaymentsModel.fromJson(_json));
}

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('phone, very large text', Size(390, 844), 2.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  test('parses the overview, keeping Gaza wall-clock time', () {
    final p = MyPaymentsModel.fromJson(_json);
    expect(p.paidTotal, 99);
    expect(p.receipts.single.receiptNumber, 'INV-20261112-0003');
    expect(p.receipts.single.eventId, '34');
    expect(p.receipts.single.walletProvider, 'Jawwal Pay');
    expect(p.receipts.single.paidAt, DateTime(2026, 11, 12, 15, 58));
    expect(p.due.single.amount, 250.5);
    expect(p.sent.single.isRejected, isTrue);
    expect(p.sent.single.reason, 'الصورة غير واضحة');
  });

  test('tolerates an empty answer', () {
    final p = MyPaymentsModel.fromJson(const {'data': {}});
    expect(p.isEmpty, isTrue);
    expect(p.paidTotal, 0);
  });

  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final (name, size, textScale) in _viewports) {
      testWidgets('${locale.languageCode}: $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await tester.runAsync(() async {
          await tester.pumpWidget(
            BlocProvider(
              create: (_) => MyPaymentsCubit(getMyPayments: GetMyPaymentsUseCase(_Repository()))..load(),
              child: MaterialApp(
                locale: locale,
                supportedLocales: AppLocalizationsSetup.supportedLocales,
                localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
                home: const MyPaymentsScreen(),
              ),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        // Due first, then the refused receipt, then the receipts (scrolled to).
        await tester.scrollUntilVisible(find.text('INV-20261112-0003'), 200, scrollable: find.byType(Scrollable).first);
        expect(tester.takeException(), isNull);
        expect(find.text('INV-20261112-0003'), findsOneWidget);
        // Translated, never a raw key.
        expect(find.textContaining('my_payments_'), findsNothing);
      });
    }
  }
}
