import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_follow_up.dart';

abstract class EventFollowUpRepository {
  Future<Either<Failure, List<ActivityItem>>> activity(String eventId);

  Future<Either<Failure, EventProgress>> progress(String eventId);

  /// Resends every invitation that did not arrive; returns how many went out.
  Future<Either<Failure, int>> resendFailed(String eventId);

  /// Fixes the name or number of a guest whose invitation was not sent yet.
  Future<Either<Failure, Unit>> updateUnsentGuest(
    String eventId,
    String invitationId, {
    required String name,
    required String phone,
  });
}
