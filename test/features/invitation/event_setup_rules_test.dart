import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/invitation/domain/utils/event_setup_rules.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_state.dart';

void main() {
  group('suggestTitle mirrors Event::suggestedTitle', () {
    String t(String? slug, Map<String, dynamic> v, {String name = 'زفاف'}) =>
        EventSetupRules.suggestTitle(slug: slug, typeNameAr: name, values: v);

    test('wedding uses family, adds أفراح once', () {
      expect(t('wedding', {'family_name': 'آل القادري'}), 'أفراح آل القادري');
      expect(t('wedding', {'family_name': 'أفراح آل القادري'}),
          'أفراح آل القادري');
      expect(t('wedding', {'groom_name': 'محمد', 'bride_name': 'سارة'}),
          'زفاف محمد وسارة');
    });

    test('graduation, opening, workshop', () {
      expect(t('graduation', {'graduate_name': ' محمد '}), 'حفل تخرج محمد');
      expect(t('opening', {'business_name': 'مطعم الياسمين'}),
          'افتتاح مطعم الياسمين');
      expect(t('workshop', {'company_name': 'شركة X'}, name: 'ورشة عمل'),
          'ورشة عمل — شركة X');
    });

    test('falls back to type name', () {
      expect(t('graduation', {'graduate_name': ''}, name: 'تخرج'), 'تخرج');
      expect(
          EventSetupRules.suggestTitle(
              slug: null, typeNameAr: null, values: const {}),
          'مناسبة');
    });
  });

  group('has_end_time', () {
    final date = DateTime(2026, 12, 1);
    const start = TimeOfDay(hour: 18, minute: 0);

    test('parsed from the event-types payload', () {
      final biz = EventTypeModel.fromJson(
          {'id': 1, 'slug': 'workshop', 'name_ar': 'ورشة', 'has_end_time': true});
      final wed = EventTypeModel.fromJson(
          {'id': 2, 'slug': 'wedding', 'name_ar': 'زفاف'});
      expect(biz.hasEndTime, isTrue);
      expect(biz.slug, 'workshop');
      expect(wed.hasEndTime, isFalse);
    });

    test('business: end on the same day after start', () {
      expect(
          EventSetupRules.endDateTimeToSend(
              hasEndTime: true,
              date: date,
              start: start,
              end: const TimeOfDay(hour: 21, minute: 30)),
          DateTime(2026, 12, 1, 21, 30));
      expect(
          EventSetupRules.endDateTimeToSend(
              hasEndTime: true,
              date: date,
              start: start,
              end: const TimeOfDay(hour: 17, minute: 0)),
          isNull);
    });

    test('other types never send an end', () {
      expect(
          EventSetupRules.endDateTimeToSend(
              hasEndTime: false,
              date: date,
              start: start,
              end: const TimeOfDay(hour: 21, minute: 0)),
          isNull);
    });

    test('next is not blocked by an empty title, but by a bad end time', () {
      const biz = EventTypeModel(
          id: 1, name: 'w', nameAr: 'w', slug: 'workshop', hasEndTime: true);
      final s = InvitationState(
          selectedEventType: biz, eventDate: date, eventTime: start);
      expect(s.canProceedFromEventDetails, isTrue);
      expect(
          s
              .copyWith(eventEndTime: const TimeOfDay(hour: 17, minute: 0))
              .canProceedFromEventDetails,
          isFalse);
    });
  });

  test('Gaza bounds match backend GAZA_BOUNDS', () {
    expect(EventSetupRules.isInGaza(31.42, 34.37), isTrue);
    expect(EventSetupRules.isInGaza(0, 0), isFalse);
    expect(EventSetupRules.isInGaza(31.9, 35.2), isFalse);
  });
}
