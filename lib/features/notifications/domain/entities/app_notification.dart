import 'package:equatable/equatable.dart';

/// One entry of the host's in-app inbox (GET /notifications).
class AppNotification extends Equatable {
  final int id;

  /// payment.approved / payment.rejected / guest.responded /
  /// image.completed / image.failed ...
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? createdAt;

  /// Who signed it. Every notification comes from the platform, so this is
  /// "Maktoob" (localized by the backend); the tile shows the Maktoob mark.
  final String senderName;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body = '',
    this.data = const {},
    this.isRead = false,
    this.createdAt,
    this.senderName = '',
  });

  String? get eventId {
    final v = data['event_id'];
    return (v == null || '$v'.isEmpty) ? null : '$v';
  }

  AppNotification markedRead() => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    data: data,
    isRead: true,
    createdAt: createdAt,
    senderName: senderName,
  );

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    body,
    data,
    isRead,
    createdAt,
    senderName,
  ];
}

class NotificationsPage extends Equatable {
  final List<AppNotification> items;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  const NotificationsPage({
    required this.items,
    required this.unreadCount,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, unreadCount, currentPage, lastPage];
}
