import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event_entity.dart';
import '../repositories/events_repository.dart';

class FilterEventsUseCase
    implements UseCase<List<EventEntity>, FilterEventsParams> {
  final EventsRepository repository;

  FilterEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<EventEntity>>> call(
      FilterEventsParams params) async {
    return await repository.filterEvents(
      searchQuery: params.searchQuery,
      status: params.status,
    );
  }
}

class FilterEventsParams extends Equatable {
  final String? searchQuery;
  final EventStatus? status;

  const FilterEventsParams({
    this.searchQuery,
    this.status,
  });

  @override
  List<Object?> get props => [searchQuery, status];
}
