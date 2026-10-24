import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/utils/venue_text.dart';

void main() {
  group('VenueText.line (same rule as Event::venueLine on the backend)', () {
    test('a repeated address is not shown twice', () {
      expect(VenueText.line('غزة', 'غزة'), 'غزة');
    });

    test('the fuller of the two wins when one contains the other', () {
      expect(VenueText.line('غزة', 'غزة - الجامعة الإسلامية'), 'غزة - الجامعة الإسلامية');
      expect(VenueText.line('قاعة الأندلس', 'ق'), 'قاعة الأندلس');
    });

    test('a real address is added after the name', () {
      expect(VenueText.line('القاعة الكبرى', 'شارع الرشيد'), 'القاعة الكبرى، شارع الرشيد');
    });

    test('either part alone is the place', () {
      expect(VenueText.line(null, 'شارع الرشيد'), 'شارع الرشيد');
      expect(VenueText.line('قاعة الأندلس', null), 'قاعة الأندلس');
      expect(VenueText.line('', ''), '');
    });
  });
}
