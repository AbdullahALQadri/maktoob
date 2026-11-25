import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bank_details_entity.dart';
import '../repositories/payment_repository.dart';

class GetBankDetailsUseCase implements UseCase<BankDetailsEntity, String?> {
  final PaymentRepository repository;

  GetBankDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, BankDetailsEntity>> call(String? currency) async {
    return await repository.getBankDetails(currency: currency);
  }
}
