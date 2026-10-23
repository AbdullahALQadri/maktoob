import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/payment/data/models/bank_details_model.dart';

/// `GET /payments/bank-details` parsing. Every field is optional: a partially
/// configured account must still parse and expose what exists. Values here are
/// obvious test fixtures, not real payment data.
void main() {
  const full = {
    'bank': {
      'name_ar': 'بنك الاختبار',
      'name_en': 'Test Bank',
      'account_holder': 'TEST HOLDER',
      'account_number': 'TEST-ACC-001',
      'iban': 'TEST-IBAN-001',
      'swift_code': 'TESTSWFT',
    },
    'wallet': {'provider_name': 'Test Wallet', 'account_number': 'TEST-WALLET-001'},
    'instructions': {'ar': 'تعليمات', 'en': 'Instructions'},
    'contact': {'invoice_whatsapp': '+000000000001', 'support_whatsapp': '+000000000002'},
    'is_configured': true,
  };

  test('parses every configured field', () {
    final m = BankDetailsModel.fromJson(full);

    expect(m.iban, 'TEST-IBAN-001');
    expect(m.swiftCode, 'TESTSWFT');
    expect(m.accountHolder, 'TEST HOLDER');
    expect(m.walletAccountNumber, 'TEST-WALLET-001');
    expect(m.supportWhatsapp, '+000000000002');
    expect(m.bankName(arabic: true), 'بنك الاختبار');
    expect(m.bankName(arabic: false), 'Test Bank');
    expect(m.isConfigured, isTrue);
    expect(m.loadFailed, isFalse);
  });

  test('missing SWIFT and holder do not break parsing or hide the rest', () {
    final m = BankDetailsModel.fromJson({
      'bank': {'name_en': 'Test Bank', 'iban': 'TEST-IBAN-001', 'swift_code': null},
    });

    expect(m.iban, 'TEST-IBAN-001');
    expect(m.swiftCode, isNull);
    expect(m.accountHolder, isNull);
    expect(m.hasBank, isTrue);
    expect(m.isConfigured, isTrue);
  });

  test('null blocks and blank strings are treated as unset', () {
    final m = BankDetailsModel.fromJson({
      'bank': null,
      'wallet': null,
      'instructions': {'ar': '   ', 'en': ''},
      'contact': {'support_whatsapp': ' '},
    });

    expect(m.hasBank, isFalse);
    expect(m.hasWallet, isFalse);
    expect(m.hasInstructions, isFalse);
    expect(m.supportWhatsapp, isNull);
    expect(m.isConfigured, isFalse);
  });

  test('an empty payload parses to an unconfigured entity instead of throwing', () {
    final m = BankDetailsModel.fromJson(const {});

    expect(m.isConfigured, isFalse);
    expect(m.loadFailed, isFalse);
  });

  test('instructions alone (e.g. cash in person) count as configured', () {
    final m = BankDetailsModel.fromJson({
      'instructions': {'ar': 'الدفع نقدًا', 'en': null},
    });

    expect(m.isConfigured, isTrue);
    expect(m.instructions(arabic: false), 'الدفع نقدًا', reason: 'falls back to the other language');
  });

  test('a bank name without an account number or IBAN is not a usable bank', () {
    final m = BankDetailsModel.fromJson({
      'bank': {'name_en': 'Test Bank', 'swift_code': 'TESTSWFT'},
    });

    expect(m.hasBank, isFalse);
    expect(m.isConfigured, isFalse);
  });
}
