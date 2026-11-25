import 'package:equatable/equatable.dart';

import '../../domain/entities/pay_currency.dart';

/// The currencies on offer and the one the client pays in.
class PayCurrencyState extends Equatable {
  const PayCurrencyState({this.currencies, this.selectedCode = PayCurrency.baseCode});

  /// Null until loaded; stays null when the list could not be read, and
  /// the payment then goes on in shekels.
  final PayCurrencies? currencies;
  final String selectedCode;

  bool get hasChoice => currencies?.hasChoice ?? false;

  PayCurrency? get selected {
    for (final currency in currencies?.options ?? const <PayCurrency>[]) {
      if (currency.code == selectedCode) return currency;
    }
    return null;
  }

  /// What goes with the payment: null for shekels.
  String? get currencyToSend => selectedCode == PayCurrency.baseCode ? null : selectedCode;

  @override
  List<Object?> get props => [currencies, selectedCode];
}
