import 'package:equatable/equatable.dart';

/// One configured local wallet (e.g. Jawwal Pay, PalPay).
class WalletAccountEntity extends Equatable {
  final String providerName;
  final String accountNumber;

  const WalletAccountEntity({
    required this.providerName,
    required this.accountNumber,
  });

  @override
  List<Object?> get props => [providerName, accountNumber];
}

/// Maktoob's manual-payment details (bank transfer, local wallet, cash
/// instructions) from `GET /payments/bank-details`.
///
/// Every field is optional: a value the admin has not configured is null and
/// its row is simply not shown. Nothing here is ever filled with a placeholder.
class BankDetailsEntity extends Equatable {
  final String? bankNameAr;
  final String? bankNameEn;
  final String? accountHolder;
  final String? accountNumber;
  final String? iban;
  final String? swiftCode;
  final String? walletProviderName;
  final String? walletAccountNumber;
  final String? instructionsAr;
  final String? instructionsEn;
  final String? supportWhatsapp;

  /// WhatsApp number that receives payment receipts / cash arrangements.
  final String? invoiceWhatsapp;

  /// Every configured wallet. Empty when none is configured.
  final List<WalletAccountEntity> wallets;

  /// True when the details could not be loaded at all (network/server error),
  /// as opposed to loaded-but-not-configured.
  final bool loadFailed;

  const BankDetailsEntity({
    this.bankNameAr,
    this.bankNameEn,
    this.accountHolder,
    this.accountNumber,
    this.iban,
    this.swiftCode,
    this.walletProviderName,
    this.walletAccountNumber,
    this.instructionsAr,
    this.instructionsEn,
    this.supportWhatsapp,
    this.invoiceWhatsapp,
    this.wallets = const [],
    this.loadFailed = false,
  });

  /// The request failed; the screen must show this instead of loading forever.
  const BankDetailsEntity.loadFailed() : this(loadFailed: true);

  /// A transfer needs something to transfer TO.
  bool get hasBank => accountNumber != null || iban != null;

  bool get hasWallet => wallets.isNotEmpty || walletAccountNumber != null;

  /// Wallets to offer: the list, or the single legacy `wallet` block.
  List<WalletAccountEntity> get walletOptions {
    if (wallets.isNotEmpty) return wallets;
    if (walletAccountNumber == null) return const [];
    return [
      WalletAccountEntity(
        providerName: walletProviderName ?? '',
        accountNumber: walletAccountNumber!,
      ),
    ];
  }

  /// The number to chat with about a payment: invoices first, then support.
  String? get paymentWhatsapp => invoiceWhatsapp ?? supportWhatsapp;

  bool get hasInstructions => instructionsAr != null || instructionsEn != null;

  bool get isConfigured => hasBank || hasWallet || hasInstructions;

  String? bankName({required bool arabic}) =>
      arabic ? (bankNameAr ?? bankNameEn) : (bankNameEn ?? bankNameAr);

  String? instructions({required bool arabic}) =>
      arabic ? (instructionsAr ?? instructionsEn) : (instructionsEn ?? instructionsAr);

  @override
  List<Object?> get props => [
        bankNameAr,
        bankNameEn,
        accountHolder,
        accountNumber,
        iban,
        swiftCode,
        walletProviderName,
        walletAccountNumber,
        instructionsAr,
        instructionsEn,
        supportWhatsapp,
        invoiceWhatsapp,
        wallets,
        loadFailed,
      ];
}
