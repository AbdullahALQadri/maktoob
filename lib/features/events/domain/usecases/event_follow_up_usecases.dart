import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event_follow_up.dart';
import '../repositories/event_follow_up_repository.dart';

/// What the event page shows about an event: its setup steps and activity.
class GetEventFollowUpUseCase {
  const GetEventFollowUpUseCase(this.repository);

  final EventFollowUpRepository repository;

  Future<Either<Failure, EventProgress>> progress(String eventId) => repository.progress(eventId);

  Future<Either<Failure, List<ActivityItem>>> activity(String eventId) => repository.activity(eventId);
}

class ResendFailedInvitationsUseCase {
  const ResendFailedInvitationsUseCase(this.repository);

  final EventFollowUpRepository repository;

  Future<Either<Failure, int>> call(String eventId) => repository.resendFailed(eventId);
}

class UpdateUnsentGuestUseCase {
  const UpdateUnsentGuestUseCase(this.repository);

  final EventFollowUpRepository repository;

  Future<Either<Failure, Unit>> call(
    String eventId,
    String invitationId, {
    required String name,
    required String phone,
  }) => repository.updateUnsentGuest(eventId, invitationId, name: name.trim(), phone: phone.trim());
}
