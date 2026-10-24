import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/utils/gaza_time.dart';

void main() {
  test('keeps the announced wall-clock time, whatever the phone zone', () {
    final date = GazaTime.wallClock('2026-10-29T19:00:00+03:00')!;
    expect([date.year, date.month, date.day, date.hour, date.minute], [2026, 10, 29, 19, 0]);
    expect(GazaTime.wallClock('2026-10-29'), DateTime(2026, 10, 29));
    expect(GazaTime.wallClock(null), isNull);
    expect(GazaTime.wallClock(''), isNull);
  });

  test('reads the UTC offset of an ISO time', () {
    expect(GazaTime.offsetOf('2026-10-24T15:00:00+02:00'), const Duration(hours: 2));
    expect(GazaTime.offsetOf('2026-07-16T00:30:00+03:00'), const Duration(hours: 3));
    expect(GazaTime.offsetOf('2026-07-16T00:30:00-05:30'), const Duration(hours: -5, minutes: -30));
    expect(GazaTime.offsetOf('2026-07-16T00:30:00Z'), isNull);
  });
}
