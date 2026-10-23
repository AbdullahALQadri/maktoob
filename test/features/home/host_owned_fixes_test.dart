import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/core/utils/phone_normalizer.dart';
import 'package:maktoob/features/events/data/models/guest_model.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/events/domain/entities/guest_entity.dart';
import 'package:maktoob/features/events/presentation/widgets/guest_invitation_sheet.dart';
import 'package:maktoob/features/home/presentation/widgets/event_search_delegate.dart';
import 'package:maktoob/features/notifications/data/models/app_notification_model.dart';
import 'package:maktoob/features/notifications/domain/entities/app_notification.dart';
import 'package:maktoob/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:maktoob/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:maktoob/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:maktoob/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:maktoob/features/notifications/presentation/cubit/notifications_state.dart';

EventEntity _event(String id, String name, {String venue = '', String type = ''}) =>
    EventEntity(
      id: id,
      name: name,
      type: type,
      date: '2026-11-01',
      time: '19:00',
      venue: venue,
      invitations: 0,
      responses: 0,
      attending: 0,
      status: EventStatus.active,
    );

class _FakeRepo implements NotificationsRepository {
  final List<int?> marked = [];
  @override
  Future<Either<Failure, NotificationsPage>> getNotifications({int page = 1}) async => const Right(
        NotificationsPage(items: [
          AppNotification(id: 1, type: 'payment.approved', title: 'a'),
          AppNotification(id: 2, type: 'guest.responded', title: 'b', isRead: true),
          AppNotification(id: 3, type: 'image.completed', title: 'c'),
        ], unreadCount: 2),
      );
  @override
  Future<Either<Failure, Unit>> markRead(int id) async {
    marked.add(id);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() async {
    marked.add(null);
    return const Right(unit);
  }
}

void main() {
  group('contacts: Palestinian numbers in any local format are accepted', () {
    for (final raw in ['059-912-3456', '0569 123 456', '+970 59 912 3456', '00972599123456', '972599123456']) {
      test(raw, () => expect(PhoneNormalizer.isValidPalestinian(raw), isTrue));
    }
    test('local 059 normalizes to +970', () {
      expect(PhoneNormalizer.normalize('0599 123 456'), '+970599123456');
    });
    test('landline-short / foreign rejected', () {
      expect(PhoneNormalizer.isValidPalestinian('+44 20 7946 0958'), isFalse);
      expect(PhoneNormalizer.isValidPalestinian('123'), isFalse);
    });
  });

  group('GuestModel parses the invitations list resource', () {
    final json = {
      'id': 7,
      'display_name': 'Ahmad',
      'status': 'opened',
      'response_status': 'attending',
      'companions_count': 2,
      'is_checked_in': true,
      'sent_at': '2026-10-01T10:00:00.000000Z',
      'opened_at': '2026-10-01T11:00:00.000000Z',
      'responded_at': '2026-10-01T12:00:00.000000Z',
      'checked_in_at': '2026-11-01T19:05:00.000000Z',
      'invitation_url': 'https://maktoob.social/i/abc123',
      'guest': {'id': 3, 'name': 'Ahmad', 'phone': '+970599123456', 'email': null},
    };

    test('uses response_status, companions_count and link fields', () {
      final g = GuestModel.fromJson(json);
      expect(g.status, GuestStatus.attending);
      expect(g.companions, 2);
      expect(g.isCheckedIn, isTrue);
      expect(g.invitationUrl, 'https://maktoob.social/i/abc123');
      expect(g.invitationStatus, 'opened');
      expect(g.checkedInAt, isNotNull);
    });

    test('not_attending maps to declined; no_response to pending', () {
      expect(GuestModel.fromJson({...json, 'response_status': 'not_attending'}).status,
          GuestStatus.declined);
      expect(GuestModel.fromJson({...json, 'response_status': 'no_response'}).status,
          GuestStatus.pending);
    });

    test('sheet timeline reflects reached steps', () {
      final g = GuestModel.fromJson({...json, 'checked_in_at': null});
      final rows = GuestInvitationSheet.timeline(g);
      expect(rows.map((r) => r.$2 != null), [true, true, true, false]);
    });
  });

  group('home search', () {
    final events = [
      _event('1', 'حفل زفاف أحمد', venue: 'قاعة الأمل'),
      _event('2', 'Graduation party', venue: 'Gaza hall'),
      _event('3', 'عيد ميلاد سارة'),
    ];

    test('empty query returns all', () => expect(searchEventList(events, '  '), events));
    test('matches name ignoring alef/hamza forms', () {
      expect(searchEventList(events, 'احمد').map((e) => e.id), ['1']);
    });
    test('matches venue, case-insensitive, all terms required', () {
      expect(searchEventList(events, 'gaza GRAD').map((e) => e.id), ['2']);
      expect(searchEventList(events, 'gaza زفاف'), isEmpty);
    });
    test('taa marbuta / haa are equivalent', () {
      expect(searchEventList(events, 'ساره').map((e) => e.id), ['3']);
    });
  });

  group('notifications', () {
    test('page parser reads data[] and meta.unread_count', () {
      final page = AppNotificationModel.pageFromJson({
        'success': true,
        'data': [
          {'id': 5, 'type': 'payment.rejected', 'title': 't', 'body': 'b', 'data': {'event_id': '9'}, 'is_read': false, 'created_at': '2026-10-10T10:00:00Z'},
        ],
        'meta': {'unread_count': 4},
      });
      expect(page.unreadCount, 4);
      expect(page.items.single.eventId, '9');
      expect(page.items.single.isRead, isFalse);
    });

    test('cubit loads, marks one and all read', () async {
      final repo = _FakeRepo();
      final cubit = NotificationsCubit(
        getNotifications: GetNotificationsUseCase(repo),
        markReadUseCase: MarkNotificationReadUseCase(repo),
      );
      await cubit.load();
      expect((cubit.state as NotificationsLoaded).unreadCount, 2);

      await cubit.markRead(1);
      var s = cubit.state as NotificationsLoaded;
      expect(s.unreadCount, 1);
      expect(s.items.first.isRead, isTrue);

      await cubit.markRead(2); // already read: no server call
      await cubit.markAllRead();
      s = cubit.state as NotificationsLoaded;
      expect(s.unreadCount, 0);
      expect(s.items.every((n) => n.isRead), isTrue);
      expect(repo.marked, [1, null]);
      await cubit.close();
    });
  });
}
