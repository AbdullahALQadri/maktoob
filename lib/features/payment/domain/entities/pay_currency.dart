import 'package:equatable/equatable.dart';

/// One currency the client may pay an event in, with its amount already
/// quoted by the server (the client picks a currency, never an amount).
class PayCurrency extends Equatable {
  const PayCurrency({
    required this.code,
    required this.amount,
    required this.formatted,
    this.nameAr,
    this.nameEn,
    this.symbol,
    this.rate = 1,
  });

  static const baseCode = 'ILS';

  /// ISO code: ILS, USD, EUR.
  final String code;
  final double amount;

  /// The amount as it is shown, symbol included.
  final String formatted;
  final String? nameAr;
  final String? nameEn;
  final String? symbol;

  /// Shekels per one unit of this currency.
  final double rate;

  bool get isBase => code == baseCode;

  String name({required bool arabic}) => (arabic ? nameAr ?? nameEn : nameEn ?? nameAr) ?? code;

  @override
  List<Object?> get props => [code, amount, formatted, nameAr, nameEn, symbol, rate];
}

/// The "Pay in" choices of an event. The ledger is always in shekels.
class PayCurrencies extends Equatable {
  const PayCurrencies({required this.ilsTotal, this.options = const []});

  final double ilsTotal;
  final List<PayCurrency> options;

  /// Something other than the shekel is offered: only then is there a choice.
  bool get hasChoice => options.any((c) => !c.isBase);

  @override
  List<Object?> get props => [ilsTotal, options];
}
