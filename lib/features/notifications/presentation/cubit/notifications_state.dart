import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> items;
  final int unreadCount;

  /// The last page appended to [items].
  final int currentPage;

  /// More pages exist on the server (scroll to the end to load them).
  final bool hasMore;
  final bool isLoadingMore;

  /// The last load-more failed; the list footer offers a retry.
  final bool loadMoreFailed;

  const NotificationsLoaded({
    required this.items,
    required this.unreadCount,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  NotificationsLoaded copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) => NotificationsLoaded(
    items: items ?? this.items,
    unreadCount: unreadCount ?? this.unreadCount,
    currentPage: currentPage ?? this.currentPage,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );

  @override
  List<Object?> get props => [
    items,
    unreadCount,
    currentPage,
    hasMore,
    isLoadingMore,
    loadMoreFailed,
  ];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
  @override
  List<Object?> get props => [message];
}
