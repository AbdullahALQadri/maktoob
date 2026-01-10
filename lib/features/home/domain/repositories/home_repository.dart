import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/recent_event_entity.dart';
import '../entities/stat_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<StatEntity>>> getStats();
  Future<Either<Failure, List<RecentEventEntity>>> getRecentEvents();
}
