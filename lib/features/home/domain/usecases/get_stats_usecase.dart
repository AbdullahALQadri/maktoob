import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/stat_entity.dart';
import '../repositories/home_repository.dart';

class GetStatsUseCase {
  final HomeRepository repository;

  GetStatsUseCase(this.repository);

  Future<Either<Failure, List<StatEntity>>> call() async {
    return await repository.getStats();
  }
}
