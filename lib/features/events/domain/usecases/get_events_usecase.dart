import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event_entity.dart';
import '../repositories/events_repository.dart';

class GetEventsUseCase implements UseCase<List<EventEntity>, NoParams> {
  final EventsRepository repository;

  GetEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<EventEntity>>> call(NoParams params) async {
    return await repository.getEvents();
  }
}
