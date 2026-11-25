import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/my_payments.dart';
import '../../domain/repositories/my_payments_repository.dart';
import '../datasources/my_payments_remote_data_source.dart';

class MyPaymentsRepositoryImpl implements MyPaymentsRepository {
  final MyPaymentsRemoteDataSource remoteDataSource;

  MyPaymentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MyPayments>> getMyPayments() => guardCall(remoteDataSource.getMyPayments);
}
