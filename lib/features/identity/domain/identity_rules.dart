import '../../../core/utils/person_name.dart';
import 'entities/identity_entities.dart';

/// The identity form's checks, mirroring the backend
/// (`IdentityVerificationService::checkDocument`), so most refusals are
/// shown before the photos are uploaded. The server stays the authority.
class IdentityRules {
  IdentityRules._();

  static const List<String> arabicFields = [
    'first_name_ar',
    'father_name_ar',
    'grandfather_name_ar',
    'family_name_ar',
  ];

  static const List<String> latinFields = ['given_names_latin', 'family_name_latin'];

  static final RegExp _separators = RegExp(r'[\s\-/.]+');
  static final RegExp _documentNumber = RegExp(r'^[A-Z0-9]{4,20}$');
  static final RegExp _shortDigits = RegExp(r'^\d{5,9}$');

  /// Arabic-Indic (U+0660..0669) and Persian (U+06F0..06F9) digits → 0-9.
  static String normalizeDigits(String? value) {
    final out = StringBuffer();
    for (final unit in (value ?? '').codeUnits) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        out.writeCharCode(0x30 + unit - 0x0660);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        out.writeCharCode(0x30 + unit - 0x06F0);
      } else {
        out.writeCharCode(unit);
      }
    }
    return out.toString();
  }

  /// Western digits, upper case, no spaces / dashes / slashes / dots.
  static String normalizeNumber(String? value) =>
      normalizeDigits(value).replaceAll(_separators, '').toUpperCase();

  /// The 9-digit check digit of Palestinian and Israeli ID numbers (one
  /// population registry): weights 1,2,1,2… with digit sums, total % 10 == 0.
  static bool hasValidCheckDigit(String digits) {
    if (!_shortDigits.hasMatch(digits)) return false;
    final id = digits.padLeft(9, '0');
    if (id == '000000000') return false;
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      final product = (id.codeUnitAt(i) - 0x30) * ((i % 2) + 1);
      sum += product > 9 ? product - 9 : product;
    }
    return sum % 10 == 0;
  }

  /// A Palestinian ID card prints all four parts of the Arabic name.
  static bool needsFourPartArabic(String type, String country, IdentityOptionsEntity options) =>
      type == 'national_id' && options.fourPartIdCountries.contains(country);

  /// A passport always carries the name in Latin letters.
  static bool needsLatin(String type) => type == 'passport';

  static bool usesCheckDigit(String type, String country, IdentityOptionsEntity options) =>
      type == 'national_id' && options.checkDigitIdCountries.contains(country);

  /// field → translation key of the first problem; empty when the input passes.
  static Map<String, String> validate({
    required String documentType,
    required String country,
    required String number,
    required Map<String, String> names,
    IdentityOptionsEntity options = const IdentityOptionsEntity(),
  }) {
    final errors = <String, String>{};
    String value(String field) => PersonName.clean(names[field]);
    bool filled(String field) => value(field).isNotEmpty;

    for (final field in arabicFields) {
      if (filled(field) && !PersonName.isArabic(value(field))) {
        errors[field] = 'identity_error_arabic_letters';
      }
    }
    for (final field in latinFields) {
      if (filled(field) && !PersonName.isLatin(value(field))) {
        errors[field] = 'identity_error_latin_letters';
      }
    }

    if (needsFourPartArabic(documentType, country, options)) {
      for (final field in arabicFields) {
        if (!filled(field)) errors.putIfAbsent(field, () => 'identity_error_four_part');
      }
    }
    if (needsLatin(documentType)) {
      for (final field in latinFields) {
        if (!filled(field)) errors.putIfAbsent(field, () => 'identity_error_latin_required');
      }
    }

    final arabic = filled('first_name_ar') && filled('family_name_ar');
    final latin = filled('given_names_latin') && filled('family_name_latin');
    if (!arabic && !latin) {
      errors.putIfAbsent('first_name_ar', () => 'identity_error_name_required');
    }
    if ((filled('father_name_ar') || filled('grandfather_name_ar')) && !arabic) {
      errors.putIfAbsent('family_name_ar', () => 'identity_error_name_required');
    }

    final normalized = normalizeNumber(number);
    if (usesCheckDigit(documentType, country, options)) {
      if (!hasValidCheckDigit(normalized)) errors['document_number'] = 'identity_error_id_number';
    } else if (!_documentNumber.hasMatch(normalized)) {
      errors['document_number'] = 'identity_error_document_number';
    }

    return errors;
  }

  /// Old enough to hold an account (Terms: 18+).
  static bool isAdult(DateTime birthDate, {int minimumAge = 18, DateTime? now}) {
    final today = now ?? DateTime.now();
    final adultBy = DateTime(today.year - minimumAge, today.month, today.day);
    return !birthDate.isAfter(adultBy);
  }
}
