import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/payment/data/models/bank_details_model.dart';
import 'package:maktoob/features/payment/domain/entities/bank_details_entity.dart';
import 'package:maktoob/features/payment/domain/entities/payment_method.dart';
import 'package:maktoob/features/payment/presentation/widgets/payment_method_widgets.dart';

/// `wallets` (every configured wallet) is newer than `wallet` (the first one).
/// Values are obvious test fixtures, not real payment data.
void main() {
  test('parses every wallet from `wallets`', () {
    final m = BankDetailsModel.fromJson(const {
      'wallet': {'provider_name': 'Wallet A', 'account_number': 'TEST-W-1'},
      'wallets': [
        {'provider_name': 'Wallet A', 'account_number': 'TEST-W-1'},
        {'provider_name': 'Wallet B', 'account_number': 'TEST-W-2'},
        {'provider_name': 'Broken', 'account_number': ''},
      ],
      'contact': {'invoice_whatsapp': '+000000000001', 'support_whatsapp': '+000000000002'},
    });

    expect(m.walletOptions, const [
      WalletAccountEntity(providerName: 'Wallet A', accountNumber: 'TEST-W-1'),
      WalletAccountEntity(providerName: 'Wallet B', accountNumber: 'TEST-W-2'),
    ]);
    expect(m.paymentWhatsapp, '+000000000001', reason: 'invoice number wins over support');
  });

  test('old backend without `wallets` falls back to `wallet`', () {
    final m = BankDetailsModel.fromJson(const {
      'wallet': {'provider_name': 'Wallet A', 'account_number': 'TEST-W-1'},
      'contact': {'support_whatsapp': '+000000000002'},
    });

    expect(m.walletOptions.single.providerName, 'Wallet A');
    expect(m.paymentWhatsapp, '+000000000002');
  });

  test('no wallets at all', () {
    final m = BankDetailsModel.fromJson(const {'wallet': null, 'wallets': []});
    expect(m.walletOptions, isEmpty);
    expect(m.hasWallet, isFalse);
    expect(m.paymentWhatsapp, isNull);
  });

  group('PaymentChoice.available', () {
    test('cash is always offered, even when loading failed', () {
      expect(PaymentChoice.available(null), const [PaymentChoice.cash()]);
      expect(PaymentChoice.available(const BankDetailsEntity.loadFailed()), const [PaymentChoice.cash()]);
    });

    test('bank only when configured, one row per wallet', () {
      final choices = PaymentChoice.available(BankDetailsModel.fromJson(const {
        'bank': {'iban': 'TEST-IBAN'},
        'wallets': [
          {'provider_name': 'Wallet A', 'account_number': 'TEST-W-1'},
          {'provider_name': 'Wallet B', 'account_number': 'TEST-W-2'},
        ],
      }));
      expect(choices.map((c) => c.method), [
        PaymentMethod.cash,
        PaymentMethod.bankTransfer,
        PaymentMethod.wallet,
        PaymentMethod.wallet,
      ]);
      expect(choices.last.wallet?.providerName, 'Wallet B');
    });
  });

  test('WhatsApp link carries the prefilled message, hidden without a number', () {
    final uri = buildPaymentWhatsappUri(
      number: '+970 59-000-0000',
      template: 'pay #{event} {amount} via {method}',
      event: '42',
      amount: '99',
      method: 'Cash',
    )!;
    expect(uri.host, 'wa.me');
    expect(uri.path, '/970590000000');
    expect(uri.queryParameters['text'], 'pay #42 99 via Cash');

    expect(
      buildPaymentWhatsappUri(number: null, template: 't', event: '1', amount: null, method: 'm'),
      isNull,
    );
  });
}
