/// The backend sends times in Gaza with their offset
/// (`2026-10-29T19:00:00+03:00`). These helpers keep what the host announced.
abstract final class GazaTime {
  static final RegExp _offset = RegExp(r'([+-])(\d{2}):?(\d{2})$');

  /// The wall-clock date and time as written (Gaza time), ignoring the
  /// offset: "19:00" stays 19:00 on a phone set to any country.
  static DateTime? wallClock(Object? iso) {
    final text = iso?.toString() ?? '';
    if (text.length < 10) return null;
    return DateTime.tryParse(text.length >= 19 ? text.substring(0, 19) : text.substring(0, 10));
  }

  /// The UTC offset carried by an ISO time, or null when it has none.
  static Duration? offsetOf(Object? iso) {
    final match = _offset.firstMatch(iso?.toString() ?? '');
    if (match == null) return null;
    final minutes = int.parse(match.group(2)!) * 60 + int.parse(match.group(3)!);
    return Duration(minutes: match.group(1) == '-' ? -minutes : minutes);
  }
}
