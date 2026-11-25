import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/my_payments.dart';

abstract class MyPaymentsRepository {
  Future<Either<Failure, MyPayments>> getMyPayments();
}
