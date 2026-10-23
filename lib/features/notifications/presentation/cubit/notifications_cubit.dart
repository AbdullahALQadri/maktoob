import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase getNotifications;
  final MarkNotificationReadUseCase markReadUseCase;

  /// Bumped by every [load]; a [loadMore] that started before a reload
  /// drops its result instead of appending to the fresh list.
  int _generation = 0;

  NotificationsCubit({
    required this.getNotifications,
    required this.markReadUseCase,
  }) : super(NotificationsInitial());

  /// (Re)loads the first page.
  Future<void> load() async {
    final generation = ++_generation;
    if (state is! NotificationsLoaded) emit(NotificationsLoading());
    final result = await getNotifications();
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => emit(NotificationsError(f.message ?? '')),
      (page) => emit(
        NotificationsLoaded(
          items: page.items,
          unreadCount: page.unreadCount,
          currentPage: page.currentPage,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  /// Appends the next page. No-op while one is loading or when none is left.
  Future<void> loadMore() async {
    final s = state;
    if (s is! NotificationsLoaded || !s.hasMore || s.isLoadingMore) return;
    final generation = _generation;
    emit(s.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final nextPage = s.currentPage + 1;
    final result = await getNotifications(page: nextPage);
    if (isClosed || generation != _generation) return;
    final current = state;
    if (current is! NotificationsLoaded) return;
    result.fold(
      (_) => emit(current.copyWith(isLoadingMore: false, loadMoreFailed: true)),
      (page) {
        // New notifications shift the pages; skip ids already shown.
        final seen = {for (final n in current.items) n.id};
        emit(
          current.copyWith(
            items: [
              ...current.items,
              ...page.items.where((n) => !seen.contains(n.id)),
            ],
            // meta.unread_count is the server's total, not this page's.
            unreadCount: page.unreadCount,
            currentPage: nextPage,
            hasMore: nextPage < page.lastPage && page.items.isNotEmpty,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  /// Optimistic: flip locally, then tell the server.
  Future<void> markRead(int id) async {
    final s = state;
    if (s is! NotificationsLoaded) return;
    if (!s.items.any((n) => n.id == id && !n.isRead)) return;
    emit(
      s.copyWith(
        items: [for (final n in s.items) n.id == id ? n.markedRead() : n],
        unreadCount: s.unreadCount > 0 ? s.unreadCount - 1 : 0,
      ),
    );
    await markReadUseCase(id);
  }

  Future<void> markAllRead() async {
    final s = state;
    if (s is! NotificationsLoaded) return;
    emit(
      s.copyWith(
        items: [for (final n in s.items) n.markedRead()],
        unreadCount: 0,
      ),
    );
    await markReadUseCase(null);
  }
}
