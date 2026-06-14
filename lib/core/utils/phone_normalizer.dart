/// Canonical phone-number normalization for Maktoob guests.
///
/// Background — there used to be FOUR divergent `_normalizePhone`
/// implementations across the invitation flow (cubit / Excel parser /
/// contact picker / manual form). The same Palestinian local number
/// `0599...` came out as `+0599...` from the cubit, `+970599...` from
/// Excel, and `+972599...` from contacts/manual. Result: guest
/// deduplication silently failed across import sources.
///
/// All callers must now use [PhoneNormalizer.normalize] so the same
/// physical number always produces the same string key.
///
/// Canonical form: `+<country><digits>`, with no spaces, dashes, or
/// formatting characters. Local Palestinian numbers (leading `0`) are
/// expanded to `+970...` by default; this matches the Palestine
/// Telecom country code. Numbers that already carry an explicit `+972`
/// or `+970` are preserved as-is so users in either jurisdiction don't
/// get rewritten.
class PhoneNormalizer {
  PhoneNormalizer._();

  /// Default country code prepended to local-format numbers (leading `0`).
  /// `'970'` (Palestine) is correct for the primary user base. The
  /// backend WhatsApp service has a `970 ↔ 972` fallback at send-time
  /// for numbers that fail to deliver — that's a routing concern, not
  /// a dedup concern, so we keep dedup canonical to one prefix.
  static const String defaultCountryCode = '970';

  /// Normalize [input] to canonical `+CCxxxxxxxxx` form.
  ///
  /// Returns an empty string if [input] has no digits at all.
  static String normalize(String input, {String? countryCode}) {
    final cc = countryCode ?? defaultCountryCode;

    // Strip everything that isn't a digit or a leading `+`.
    final hadPlus = input.trimLeft().startsWith('+');
    var digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) return '';

    // 00-prefixed international (some carriers) → +
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
      return '+$digits';
    }

    // Already has +CC — preserve.
    if (hadPlus) {
      return '+$digits';
    }

    // Bare-international (970..., 972..., 1..., etc.) — promote to +.
    // We treat any number starting with a known PA/IL country code OR
    // longer than the local 9-digit form as already-international.
    if (digits.startsWith('970') ||
        digits.startsWith('972') ||
        digits.length > 10) {
      return '+$digits';
    }

    // Local format (e.g. `0599123456`) — strip the leading `0` and prepend
    // the country code.
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return '+$cc$digits';
  }

  /// Returns true if [input] looks like a syntactically valid PA/IL
  /// mobile number after normalization. Conservative — does not catch
  /// every invalid number, but rejects empty / too-short / wrong-CC
  /// inputs that would create bad guest rows.
  static bool isValidPalestinian(String input) {
    final n = normalize(input);
    return RegExp(r'^\+97[02]\d{8,9}$').hasMatch(n);
  }
}
