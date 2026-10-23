import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../domain/entities/app_notification.dart';
import '../models/app_notification_model.dart';

abstract class NotificationsRemoteDataSource {
  /// GET /notifications (`ApiResponse::paginated`, at most 100 per page).
  Future<NotificationsPage> getNotifications({int page = 1});
  Future<void> markRead(int id);
  Future<void> markAllRead();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiConsumer apiConsumer;
  NotificationsRemoteDataSourceImpl({required this.apiConsumer});

  static const perPage = 50;

  @override
  Future<NotificationsPage> getNotifications({int page = 1}) async {
    final response = await apiConsumer.get(
      Endpoints.notifications,
      queryParameters: {'per_page': perPage, 'page': page},
    );
    return AppNotificationModel.pageFromJson(response);
  }

  @override
  Future<void> markRead(int id) async {
    await apiConsumer.post(Endpoints.notificationRead(id));
  }

  @override
  Future<void> markAllRead() async {
    await apiConsumer.post(Endpoints.notificationsReadAll);
  }
}
