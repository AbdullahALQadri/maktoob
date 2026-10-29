import 'package:flutter/material.dart';

/// Page-1 rules kept in sync with the backend.
class EventSetupRules {
  EventSetupRules._();

  /// Mirrors `Event::suggestedTitle()` (maktoob-backend/app/Models/Event.php):
  /// the title the backend writes when the host leaves it empty.
  static String suggestTitle({
    required String? slug,
    required String? typeNameAr,
    required Map<String, dynamic> values,
    String? clientName,
  }) {
    String? get(String k) {
      final v = values[k];
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    final typeName = (typeNameAr != null && typeNameAr.trim().isNotEmpty) ? typeNameAr.trim() : 'مناسبة';
    final groom = get('groom_name');
    final bride = get('bride_name');
    final couple = groom != null && bride != null ? '$groom و$bride' : null;

    String? title;
    switch (slug) {
      case 'wedding':
        final family = get('family_name');
        title = family != null
            ? (family.startsWith('أفراح') ? family : 'أفراح $family')
            : (couple != null ? 'زفاف $couple' : null);
        break;
      case 'engagement':
        title = couple != null ? 'خطوبة $couple' : null;
        break;
      case 'katb-kitab':
        title = couple != null ? 'كتب كتاب $couple' : null;
        break;
      case 'henna':
        title = bride != null ? 'حنّة العروس $bride' : null;
        break;
      case 'anniversary':
        final c = get('couple_names');
        title = c != null ? 'ذكرى زواج $c' : null;
        break;
      case 'baby-shower':
      case 'baby-party':
      case 'aqiqah':
        final b = get('baby_name');
        title = b != null ? '$typeName $b' : null;
        break;
      case 'birthday':
        final c = get('celebrant_name');
        title = c != null ? 'عيد ميلاد $c' : null;
        break;
      case 'graduation':
        final g = get('graduate_name');
        title = g != null ? 'حفل تخرج $g' : null;
        break;
      case 'tawjihi':
        final g = get('graduate_name');
        title = g != null ? 'نجاح $g' : null;
        break;
      case 'hajj-return':
        final p = get('pilgrim_name');
        title = p != null ? 'استقبال الحاج $p' : null;
        break;
      case 'quran-completion':
        final h = get('hafiz_name');
        title = h != null ? 'ختم القرآن الكريم — $h' : null;
        break;
      case 'opening':
        final b = get('business_name');
        title = b != null ? 'افتتاح $b' : null;
        break;
      case 'product-launch':
        final p = get('product_name');
        title = p != null ? 'إطلاق $p' : null;
        break;
      default:
        final company = get('company_name');
        final hosts = get('host_names');
        title = company != null ? '$typeName — $company' : (hosts != null ? '$typeName — $hosts' : null);
    }
    if (title != null && title.isNotEmpty) return title;

    final client = clientName?.trim() ?? '';
    return client.isEmpty ? typeName : '$typeName — $client';
  }

  /// Backend `GAZA_BOUNDS` (EventSetupService) — coordinates outside are 422.
  static const double minLat = 31.2;
  static const double maxLat = 31.6;
  static const double minLng = 34.2;
  static const double maxLng = 34.6;

  static bool isInGaza(double lat, double lng) => lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;

  /// End time for `has_end_time` types sits on the start day and must be later.
  static bool isEndAfterStart(TimeOfDay start, TimeOfDay end) =>
      end.hour * 60 + end.minute > start.hour * 60 + start.minute;

  /// The longest event the door handles day by day (backend MAX_EVENT_DAYS).
  static const int maxEventDays = 31;

  /// The `end_date` to send, only for has_end_time types: the start day at
  /// [end], or [lastDay] at [end] for an event of several days (the guests'
  /// QR then works every day, each day counting its own attendance).
  static DateTime? endDateTimeToSend({
    required bool hasEndTime,
    required DateTime? date,
    required TimeOfDay? start,
    required TimeOfDay? end,
    DateTime? lastDay,
  }) {
    if (!hasEndTime || date == null || end == null) return null;
    if (lastDay != null && isLaterDay(date, lastDay)) {
      return DateTime(lastDay.year, lastDay.month, lastDay.day, end.hour, end.minute);
    }
    if (start != null && !isEndAfterStart(start, end)) return null;
    return DateTime(date.year, date.month, date.day, end.hour, end.minute);
  }

  /// [lastDay] is a later calendar day than [start], within [maxEventDays].
  static bool isLaterDay(DateTime start, DateTime lastDay) {
    final days = DateTime(
      lastDay.year,
      lastDay.month,
      lastDay.day,
    ).difference(DateTime(start.year, start.month, start.day)).inDays;
    return days >= 1 && days < maxEventDays;
  }
}
