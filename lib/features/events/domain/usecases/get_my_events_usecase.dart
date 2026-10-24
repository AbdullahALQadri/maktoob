import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_entity.dart';
import '../entities/event_page.dart';
import '../repositories/my_events_repository.dart';

class GetMyEventsUseCase {
  const GetMyEventsUseCase(this.repository);

  final MyEventsRepository repository;

  Future<Either<Failure, EventPage>> call({EventStatus? status, String query = '', int page = 1}) =>
      repository.getPage(status: status, query: query.trim(), page: page);
}
