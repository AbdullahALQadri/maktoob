import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:maktoob/features/payment/data/models/bank_details_model.dart';
import 'package:maktoob/features/payment/data/models/pay_currency_model.dart';
import 'package:maktoob/features/payment/domain/entities/pay_currency.dart';
import 'package:maktoob/features/payment/domain/entities/payment_method.dart';
import 'package:maktoob/features/payment/domain/repositories/pay_currency_repository.dart';
import 'package:maktoob/features/payment/domain/usecases/get_pay_currencies_usecase.dart';
import 'package:maktoob/features/payment/presentation/cubit/pay_currency_cubit.dart';
import 'package:maktoob/features/payment/presentation/widgets/pay_currency_picker.dart';
import 'package:maktoob/features/payment/presentation/widgets/payment_amount_line.dart';

const _response = {
  'success': true,
  'data': {
    'ils_total': 99,
    'currencies': [
      {'code': 'ILS', 'name_ar': 'شيكل', 'name_en': 'Shekel', 'symbol': '₪', 'amount': 99, 'formatted': '₪99', 'rate': 1},
      // MySQL sends decimals as text.
      {'code': 'USD', 'name_ar': 'دولار أمريكي', 'name_en': 'US dollar', 'symbol': r'$', 'amount': '29.00', 'formatted': r'$29', 'rate': '3.413793'},
    ],
  },
};

class _Repo implements PayCurrencyRepository {
  _Repo(this.answer);

  final Either<Failure, PayCurrencies> answer;

  @override
  Future<Either<Failure, PayCurrencies>> currenciesFor(String eventId) async => answer;
}

PayCurrencyCubit _cubit(Either<Failure, PayCurrencies> answer) =>
    PayCurrencyCubit(getPayCurrencies: GetPayCurrenciesUseCase(_Repo(answer)));

void main() {
  final currencies = PayCurrencyModel.listFromJson(_response);

  test('reads the choices, numbers sent as text included', () {
    expect(currencies.ilsTotal, 99);
    expect(currencies.options.map((c) => c.code), ['ILS', 'USD']);
    expect(currencies.options.last.amount, 29);
    expect(currencies.options.last.rate, closeTo(3.4138, 0.001));
    expect(currencies.hasChoice, isTrue);
    // Only the shekel on offer: nothing to choose, so no picker.
    final shekelOnly = PayCurrencyModel.listFromJson({
      'data': {
        'ils_total': 99,
        'currencies': [
          {'code': 'ILS', 'amount': 99, 'formatted': '₪99'},
        ],
      },
    });
    expect(shekelOnly.hasChoice, isFalse);
  });

  test('the shekel goes without a currency; another one is sent by its code', () async {
    final cubit = _cubit(Right(currencies));
    await cubit.load('7');
    expect(cubit.state.hasChoice, isTrue);
    expect(cubit.state.currencyToSend, isNull);

    cubit.select('USD');
    expect(cubit.state.currencyToSend, 'USD');
    expect(cubit.state.selected?.formatted, r'$29');

    final fields = PaymentRemoteDataSourceImpl.buildPaymentRequestFields(
      eventId: '7',
      method: PaymentMethod.bankTransfer,
      currency: cubit.state.currencyToSend,
    );
    expect(fields['original_currency'], 'USD');
    // The amount is never sent: the server quotes it.
    expect(fields.containsKey('original_amount'), isFalse);

    final shekels = PaymentRemoteDataSourceImpl.buildPaymentRequestFields(
      eventId: '7',
      method: PaymentMethod.cash,
      currency: 'ILS',
    );
    expect(shekels.containsKey('original_currency'), isFalse);
    await cubit.close();
  });

  test('a list that cannot be read leaves the shekel: paying is never blocked', () async {
    final cubit = _cubit(const Left(NetworkFailure(message: 'offline')));
    await cubit.load('7');
    expect(cubit.state.hasChoice, isFalse);
    expect(cubit.state.currencyToSend, isNull);
    await cubit.close();
  });

  test('a currency with an account of its own says so', () {
    final details = BankDetailsModel.fromJson({
      'bank': {'name_en': 'Bank of Palestine', 'iban': 'PS00USD'},
      'bank_currency': 'USD',
    });
    expect(details.bankCurrency, 'USD');
    expect(BankDetailsModel.fromJson({'bank': {'iban': 'PS00ILS'}}).bankCurrency, isNull);
  });

  group('layout', () {
    const viewports = <(String, Size, double)>[
      ('small phone', Size(320, 568), 1.0),
      ('phone, very large text', Size(390, 844), 2.0),
      ('desktop', Size(1280, 800), 1.0),
    ];
    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final (name, size, textScale) in viewports) {
        testWidgets('${locale.languageCode}: $name', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          String? picked;
          await tester.runAsync(() async {
            await tester.pumpWidget(MaterialApp(
              locale: locale,
              supportedLocales: AppLocalizationsSetup.supportedLocales,
              localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
              home: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PayCurrencyPicker(currencies: currencies, selectedCode: 'USD', onChanged: (code) => picked = code),
                    PaymentAmountLine(amount: 99, currency: currencies.options.last),
                  ],
                ),
              ),
            ));
            await Future<void>.delayed(const Duration(milliseconds: 200));
          });
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('pay_in_note')), findsOneWidget);
          expect(find.textContaining(r'$29'), findsWidgets);
          await tester.tap(find.byKey(const Key('pay_currency_ILS')));
          expect(picked, 'ILS');
        });
      }
    }
  });
}
