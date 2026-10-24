import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.remoteDataSource});

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, HomeSummary>> getHome() => guardCall(remoteDataSource.getHome);
}
