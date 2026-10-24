import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_entity.dart';
import '../entities/event_page.dart';

abstract class MyEventsRepository {
  /// The events the host may view, newest first, optionally one status and a
  /// title search. Offline it is the last saved copy of the same page.
  Future<Either<Failure, EventPage>> getPage({EventStatus? status, String query = '', int page = 1});
}
