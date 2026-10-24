import 'package:flutter/painting.dart';

/// The hourly colour moods of hero banners: the same eight as the web
/// (backend `App\Support\BannerMood`). Decorative only; buttons, links and
/// statuses keep the sky/navy identity.
///
/// The mood turns every hour in Gaza and the cycle shifts by one each day,
/// so the same hour does not always look the same.
class BannerMood {
  const BannerMood(this.key, this.from, this.via, this.to, this.glow, this.accent, this.ink);

  final String key;
  final Color from;
  final Color via;
  final Color to;

  /// The corner light.
  final Color glow;

  /// Small text and the ornament.
  final Color accent;

  /// Text on the white button.
  final Color ink;

  /// Translation key of the mood's name.
  String get nameKey => 'mood_$key';

  /// Same order as the backend: the index decides the mood.
  static const all = <BannerMood>[
    BannerMood(
      'olive',
      Color(0xFF0E5E4A),
      Color(0xFF0B4F3E),
      Color(0xFF08392D),
      Color.fromRGBO(194, 136, 74, .42),
      Color(0xFFE9C796),
      Color(0xFF0B4F3E),
    ),
    BannerMood(
      'sky',
      Color(0xFF1C74A8),
      Color(0xFF1A5F99),
      Color(0xFF032855),
      Color.fromRGBO(125, 196, 234, .40),
      Color(0xFFCFE9F8),
      Color(0xFF032855),
    ),
    BannerMood(
      'sunset',
      Color(0xFFC2502E),
      Color(0xFFA3324F),
      Color(0xFF4A1D4F),
      Color.fromRGBO(255, 190, 120, .45),
      Color(0xFFFFD9B3),
      Color(0xFF7A2445),
    ),
    BannerMood(
      'sea',
      Color(0xFF0B7C7C),
      Color(0xFF0A5E6B),
      Color(0xFF0B3341),
      Color.fromRGBO(150, 236, 222, .35),
      Color(0xFFBFF3EA),
      Color(0xFF0A5E6B),
    ),
    BannerMood(
      'night',
      Color(0xFF3B2A6B),
      Color(0xFF24184A),
      Color(0xFF120C2B),
      Color.fromRGBO(226, 190, 90, .38),
      Color(0xFFEBD58E),
      Color(0xFF24184A),
    ),
    BannerMood(
      'rose',
      Color(0xFFA8436A),
      Color(0xFF7E2A50),
      Color(0xFF43142C),
      Color.fromRGBO(255, 196, 214, .40),
      Color(0xFFFFD3E0),
      Color(0xFF7E2A50),
    ),
    BannerMood(
      'clay',
      Color(0xFFA15C33),
      Color(0xFF7C4128),
      Color(0xFF3F2116),
      Color.fromRGBO(244, 204, 146, .42),
      Color(0xFFF5D7B0),
      Color(0xFF7C4128),
    ),
    BannerMood(
      'dawn',
      Color(0xFF5464B8),
      Color(0xFF5B4A96),
      Color(0xFF2A2556),
      Color.fromRGBO(255, 205, 170, .40),
      Color(0xFFE4DCFF),
      Color(0xFF3A3378),
    ),
  ];

  /// The mood at the instant [now] in Gaza, whose UTC offset is [gazaOffset]
  /// (it moves with daylight saving; the server tells the app).
  static BannerMood at(DateTime now, Duration gazaOffset) {
    final gaza = now.toUtc().add(gazaOffset);
    final dayOfYear = gaza.difference(DateTime.utc(gaza.year)).inDays + 1;
    return all[(gaza.hour + dayOfYear) % all.length];
  }
}
