import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/repositories/venues_repository.dart';
import '../datasources/venues_local_data_source.dart';
import '../datasources/venues_remote_data_source.dart';
import '../models/venue_model.dart';

/// Implementation of VenuesRepository
class VenuesRepositoryImpl implements VenuesRepository {
  final VenuesRemoteDataSource remoteDataSource;
  final VenuesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  VenuesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<VenueEntity>>> getVenues() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteVenues = await remoteDataSource.getVenues();
        await localDataSource.cacheVenues(remoteVenues);
        return Right(remoteVenues.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localVenues = await localDataSource.getCachedVenues();
        return Right(localVenues.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, VenueEntity>> addVenue(VenueEntity venue) async {
    try {
      final venueModel = VenueModel.fromEntity(venue);
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.addVenue(venueModel);
        await localDataSource.addVenueToCache(result);
        return Right(result.toEntity());
      } else {
        final result = await localDataSource.addVenueToCache(venueModel);
        return Right(result.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<VenueEntity>>> searchVenues(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final results = await remoteDataSource.searchVenues(query);
        return Right(results.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localVenues = await localDataSource.getCachedVenues();
        if (query.isEmpty) {
          return Right(localVenues.map((model) => model.toEntity()).toList());
        }
        final lowerQuery = query.toLowerCase();
        final filtered = localVenues.where((venue) {
          return venue.name.toLowerCase().contains(lowerQuery) ||
              venue.address.toLowerCase().contains(lowerQuery) ||
              venue.email.toLowerCase().contains(lowerQuery);
        }).toList();
        return Right(filtered.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, VenueEntity>> getVenueById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getVenueById(id);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localVenues = await localDataSource.getCachedVenues();
        final venue = localVenues.firstWhere(
          (v) => v.id == id,
          orElse: () => throw const CacheException(message: 'Venue not found in cache'),
        );
        return Right(venue.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, VenueEntity>> updateVenue(VenueEntity venue) async {
    try {
      final venueModel = VenueModel.fromEntity(venue);
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.updateVenue(venueModel);
        return Right(result.toEntity());
      } else {
        return Left(const ServerFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVenue(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteVenue(id);
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(const ServerFailure('No internet connection'));
    }
  }
}
