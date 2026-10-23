import '../../../../core/api/paginated_fetch.dart';
import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    super.body,
    super.data,
    super.isRead,
    super.createdAt,
    super.senderName,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final data = json['data'];
    final sender = json['sender'];
    return AppNotificationModel(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: data is Map ? Map<String, dynamic>.from(data) : const {},
      isRead: json['is_read'] as bool? ?? json['read_at'] != null,
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at'] as String)?.toLocal()
          : null,
      senderName: sender is Map ? '${sender['name'] ?? ''}' : '',
    );
  }

  /// Parses `{success, data:[...], meta:{current_page, last_page, unread_count}}`.
  static NotificationsPage pageFromJson(dynamic response) {
    final map = response is Map ? response : const {};
    final list = map['data'] is List ? map['data'] as List : const [];
    final items = list
        .whereType<Map>()
        .map((e) => AppNotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final meta = map['meta'];
    final unread = meta is Map && meta['unread_count'] is num
        ? (meta['unread_count'] as num).toInt()
        : items.where((n) => !n.isRead).length;
    final current = Pagination.currentPageOf(map) ?? 1;
    return NotificationsPage(
      items: items,
      unreadCount: unread,
      currentPage: current,
      lastPage: Pagination.lastPageOf(map) ?? current,
    );
  }
}
