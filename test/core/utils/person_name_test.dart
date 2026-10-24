import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/utils/person_name.dart';

void main() {
  group('PersonName (mirrors App\\Support\\PersonName)', () {
    test('clean collapses spaces, drops tatweel and maps Persian look-alikes', () {
      final tatweel = String.fromCharCode(0x0640);
      final farsiYeh = String.fromCharCode(0x06CC);
      final keheh = String.fromCharCode(0x06A9);
      expect(PersonName.clean('  محمد   $tatweelأحمد  '), 'محمد أحمد');
      expect(PersonName.clean('عل$farsiYeh'), 'علي');
      expect(PersonName.clean('$kehehمال'), 'كمال');
      expect(PersonName.clean('Ahmad${String.fromCharCode(0x200F)} Saleh'), 'Ahmad Saleh');
    });

    test('a full name needs letters only and at least two words', () {
      expect(PersonName.fullNameErrorKey('محمد عبد الله'), isNull);
      expect(PersonName.fullNameErrorKey("Sean O'Brien"), isNull);
      expect(PersonName.fullNameErrorKey('محمد'), 'name_full_required');
      expect(PersonName.fullNameErrorKey('Ahmad 99'), 'name_letters_only');
      expect(PersonName.fullNameErrorKey('   '), 'auth_field_required');
      expect(PersonName.fullNameErrorKey('@hmad Saleh'), 'name_letters_only');
    });

    test('script checks keep compound names together', () {
      expect(PersonName.isArabic('عبد الله'), isTrue);
      expect(PersonName.isArabic('أبو شمالة'), isTrue);
      expect(PersonName.isArabic('محمد١'), isFalse);
      expect(PersonName.isArabic('Ahmad'), isFalse);
      expect(PersonName.isLatin('Abu-Shamala'), isTrue);
      expect(PersonName.isLatin('Mohammed Abdullah'), isTrue);
      expect(PersonName.isLatin('محمد'), isFalse);
      expect(PersonName.isLatin('Ahmad2'), isFalse);
    });
  });
}
