import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/events/data/models/event_model.dart';
import 'package:maktoob/features/events/domain/entities/event_entity.dart';

EventModel _event(String status, {Object? total}) => EventModel.fromJson({
      'id': 5,
      'title': 'زفاف',
      'status': status,
      'event_date': '2026-11-01',
      if (total != null) 'invoice_total': total,
    });

void main() {
  group('EventStatus parsing', () {
    test('covers every backend status', () {
      expect(_event('draft').status, EventStatus.draft);
      expect(_event('pending_payment').status, EventStatus.pendingPayment);
      expect(_event('active').status, EventStatus.active);
      expect(_event('completed').status, EventStatus.completed);
      expect(_event('cancelled').status, EventStatus.cancelled);
      expect(_event('something_new').status, EventStatus.draft);
    });

    test('apiValue round-trips the backend values', () {
      for (final s in EventStatus.values) {
        expect(EventStatusApi.parse(s.apiValue), s);
      }
      expect(EventStatus.pendingPayment.apiValue, 'pending_payment');
    });

    test('pending payment and cancelled are inactive', () {
      expect(_event('pending_payment').isPendingPayment, isTrue);
      expect(_event('pending_payment').isInactive, isTrue);
      expect(_event('cancelled').isInactive, isTrue);
      expect(_event('active').isInactive, isFalse);
    });
  });
}
