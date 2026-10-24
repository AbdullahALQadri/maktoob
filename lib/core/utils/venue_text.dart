/// Where the occasion is, as one line — the same rule as the backend's
/// `Event::venueLine()`.
///
/// The host is asked once for the place («قاعة الأندلس – الرمال، غزة»).
/// Older events can still carry a separate address, sometimes repeating the
/// name ("غزة" / "غزة") or holding only the first letter typed; the address
/// is added only when it says more than the name, so nothing is shown twice.
class VenueText {
  VenueText._();

  static String line(String? name, String? address) {
    final n = (name ?? '').trim();
    final a = (address ?? '').trim();
    if (n.isEmpty) return a;
    if (a.isEmpty) return n;

    final nk = _key(n);
    final ak = _key(a);
    if (nk.isEmpty || ak.isEmpty || nk.contains(ak) || ak.contains(nk)) {
      return ak.length > nk.length ? a : n;
    }
    return '$n، $a';
  }

  /// Letters and digits only, so "غزة - " and "غزة،" compare equal.
  static String _key(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), '');
}
