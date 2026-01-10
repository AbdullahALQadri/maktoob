import 'package:equatable/equatable.dart';

class BankDetailsEntity extends Equatable {
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String iban;
  final String swiftCode;

  const BankDetailsEntity({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.iban,
    required this.swiftCode,
  });

  @override
  List<Object?> get props => [
        bankName,
        accountName,
        accountNumber,
        iban,
        swiftCode,
      ];
}
