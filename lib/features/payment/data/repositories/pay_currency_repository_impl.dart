import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/pay_currency.dart';
import '../../domain/repositories/pay_currency_repository.dart';
import '../datasources/pay_currency_remote_data_source.dart';

class PayCurrencyRepositoryImpl implements PayCurrencyRepository {
  PayCurrencyRepositoryImpl({required this.remoteDataSource});

  final PayCurrencyRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, PayCurrencies>> currenciesFor(String eventId) =>
      guardCall(() => remoteDataSource.currenciesFor(eventId));
}
