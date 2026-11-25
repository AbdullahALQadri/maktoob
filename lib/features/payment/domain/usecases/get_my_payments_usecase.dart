import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/my_payments.dart';
import '../repositories/my_payments_repository.dart';

class GetMyPaymentsUseCase implements UseCase<MyPayments, NoParams> {
  final MyPaymentsRepository repository;

  GetMyPaymentsUseCase(this.repository);

  @override
  Future<Either<Failure, MyPayments>> call(NoParams params) => repository.getMyPayments();
}
