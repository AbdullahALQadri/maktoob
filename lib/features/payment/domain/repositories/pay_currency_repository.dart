import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pay_currency.dart';

abstract class PayCurrencyRepository {
  /// The currencies an event can be paid in, each already quoted.
  Future<Either<Failure, PayCurrencies>> currenciesFor(String eventId);
}
