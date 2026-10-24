import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/event_follow_up.dart';
import '../../domain/repositories/event_follow_up_repository.dart';
import '../datasources/event_follow_up_remote_data_source.dart';

class EventFollowUpRepositoryImpl implements EventFollowUpRepository {
  const EventFollowUpRepositoryImpl({required this.remoteDataSource});

  final EventFollowUpRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<ActivityItem>>> activity(String eventId) =>
      guardCall(() => remoteDataSource.activity(eventId));

  @override
  Future<Either<Failure, EventProgress>> progress(String eventId) =>
      guardCall(() => remoteDataSource.progress(eventId));

  @override
  Future<Either<Failure, int>> resendFailed(String eventId) => guardCall(() => remoteDataSource.resendFailed(eventId));

  @override
  Future<Either<Failure, Unit>> updateUnsentGuest(
    String eventId,
    String invitationId, {
    required String name,
    required String phone,
  }) => guardCall(() async {
    await remoteDataSource.updateUnsentGuest(eventId, invitationId, name: name, phone: phone);
    return unit;
  });
}
