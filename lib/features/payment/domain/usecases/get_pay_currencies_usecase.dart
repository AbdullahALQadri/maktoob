import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/pay_currency.dart';
import '../repositories/pay_currency_repository.dart';

class GetPayCurrenciesUseCase implements UseCase<PayCurrencies, String> {
  GetPayCurrenciesUseCase(this.repository);

  final PayCurrencyRepository repository;

  @override
  Future<Either<Failure, PayCurrencies>> call(String eventId) => repository.currenciesFor(eventId);
}
