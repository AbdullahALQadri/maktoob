import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/occasion_group_entity.dart';
import '../../domain/entities/template_preview_entity.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_data_source.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource remoteDataSource;

  ExploreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OccasionGroupEntity>>> getOccasionGroups() =>
      _guard(remoteDataSource.getOccasionGroups);

  @override
  Future<Either<Failure, List<TemplatePreviewEntity>>> getTemplates({
    int? eventTypeId,
  }) =>
      _guard(() => remoteDataSource.getTemplates(eventTypeId: eventTypeId));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
