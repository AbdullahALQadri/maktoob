import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository repository;
  MarkNotificationReadUseCase(this.repository);

  /// [id] null marks everything read.
  Future<Either<Failure, Unit>> call(int? id) =>
      id == null ? repository.markAllRead() : repository.markRead(id);
}
