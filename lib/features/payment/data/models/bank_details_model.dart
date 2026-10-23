import '../../domain/entities/bank_details_entity.dart';

/// Parses `GET /payments/bank-details`:
///
/// ```json
/// { "success": true, "data": {
///     "bank":   { "name_ar", "name_en", "account_holder", "account_number", "iban", "swift_code" } | null,
///     "wallet": { "provider_name", "account_number" } | null,   // first wallet (old apps)
///     "wallets": [ { "provider_name", "account_number" } ],     // newer backends only
///     "instructions": { "ar", "en" },
///     "contact": { "invoice_whatsapp", "support_whatsapp" },
///     "is_configured": bool } }
/// ```
///
/// Tolerant by design: any block or field may be missing or null, and blank
/// strings are treated as unset — a partially configured account must still
/// show the parts that exist instead of failing to parse.
class BankDetailsModel extends BankDetailsEntity {
  const BankDetailsModel({
    super.bankNameAr,
    super.bankNameEn,
    super.accountHolder,
    super.accountNumber,
    super.iban,
    super.swiftCode,
    super.walletProviderName,
    super.walletAccountNumber,
    super.instructionsAr,
    super.instructionsEn,
    super.supportWhatsapp,
    super.invoiceWhatsapp,
    super.wallets,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    final bank = _map(json['bank']);
    final wallet = _map(json['wallet']);
    final instructions = _map(json['instructions']);
    final contact = _map(json['contact']);

    return BankDetailsModel(
      bankNameAr: _text(bank['name_ar']),
      bankNameEn: _text(bank['name_en']),
      accountHolder: _text(bank['account_holder']),
      accountNumber: _text(bank['account_number']),
      iban: _text(bank['iban']),
      swiftCode: _text(bank['swift_code']),
      walletProviderName: _text(wallet['provider_name']),
      walletAccountNumber: _text(wallet['account_number']),
      instructionsAr: _text(instructions['ar']),
      instructionsEn: _text(instructions['en']),
      supportWhatsapp: _text(contact['support_whatsapp']),
      invoiceWhatsapp: _text(contact['invoice_whatsapp']),
      wallets: _wallets(json['wallets'], wallet),
    );
  }

  /// `wallets` may be absent (older backend): fall back to the single `wallet`.
  /// Entries without an account number are dropped — nothing to pay into.
  static List<WalletAccountEntity> _wallets(
      dynamic list, Map<String, dynamic> legacy) {
    final source = list is List && list.isNotEmpty ? list : [legacy];
    final result = <WalletAccountEntity>[];
    for (final item in source) {
      final m = _map(item);
      final number = _text(m['account_number']);
      if (number == null) continue;
      result.add(WalletAccountEntity(
        providerName: _text(m['provider_name']) ?? '',
        accountNumber: number,
      ));
    }
    return result;
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

  static String? _text(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
