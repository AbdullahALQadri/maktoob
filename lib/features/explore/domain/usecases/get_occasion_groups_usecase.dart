import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/occasion_group_entity.dart';
import '../repositories/explore_repository.dart';

class GetOccasionGroupsUseCase {
  final ExploreRepository repository;

  GetOccasionGroupsUseCase(this.repository);

  Future<Either<Failure, List<OccasionGroupEntity>>> call() =>
      repository.getOccasionGroups();
}
