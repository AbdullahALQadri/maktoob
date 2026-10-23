import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/events/data/models/event_add_ons_model.dart';
import 'package:maktoob/features/events/domain/entities/event_add_ons_entity.dart';

void main() {
  test('parses GET /events/{id}/add-ons (ApiResponse envelope)', () {
    final m = EventAddOnsModel.fromJson({
      'success': true,
      'data': {
        'can_request': true,
        'services': [
          {'extra_service_id': 3, 'name_ar': 'مصور', 'name_en': 'Photographer', 'quantity': 1,
           'total_price': 50, 'status': 'awaiting_payment', 'decision_note': null, 'can_withdraw': true},
        ],
        'payment_due': {'items': [], 'total': 50.0},
        'pending_payment_request': null,
        'available_services': [
          {'id': 4, 'name_ar': 'ضيافة', 'name_en': null, 'base_price': '120.00'},
        ],
      },
    });

    expect(m.canRequest, isTrue);
    expect(m.services.single.status, AddOnStatus.awaitingPayment);
    expect(m.services.single.name(false), 'Photographer');
    expect(m.amountDue, 50);
    expect(m.canPay, isTrue);
    expect(m.available.single.price, 120);
    expect(m.available.single.name(false), 'ضيافة'); // falls back to Arabic
  });

  test('a payment under review blocks paying again', () {
    final m = EventAddOnsModel.fromJson({
      'data': {
        'can_request': true,
        'services': const [],
        'payment_due': {'total': 50},
        'pending_payment_request': {'id': 9},
      },
    });
    expect(m.paymentUnderReview, isTrue);
    expect(m.canPay, isFalse);
  });
}
