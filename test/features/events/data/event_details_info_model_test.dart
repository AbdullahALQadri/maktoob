import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/events/data/models/event_model.dart';

void main() {
  group('EventModel details (GET /events/{id})', () {
    test('reads everything the host entered, times as announced in Gaza', () {
      final e = EventModel.fromJson({
        'id': 14,
        'status': 'active',
        'title': 'Wedding night',
        'details': {
          'starts_at': '2026-12-10T19:00:00+02:00',
          'ends_at': '2026-12-10T23:30:00+02:00',
          'venue': {'name': 'Andalus Hall', 'address': 'Rimal street', 'map_url': 'https://www.google.com/maps?q=31.52,34.45'},
          'description': 'Dinner after the ceremony',
          'occasion_answers': [
            {'key': 'groom_name', 'label_ar': 'اسم العريس', 'label_en': 'Groom name', 'value': 'Ahmad', 'on_invitation': true},
            {'key': 'empty', 'label_ar': 'فارغ', 'label_en': 'Empty', 'value': ''},
          ],
          'replies': {'require_response': false, 'response_deadline': '2026-12-05', 'allow_companions': true, 'max_companions': null, 'ask_reason': true},
          'messages': [
            {'key': 'invitation', 'ar': 'أهلاً بكم', 'en': null},
          ],
          'delivery_method': 'whatsapp',
          'billing': {
            'package': {'name_ar': 'الذهبية', 'name_en': 'Gold'},
            'custom_package': false,
            'invitation_limit': 100,
            'invitations_used': 12,
            'invoice_number': 'EV-2026-0042',
            'total': '150.00',
            'paid': 150,
          },
          'invitations_sent_at': null,
        },
      });

      final d = e.details!;
      expect(d.startsAt, DateTime(2026, 12, 10, 19));
      expect(d.endsAt, DateTime(2026, 12, 10, 23, 30));
      expect(d.venueName, 'Andalus Hall');
      expect(d.venueAddress, 'Rimal street');
      expect(d.mapUrl, 'https://www.google.com/maps?q=31.52,34.45');
      expect(d.occasionAnswers, hasLength(1));
      expect(d.occasionAnswers.first.label('ar'), 'اسم العريس');
      expect(d.occasionAnswers.first.label('en'), 'Groom name');
      expect(d.occasionAnswers.first.onInvitation, isTrue);
      expect(d.replies.requireResponse, isFalse);
      expect(d.replies.responseDeadline, DateTime(2026, 12, 5));
      expect(d.replies.maxCompanions, isNull);
      expect(d.replies.askReason, isTrue);
      // An Arabic-only text still shows in English.
      expect(d.messages.single.text('en'), 'أهلاً بكم');
      expect(d.billing.packageName('en'), 'Gold');
      expect(d.billing.invitationLimit, 100);
      expect(d.billing.invitationsUsed, 12);
      expect(d.billing.total, 150.0);
      expect(d.billing.paid, 150.0);
      expect(d.invitationsSentAt, isNull);
    });

    test('an older payload without details still parses', () {
      final e = EventModel.fromJson({'id': 1, 'status': 'draft', 'title': 'Draft'});
      expect(e.details, isNull);
    });

    test('details survive the entity round trip', () {
      final e = EventModel.fromJson({
        'id': 2,
        'details': {'starts_at': '2026-11-01T18:00:00+02:00'},
      });
      expect(e.toEntity().details?.startsAt, DateTime(2026, 11, 1, 18));
      expect(e.copyWith(name: 'x').details, e.details);
    });
  });
}
