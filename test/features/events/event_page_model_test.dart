import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/events/data/models/event_page_model.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';

/// `GET /client/events` as the backend sends it (ClientEventListController).
void main() {
  test('reads the cards, the page and a count per status', () {
    final page = EventPageModel.fromResponse({
      'success': true,
      'data': [
        {
          'id': 3,
          'title': 'عقيقة آدم',
          'status': 'draft',
          'step_number': 2,
          'next_action': {'key': 'add_guests'},
        },
      ],
      'meta': {'current_page': 1, 'last_page': 3, 'per_page': 20, 'total': 41},
      'counts': {'all': 41, 'draft': 2, 'pending_payment': 1, 'active': 30, 'completed': 8, 'cancelled': 0},
    });

    expect(page.items.single.title, 'عقيقة آدم');
    expect(page.items.single.inSetup, isTrue);
    expect(page.hasMore, isTrue);
    expect(page.counts.of(null), 41);
    expect(page.counts.of(EventStatus.pendingPayment), 1);
    expect(page.counts.of(EventStatus.cancelled), 0);
    expect(page.savedAgo, isNull);
  });

  test('marks the last saved copy and tolerates missing parts', () {
    final page = EventPageModel.fromResponse({
      'data': [],
      '_offline': {'age_seconds': 90},
    });
    expect(page.items, isEmpty);
    expect(page.hasMore, isFalse);
    expect(page.counts.of(null), 0);
    expect(page.savedAgo, const Duration(seconds: 90));
  });
}
