import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/recent_event_entity.dart';
import '../../domain/entities/stat_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/recent_event_model.dart';
import '../models/stat_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<StatEntity>>> getStats() async {
    try {
      final remoteStats = await remoteDataSource.getStats();
      await localDataSource.cacheStats(remoteStats);
      return Right(remoteStats);
    } catch (e) {
      try {
        final cachedStats = await localDataSource.getCachedStats();
        if (cachedStats.isNotEmpty) {
          return Right(cachedStats);
        }
        return Left(CacheFailure('No cached stats available'));
      } catch (cacheError) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<RecentEventEntity>>> getRecentEvents() async {
    try {
      final remoteEvents = await remoteDataSource.getRecentEvents();
      await localDataSource.cacheRecentEvents(remoteEvents);
      return Right(remoteEvents);
    } catch (e) {
      try {
        final cachedEvents = await localDataSource.getCachedRecentEvents();
        if (cachedEvents.isNotEmpty) {
          return Right(cachedEvents);
        }
        return Left(CacheFailure('No cached events available'));
      } catch (cacheError) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}
