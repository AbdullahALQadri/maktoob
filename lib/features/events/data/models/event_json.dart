/// Readers for the event payloads, which differ between endpoints (relation
/// maps or plain strings, ints or numeric strings, counts or lists).
abstract final class EventJson {
  /// A display name from a plain String or a loaded relation Map
  /// ({name_ar / name_en / name}).
  static String? nameFrom(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      return (value['name_ar'] ?? value['name_en'] ?? value['name']) as String?;
    }
    return null;
  }

  /// An int from an int or numeric string; null otherwise.
  static int? toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// An int, a List (its length), a numeric string, or null.
  static int? countOf(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is List) return value.length;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Mirrors Event::getEffectiveInvitationsLimit(): the attached packages'
  /// `pivot.invitations_included` total, else `max_invitations`.
  /// Null (or 0) means no limit.
  static int? invitationLimit(Map<String, dynamic> json) {
    final explicit = toInt(json['invitation_limit']);
    if (explicit != null) return explicit > 0 ? explicit : null;
    final packages = json['packages'];
    if (packages is List) {
      var total = 0;
      for (final p in packages) {
        if (p is Map && p['pivot'] is Map) {
          total += toInt(p['pivot']['invitations_included']) ?? 0;
        }
      }
      if (total > 0) return total;
    }
    final max = toInt(json['max_invitations']);
    return (max != null && max > 0) ? max : null;
  }

  /// Mirrors Event::getRemainingInvitationsAttribute(). Null = unlimited.
  static int? remaining(Map<String, dynamic> json) {
    if (json.containsKey('remaining_invitations')) {
      return toInt(json['remaining_invitations']);
    }
    final limit = invitationLimit(json);
    if (limit == null) return null;
    final used = toInt(json['invitations_used']) ?? 0;
    return (limit - used).clamp(0, limit);
  }

  static String dateLabel(dynamic eventDate) {
    if (eventDate == null) return '';
    if (eventDate is String) {
      try {
        final date = DateTime.parse(eventDate);
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      } catch (_) {
        return eventDate;
      }
    }
    return '';
  }
}
