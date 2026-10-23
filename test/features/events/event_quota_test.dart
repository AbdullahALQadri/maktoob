import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/events/data/models/event_model.dart';

void main() {
  group('EventModel invitation quota', () {
    test('package pivot total wins over max_invitations; remaining = limit - used', () {
      final e = EventModel.fromJson({
        'id': 1,
        'status': 'active',
        'max_invitations': 10,
        'invitations_used': 7,
        'packages': [
          {'id': 3, 'pivot': {'invitations_included': 50}},
          {'id': 4, 'pivot': {'invitations_included': '25'}},
        ],
      });
      expect(e.invitationLimit, 75);
      expect(e.remainingInvitations, 68);
      // invitations_used is the capacity ledger, never door check-ins.
      expect(e.checkedIn, 0);
    });

    test('falls back to max_invitations and clamps at zero', () {
      final e = EventModel.fromJson({'id': 1, 'max_invitations': 5, 'invitations_used': 9});
      expect(e.invitationLimit, 5);
      expect(e.remainingInvitations, 0);
    });

    test('no limit configured means unlimited (null)', () {
      final e = EventModel.fromJson({'id': 1, 'max_invitations': null});
      expect(e.invitationLimit, isNull);
      expect(e.remainingInvitations, isNull);
    });

    test('server remaining_invitations is used as sent', () {
      final e = EventModel.fromJson({'id': 1, 'max_invitations': 20, 'invitations_used': 2, 'remaining_invitations': 4});
      expect(e.remainingInvitations, 4);
    });
  });
}
