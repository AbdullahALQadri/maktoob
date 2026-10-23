import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsPage>> getNotifications({int page = 1});
  Future<Either<Failure, Unit>> markRead(int id);
  Future<Either<Failure, Unit>> markAllRead();
}
