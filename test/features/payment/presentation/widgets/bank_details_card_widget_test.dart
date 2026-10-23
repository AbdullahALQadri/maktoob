import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations.dart';
import 'package:maktoob/features/payment/domain/entities/bank_details_entity.dart';
import 'package:maktoob/features/payment/presentation/widgets/bank_details_card_widget.dart';

/// The payment-details card on the receipt-upload screen: only configured rows
/// are shown, an unconfigured or failed load is stated plainly, and support
/// chat is offered only with a real configured number.
void main() {
  Future<void> pump(
    WidgetTester tester,
    BankDetailsEntity details, {
    String locale = 'en',
    VoidCallback? onRetry,
  }) async {
    // AppLocalizations reads lang/*.json through rootBundle — real async I/O
    // that the fake test clock does not advance. Let it finish in real time,
    // otherwise whether a test sees translations depends on cache timing.
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        locale: Locale(locale),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            child: BankDetailsCardWidget(bankDetails: details, onRetry: onRetry),
          ),
        ),
      ));
      for (var i = 0; i < 50 && find.byType(BankDetailsCardWidget).evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();
    expect(find.byType(BankDetailsCardWidget), findsOneWidget, reason: 'translations loaded');
  }

  const full = BankDetailsEntity(
    bankNameAr: 'بنك الاختبار',
    bankNameEn: 'Test Bank',
    accountHolder: 'TEST HOLDER',
    accountNumber: 'TEST-ACC-001',
    iban: 'TEST-IBAN-001',
    swiftCode: 'TESTSWFT',
    walletProviderName: 'Test Wallet',
    walletAccountNumber: 'TEST-WALLET-001',
    instructionsEn: 'Test instructions',
    supportWhatsapp: '+000000000002',
  );

  testWidgets('shows every configured value', (tester) async {
    await pump(tester, full);

    for (final value in ['Test Bank', 'TEST HOLDER', 'TEST-ACC-001', 'TEST-IBAN-001', 'TESTSWFT', 'TEST-WALLET-001', 'Test instructions']) {
      expect(find.text(value), findsOneWidget, reason: value);
    }
    expect(find.byKey(const Key('bank_details_contact_support')), findsOneWidget);
  });

  testWidgets('hides rows without a value, including SWIFT', (tester) async {
    await pump(tester, const BankDetailsEntity(iban: 'TEST-IBAN-001'));

    expect(find.text('TEST-IBAN-001'), findsOneWidget);
    expect(find.text('SWIFT / BIC'), findsNothing);
    expect(find.text('Account holder'), findsNothing);
    expect(find.text('Wallet / local payment service'), findsNothing);
  });

  testWidgets('nothing configured: says so, and never offers a fake contact', (tester) async {
    await pump(tester, const BankDetailsEntity());

    expect(
      find.text('Payment details are not available yet. Please contact Maktoob support before transferring any money.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('bank_details_support_unavailable')), findsOneWidget);
    expect(find.byKey(const Key('bank_details_contact_support')), findsNothing);
  });

  testWidgets('nothing configured but support number set: offers support chat', (tester) async {
    await pump(tester, const BankDetailsEntity(supportWhatsapp: '+000000000002'));

    expect(find.byKey(const Key('bank_details_contact_support')), findsOneWidget);
  });

  testWidgets('failed request: explains and retries instead of loading forever', (tester) async {
    var retried = 0;
    await pump(tester, const BankDetailsEntity.loadFailed(), onRetry: () => retried++);

    expect(find.text("We couldn't load the payment details. Check your connection and try again."), findsOneWidget);
    await tester.tap(find.byKey(const Key('bank_details_retry')));
    expect(retried, 1);
  });

  testWidgets('Arabic locale shows Arabic labels and the Arabic bank name', (tester) async {
    await pump(tester, full, locale: 'ar');

    expect(find.text('بيانات الدفع'), findsOneWidget);
    expect(find.text('بنك الاختبار'), findsOneWidget);
    expect(find.text('التحويل البنكي'), findsOneWidget);
    expect(find.textContaining('not found'), findsNothing, reason: 'no missing translation keys');
  });
}
