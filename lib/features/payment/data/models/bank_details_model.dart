import '../../domain/entities/bank_details_entity.dart';

class BankDetailsModel extends BankDetailsEntity {
  const BankDetailsModel({
    required super.bankName,
    required super.accountName,
    required super.accountNumber,
    required super.iban,
    required super.swiftCode,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      bankName: json['bank_name'] as String,
      accountName: json['account_name'] as String,
      accountNumber: json['account_number'] as String,
      iban: json['iban'] as String,
      swiftCode: json['swift_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
      'iban': iban,
      'swift_code': swiftCode,
    };
  }

  BankDetailsModel copyWith({
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? iban,
    String? swiftCode,
  }) {
    return BankDetailsModel(
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      swiftCode: swiftCode ?? this.swiftCode,
    );
  }
}
