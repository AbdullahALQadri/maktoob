import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/venue_entity.dart';
import '../repositories/venues_repository.dart';

/// Use case for searching venues by query
class SearchVenuesUseCase extends UseCase<List<VenueEntity>, SearchVenuesParams> {
  final VenuesRepository repository;

  SearchVenuesUseCase(this.repository);

  @override
  Future<Either<Failure, List<VenueEntity>>> call(SearchVenuesParams params) async {
    return await repository.searchVenues(params.query);
  }
}

/// Parameters for searching venues
class SearchVenuesParams extends Equatable {
  final String query;

  const SearchVenuesParams({required this.query});

  @override
  List<Object?> get props => [query];
}
