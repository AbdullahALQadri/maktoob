import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/services/pending_wizard_intent_service.dart';

void main() {
  test('an intent is consumed exactly once', () {
    final s = PendingWizardIntentService();
    expect(s.consume(), isNull);

    s.set(const PendingWizardIntent(eventTypeId: 3, templateId: 41));
    expect(s.hasPending, isTrue);

    final got = s.consume();
    expect(got?.eventTypeId, 3);
    expect(got?.templateId, 41);
    expect(s.consume(), isNull);
  });

  test('an empty intent is not stored; clear drops a pending one', () {
    final s = PendingWizardIntentService();
    s.set(const PendingWizardIntent());
    expect(s.hasPending, isFalse);

    s.set(const PendingWizardIntent(eventTypeId: 1));
    s.clear();
    expect(s.consume(), isNull);
  });
}
