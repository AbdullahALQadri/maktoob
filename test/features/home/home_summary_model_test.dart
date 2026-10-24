import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';
import 'package:maktoob/features/home/data/models/home_summary_model.dart';
import 'package:maktoob/features/events/domain/entities/event_card.dart';

/// `GET /client/home` as the backend sends it (ClientHomeController).
Map<String, dynamic> _response({Map<String, dynamic>? offline}) => {
      'success': true,
      'message': 'Success',
      'data': {
        'totals': {'events': 4, 'active_events': 1, 'invitations': 4, 'responses': 1, 'response_rate': 25},
        'next_event': {
          'id': 7,
          'title': 'حفل زفاف أحمد وليلى',
          'status': 'draft',
          'event_type': {'id': 1, 'name_ar': 'زفاف', 'name_en': 'Wedding'},
          'event_date': '2026-10-29T19:00:00+03:00',
          'image_url': null,
          'invitations_count': 0,
          'opened_count': 0,
          'responded_count': 0,
          'countdown_days': 5,
          'next_action': {'key': 'choose_design', 'step': 'design'},
          'step_number': 3,
          'steps_total': 6,
          'my_role': 'owner',
        },
        'events': [
          {
            'id': 9,
            'title': 'تخريج دفعة 2026',
            'status': 'active',
            'event_date': '2026-11-15T10:00:00+02:00',
            'image_url': 'https://example.test/i.jpg',
            'invitations_count': 600,
            'opened_count': 520,
            'responded_count': 410,
            'countdown_days': 22,
            'next_action': {'key': 'view_results', 'step': 'send'},
            'step_number': null,
            'my_role': 'manager',
          },
        ],
        'free_trial_available': true,
        'now': '2026-10-24T15:00:00+02:00',
      },
      if (offline != null) '_offline': offline,
    };

void main() {
  test('reads the numbers, the spotlight and the cards', () {
    final home = HomeSummaryModel.fromResponse(_response());

    expect(home.totals.events, 4);
    expect(home.totals.responseRate, 25);
    expect(home.freeTrialAvailable, isTrue);
    expect(home.gazaOffset, const Duration(hours: 2));
    expect(home.isSavedCopy, isFalse);
    expect(home.isFirstVisit, isFalse);

    final next = home.nextEvent!;
    expect(next.status, EventStatus.draft);
    expect(next.nextAction, NextAction.chooseDesign);
    expect(next.stepNumber, 3);
    expect(next.inSetup, isTrue);
    expect(next.date, DateTime(2026, 10, 29, 19));
    expect(next.typeName('ar'), 'زفاف');
    expect(next.typeName('en'), 'Wedding');
    expect(next.imageUrl, isNull);

    final card = home.events.single;
    expect(card.role, EventRole.manager);
    expect(card.inSetup, isFalse);
    expect(card.responseShare, closeTo(410 / 600, 1e-9));
  });

  test('marks the last saved copy served while offline', () {
    final home = HomeSummaryModel.fromResponse(_response(offline: {'age_seconds': 300}));
    expect(home.isSavedCopy, isTrue);
    expect(home.savedAgo, const Duration(minutes: 5));
  });

  test('a new client with nothing yet gets an empty, valid home', () {
    final home = HomeSummaryModel.fromResponse({'data': {'totals': {}, 'next_event': null, 'events': []}});
    expect(home.isFirstVisit, isTrue);
    expect(home.nextEvent, isNull);
    expect(home.events, isEmpty);
    expect(home.freeTrialAvailable, isFalse);
  });

  test('unknown next-action keys fall back to the results view', () {
    expect(NextAction.fromKey('something_new'), NextAction.viewResults);
    expect(NextAction.fromKey('track_payment'), NextAction.trackPayment);
  });
}
