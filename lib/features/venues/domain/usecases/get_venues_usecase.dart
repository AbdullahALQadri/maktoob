import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/venue_entity.dart';
import '../repositories/venues_repository.dart';

/// Use case for fetching all venues
class GetVenuesUseCase extends UseCase<List<VenueEntity>, NoParams> {
  final VenuesRepository repository;

  GetVenuesUseCase(this.repository);

  @override
  Future<Either<Failure, List<VenueEntity>>> call(NoParams params) async {
    return await repository.getVenues();
  }
}
