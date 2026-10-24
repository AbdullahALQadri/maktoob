/// Personal names: clean-up and checks that mirror the backend
/// (`App\Support\PersonName` / `App\Rules\PersonName`), so the form says
/// what the server would refuse before anything is sent.
///
/// Names are never split from one string (Arabic compound names such as
/// "عبد الله" or "أبو شمالة" defeat any splitter); the legal name is typed in
/// parts on the identity form.
class PersonName {
  PersonName._();

  /// Persian / Urdu look-alike letters some Android keyboards type.
  static const Map<String, String> _lookalikes = {
    '\u06CC': '\u064A', // Farsi yeh -> Arabic yeh
    '\u06A9': '\u0643', // keheh -> kaf
    '\u06C1': '\u0647', // heh goal -> heh
    '\u06D5': '\u0647', // ae -> heh
  };

  /// Zero-width and direction marks (escaped: never paste them as characters).
  static final RegExp _invisible =
      RegExp(r'[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF\u061C\u00AD]');
  static final RegExp _spaces = RegExp(r'\s+');
  static final RegExp _anyLetter = RegExp(r'\p{L}', unicode: true);
  static final RegExp _personName = RegExp(r"^\p{L}[\p{L}\p{M}'’ʼ.\- ]*$", unicode: true);
  static final RegExp _arabic =
      RegExp(r'^[\p{Script=Arabic}\p{M}]+(?: [\p{Script=Arabic}\p{M}]+)*$', unicode: true);
  static final RegExp _notLetter = RegExp(r'[\p{N}\p{P}\p{S}]', unicode: true);
  static final RegExp _latin = RegExp(r"^\p{Script=Latin}[\p{Script=Latin}\p{M}'’ʼ.\- ]*$", unicode: true);

  /// Invisible marks removed, look-alikes mapped, tatweel dropped, spaces collapsed.
  static String clean(String? value) {
    var name = (value ?? '').replaceAll(_invisible, '');
    _lookalikes.forEach((from, to) => name = name.replaceAll(from, to));
    name = name.replaceAll('\u0640', ''); // tatweel
    return name.replaceAll(_spaces, ' ').trim();
  }

  /// A person's name in any script: starts with a letter, no digits or symbols.
  static bool isValid(String value) =>
      _personName.hasMatch(value) && _anyLetter.allMatches(value).length >= 2;

  static int wordCount(String value) =>
      value.trim().split(_spaces).where((w) => w.isNotEmpty).length;

  /// Arabic letters (and their marks) with single spaces: "عبد الله".
  static bool isArabic(String value) =>
      value.isNotEmpty && _arabic.hasMatch(value) && !_notLetter.hasMatch(value);

  /// Latin letters with the hyphen / apostrophe / dot names use: "O'Brien".
  static bool isLatin(String value) => _latin.hasMatch(value) && !value.contains('  ');

  /// Error translation key for a client's full name, or null when it is fine.
  static String? fullNameErrorKey(String? value, {int minWords = 2}) {
    final name = clean(value);
    if (name.isEmpty) return 'auth_field_required';
    if (!isValid(name)) return 'name_letters_only';
    if (wordCount(name) < minWords) return 'name_full_required';
    return null;
  }
}
