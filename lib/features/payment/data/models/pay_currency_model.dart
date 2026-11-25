import '../../domain/entities/pay_currency.dart';

class PayCurrencyModel extends PayCurrency {
  const PayCurrencyModel({
    required super.code,
    required super.amount,
    required super.formatted,
    super.nameAr,
    super.nameEn,
    super.symbol,
    super.rate,
  });

  factory PayCurrencyModel.fromJson(Map<String, dynamic> json) {
    final amount = _number(json['amount']);
    return PayCurrencyModel(
      code: '${json['code'] ?? json['currency'] ?? ''}'.toUpperCase(),
      amount: amount,
      formatted: json['formatted']?.toString() ?? amount.toStringAsFixed(2),
      nameAr: json['name_ar']?.toString(),
      nameEn: json['name_en']?.toString(),
      symbol: json['symbol']?.toString(),
      rate: _number(json['rate'], fallback: 1),
    );
  }

  /// The list with the shekel total, inside "data" or bare.
  static PayCurrencies listFromJson(dynamic response) {
    final root = response is Map ? response['data'] ?? response : null;
    final data = root is Map ? root : const {};
    final list = data['currencies'];
    return PayCurrencies(
      ilsTotal: _number(data['ils_total']),
      options: [
        for (final item in list is List ? list : const [])
          if (item is Map) PayCurrencyModel.fromJson(Map<String, dynamic>.from(item)),
      ],
    );
  }

  /// MySQL sends decimals as text.
  static double _number(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? fallback;
  }
}
