import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/events/data/models/event_follow_up_models.dart';
import 'package:maktoob/features/events/domain/entities/event_card.dart';

/// The event page's follow-up answers as the backend sends them
/// (EventFollowUpController).
void main() {
  test('reads the activity feed', () {
    final items = ActivityItemModel.listFrom({
      'success': true,
      'data': [
        {
          'invitation_id': 4,
          'type': 'replied',
          'reply': 'attending',
          'name': 'ليلى',
          'companions': 2,
          'at': '2026-10-24T14:10:00+02:00',
        },
        {'invitation_id': 5, 'type': 'opened', 'reply': null, 'name': 'نور', 'companions': 0, 'at': null},
      ],
    });

    expect(items, hasLength(2));
    expect(items.first.replied, isTrue);
    expect(items.first.reply, 'attending');
    expect(items.first.at, DateTime(2026, 10, 24, 14, 10));
    expect(items.last.replied, isFalse);
    expect(items.last.at, isNull);
  });

  test('reads the setup steps and the next action', () {
    final progress = EventProgressModel.fromResponse({
      'data': {
        'in_setup': true,
        'next_action': {'key': 'add_guests', 'step': 'guests'},
        'steps': [
          {'key': 'details', 'done': true, 'current': false},
          {'key': 'guests', 'done': false, 'current': true},
        ],
      },
    });

    expect(progress.inSetup, isTrue);
    expect(progress.nextAction, NextAction.addGuests);
    expect(progress.steps.map((s) => s.key), ['details', 'guests']);
    expect(progress.steps.last.current, isTrue);
  });
}
