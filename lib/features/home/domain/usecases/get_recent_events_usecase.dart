import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recent_event_entity.dart';
import '../repositories/home_repository.dart';

class GetRecentEventsUseCase {
  final HomeRepository repository;

  GetRecentEventsUseCase(this.repository);

  Future<Either<Failure, List<RecentEventEntity>>> call() async {
    return await repository.getRecentEvents();
  }
}
