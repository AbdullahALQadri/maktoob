import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/design/mood/banner_mood.dart';

/// The app must show the same mood as the web at the same hour. These
/// instants were computed by the backend (`BannerMood::current`).
void main() {
  const vectors = <(String, int, String)>[
    ('2026-10-24T13:00:00Z', 2, 'olive'), // Gaza 15:00, winter time
    ('2026-01-01T00:00:00Z', 2, 'sea'),
    ('2026-07-15T21:30:00Z', 3, 'rose'), // already the 16th in Gaza
    ('2026-03-28T22:30:00Z', 3, 'sky'), // first night of summer time
    ('2026-12-31T23:59:00Z', 2, 'sunset'), // new year in Gaza
  ];

  for (final (instant, offsetHours, mood) in vectors) {
    test('$instant (UTC+$offsetHours in Gaza) is $mood, as on the server', () {
      final at = BannerMood.at(DateTime.parse(instant), Duration(hours: offsetHours));
      expect(at.key, mood);
    });
  }

  test('there are eight moods, in the backend order', () {
    expect(BannerMood.all.map((m) => m.key), ['olive', 'sky', 'sunset', 'sea', 'night', 'rose', 'clay', 'dawn']);
  });
}
