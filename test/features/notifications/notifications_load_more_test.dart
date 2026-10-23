import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/notifications/data/models/app_notification_model.dart';
import 'package:maktoob/features/notifications/domain/entities/app_notification.dart';
import 'package:maktoob/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:maktoob/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:maktoob/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:maktoob/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:maktoob/features/notifications/presentation/cubit/notifications_state.dart';

class _PagedRepo implements NotificationsRepository {
  final requested = <int>[];
  bool failNext = false;

  @override
  Future<Either<Failure, NotificationsPage>> getNotifications({int page = 1}) async {
    requested.add(page);
    if (failNext) {
      failNext = false;
      return const Left(ServerFailure(message: 'x'));
    }
    return Right(NotificationsPage(
      items: [
        AppNotification(id: page * 10, type: 't', title: 'p$page'),
        // Overlaps the previous page (new rows shifted it).
        if (page > 1) AppNotification(id: (page - 1) * 10, type: 't', title: 'dup'),
      ],
      unreadCount: 7 - page,
      currentPage: page,
      lastPage: 3,
    ));
  }

  @override
  Future<Either<Failure, Unit>> markRead(int id) async => const Right(unit);
  @override
  Future<Either<Failure, Unit>> markAllRead() async => const Right(unit);
}

void main() {
  test('page parser reads current_page / last_page from meta', () {
    final page = AppNotificationModel.pageFromJson({
      'success': true,
      'data': [],
      'meta': {'current_page': 2, 'last_page': 5, 'unread_count': 1},
    });
    expect(page.currentPage, 2);
    expect(page.lastPage, 5);
    expect(page.hasMore, isTrue);
  });

  test('loadMore appends pages, dedupes, follows server unread, stops at last', () async {
    final repo = _PagedRepo();
    final cubit = NotificationsCubit(
      getNotifications: GetNotificationsUseCase(repo),
      markReadUseCase: MarkNotificationReadUseCase(repo),
    );
    await cubit.load();
    var s = cubit.state as NotificationsLoaded;
    expect(s.items.map((n) => n.id), [10]);
    expect(s.hasMore, isTrue);
    expect(s.unreadCount, 6);

    await cubit.loadMore();
    s = cubit.state as NotificationsLoaded;
    expect(s.items.map((n) => n.id), [10, 20]);
    expect(s.unreadCount, 5);

    repo.failNext = true;
    await cubit.loadMore();
    s = cubit.state as NotificationsLoaded;
    expect(s.loadMoreFailed, isTrue);
    expect(s.items.length, 2);

    await cubit.loadMore(); // retry
    s = cubit.state as NotificationsLoaded;
    expect(s.items.map((n) => n.id), [10, 20, 30]);
    expect(s.hasMore, isFalse);
    expect(s.loadMoreFailed, isFalse);

    await cubit.loadMore(); // nothing left
    expect(repo.requested, [1, 2, 3, 3]);

    // markRead keeps the paging state.
    await cubit.markRead(30);
    s = cubit.state as NotificationsLoaded;
    expect(s.currentPage, 3);
    expect(s.unreadCount, 3);
    await cubit.close();
  });
}
