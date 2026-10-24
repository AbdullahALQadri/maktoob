import 'package:flutter/widgets.dart';

import '../../config/locale/l10n_context.dart';

/// Dates in words, in the app's language (keys in lang/*.json), so every
/// screen writes "Thursday 29 October · 19:00" the same way.
extension DateWords on BuildContext {
  static const _months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];

  String monthName(DateTime date) => tr('month_${_months[date.month - 1]}');

  String monthShort(DateTime date) => tr('month_short_${_months[date.month - 1]}');

  /// Monday is 1, Sunday 7 ([DateTime.weekday]).
  String weekdayName(DateTime date) => tr('weekday_${date.weekday}');

  String clockTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  /// "Thursday 29 October · 19:00" (time left out at midnight).
  String eventDateLine(DateTime date) {
    final day = '${weekdayName(date)} ${date.day} ${monthName(date)}';
    final hasTime = date.hour != 0 || date.minute != 0;
    return hasTime ? '$day · ${clockTime(date)}' : day;
  }

  /// "In 5 days", "Tomorrow", "Today", "Ended", with Arabic plural forms.
  String countdownLabel(int days) {
    if (days < 0) return tr('home_event_ended');
    if (days == 0) return tr('home_today');
    if (days == 1) return tr('home_in_days_1');
    if (days == 2) return tr('home_in_days_2');
    return tr(days <= 10 ? 'home_in_days_few' : 'home_in_days_many', {'count': days});
  }

  /// "5 days to go" under the big number, with Arabic plural forms.
  String daysLeftLabel(int days) => tr(switch (days) {
    1 => 'home_days_left_1',
    2 => 'home_days_left_2',
    <= 10 => 'home_days_left_few',
    _ => 'home_days_left_many',
  });
}
