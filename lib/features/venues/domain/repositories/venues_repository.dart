import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/venue_entity.dart';

/// Abstract repository interface for Venues feature
abstract class VenuesRepository {
  /// Gets all venues from the data source
  Future<Either<Failure, List<VenueEntity>>> getVenues();

  /// Adds a new venue
  Future<Either<Failure, VenueEntity>> addVenue(VenueEntity venue);

  /// Searches venues by query string
  Future<Either<Failure, List<VenueEntity>>> searchVenues(String query);

  /// Gets a single venue by id
  Future<Either<Failure, VenueEntity>> getVenueById(String id);

  /// Updates an existing venue
  Future<Either<Failure, VenueEntity>> updateVenue(VenueEntity venue);

  /// Deletes a venue by id
  Future<Either<Failure, Unit>> deleteVenue(String id);
}
