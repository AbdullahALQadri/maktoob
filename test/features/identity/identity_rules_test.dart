import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/identity/domain/entities/identity_entities.dart';
import 'package:maktoob/features/identity/domain/identity_rules.dart';

/// Arabic-Indic digits for a Western digit string ("12" → "١٢").
String arabicDigits(String s) => String.fromCharCodes(s.codeUnits.map((c) => 0x0660 + c - 0x30));

const fourPart = {
  'first_name_ar': 'محمد',
  'father_name_ar': 'عبد الله',
  'grandfather_name_ar': 'أحمد',
  'family_name_ar': 'أبو شمالة',
};

void main() {
  group('IdentityRules document number', () {
    test('the 9-digit check digit (weights 1,2,1,2…) matches the backend', () {
      expect(IdentityRules.hasValidCheckDigit('123456782'), isTrue);
      expect(IdentityRules.hasValidCheckDigit('000000018'), isTrue);
      expect(IdentityRules.hasValidCheckDigit('18'), isFalse, reason: 'fewer than 5 digits');
      expect(IdentityRules.hasValidCheckDigit('123456789'), isFalse);
      expect(IdentityRules.hasValidCheckDigit('000000000'), isFalse);
      expect(IdentityRules.hasValidCheckDigit('12345678A'), isFalse);
    });

    test('Arabic-Indic digits, spaces and dashes are normalized', () {
      expect(IdentityRules.normalizeNumber('${arabicDigits('123')} 456-782'), '123456782');
      expect(IdentityRules.normalizeNumber(' ab 12/34 '), 'AB1234');
    });
  });

  group('IdentityRules.validate', () {
    test('a Palestinian ID needs the four Arabic parts and a valid number', () {
      expect(
        IdentityRules.validate(documentType: 'national_id', country: 'PS', number: '123456782', names: fourPart),
        isEmpty,
      );

      final missing = IdentityRules.validate(
        documentType: 'national_id',
        country: 'PS',
        number: '123456789',
        names: {'first_name_ar': 'محمد', 'family_name_ar': 'أبو شمالة'},
      );
      expect(missing['father_name_ar'], 'identity_error_four_part');
      expect(missing['grandfather_name_ar'], 'identity_error_four_part');
      expect(missing['document_number'], 'identity_error_id_number');
    });

    test('a passport needs the Latin name; other numbers are letters and digits', () {
      final errors = IdentityRules.validate(
        documentType: 'passport',
        country: 'DE',
        number: 'C01X00T47',
        names: {'first_name_ar': 'محمد', 'family_name_ar': 'أبو شمالة'},
      );
      expect(errors['given_names_latin'], 'identity_error_latin_required');
      expect(errors['family_name_latin'], 'identity_error_latin_required');
      expect(errors.containsKey('document_number'), isFalse);

      expect(
        IdentityRules.validate(
          documentType: 'passport',
          country: 'DE',
          number: 'C01X00T47',
          names: {'given_names_latin': 'Mohammed', 'family_name_latin': 'Abu-Shamala'},
        ),
        isEmpty,
      );
      expect(
        IdentityRules.validate(
          documentType: 'passport',
          country: 'DE',
          number: 'C0#',
          names: {'given_names_latin': 'Mohammed', 'family_name_latin': 'Abu-Shamala'},
        )['document_number'],
        'identity_error_document_number',
      );
    });

    test('scripts are checked per field and one complete name is required', () {
      final errors = IdentityRules.validate(
        documentType: 'residence_permit',
        country: 'AE',
        number: '784198012345',
        names: {'first_name_ar': 'Mohammed', 'given_names_latin': 'محمد'},
      );
      expect(errors['first_name_ar'], 'identity_error_arabic_letters');
      expect(errors['given_names_latin'], 'identity_error_latin_letters');

      final none = IdentityRules.validate(documentType: 'residence_permit', country: 'AE', number: 'AB1234', names: {});
      expect(none['first_name_ar'], 'identity_error_name_required');
    });

    test('the option lists from the backend decide which rules apply', () {
      const options = IdentityOptionsEntity(fourPartIdCountries: ['JO'], checkDigitIdCountries: []);
      expect(
        IdentityRules.validate(
          documentType: 'national_id',
          country: 'PS',
          number: 'ABC123',
          names: {'first_name_ar': 'محمد', 'family_name_ar': 'صالح'},
          options: options,
        ),
        isEmpty,
      );
    });

    test('minimum age is 18 by default', () {
      final now = DateTime(2026, 10, 24);
      expect(IdentityRules.isAdult(DateTime(2008, 10, 24), now: now), isTrue);
      expect(IdentityRules.isAdult(DateTime(2008, 10, 25), now: now), isFalse);
    });
  });

  test('IdentitySubmissionInput sends filled names, the declaration and no empty parts', () {
    final fields = const IdentitySubmissionInput(
      documentType: 'passport',
      documentCountry: 'DE',
      documentNumber: 'C01X00T47',
      givenNamesLatin: ' Mohammed ',
      familyNameLatin: 'Abu-Shamala',
      birthDate: '1990-05-14',
      frontPath: '/tmp/front.jpg',
    ).toFields();

    expect(fields['given_names_latin'], 'Mohammed');
    expect(fields['declaration'], '1');
    expect(fields.containsKey('first_name_ar'), isFalse);
    expect(fields.containsKey('document_expires_on'), isFalse);
  });
}
