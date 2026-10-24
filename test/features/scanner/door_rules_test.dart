import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/scanner/domain/entities/door_entities.dart';
import 'package:maktoob/features/scanner/domain/logic/door_rules.dart';

/// The rules an offline door applies (same as CheckInService on the server).
void main() {
  final day = DateTime.utc(2026, 11, 5, 15);
  DoorEventInfo event({String status = 'active'}) => DoorEventInfo(
    id: 1,
    title: 'Wedding',
    status: status,
    validFrom: DateTime.utc(2026, 11, 4, 22), // 00:00 Gaza
    validUntil: DateTime.utc(2026, 11, 5, 21, 59, 59),
  );

  test('only active / completed events admit', () {
    expect(DoorRules.eventBlocker(event(), day), isNull);
    expect(DoorRules.eventBlocker(event(status: 'completed'), day), isNull);
    for (final s in ['draft', 'pending_payment', 'cancelled']) {
      expect(DoorRules.eventBlocker(event(status: s), day), DoorRules.eventNotActive);
    }
  });

  test('the QR is valid on the event day only', () {
    expect(DoorRules.eventBlocker(event(), DateTime.utc(2026, 11, 4, 21)), DoorRules.notYetValid);
    expect(DoorRules.eventBlocker(event(), DateTime.utc(2026, 11, 5, 22, 30)), DoorRules.expired);
    // No date window on an undated event.
    expect(DoorRules.eventBlocker(const DoorEventInfo(id: 1, title: '', status: 'active'), day), isNull);
  });

  test('companions up to the maximum; no maximum means no limit', () {
    expect(DoorRules.companionsBlocker(2, 2), isNull);
    expect(DoorRules.companionsBlocker(3, 2), DoorRules.tooManyCompanions);
    expect(DoorRules.companionsBlocker(9, null), isNull);
  });

  test('warnings never refuse: declined, wrong gate, unlisted', () {
    const woman = DoorGuest(id: 1, name: 'سارة', gender: 'female', rsvp: 'not_attending');
    const men = DoorGate(id: 1, name: 'رجال ١', audience: 'men');
    const all = DoorGate(id: 2, name: 'رئيسية');

    expect(DoorRules.warnings(guest: woman, gate: men), [DoorRules.warnDeclined, DoorRules.warnWrongGate]);
    expect(DoorRules.warnings(guest: woman, gate: all), [DoorRules.warnDeclined]);
    expect(DoorRules.warnings(guest: const DoorGuest(id: 2, name: ''), unlisted: true), [DoorRules.warnUnlisted]);
    // Unknown gender never warns.
    expect(
      DoorRules.warnings(
        guest: const DoorGuest(id: 3, name: 'x'),
        gate: men,
      ),
      isEmpty,
    );
  });
}
