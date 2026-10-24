import '../entities/door_entities.dart';

/// The door rules, decided on the phone (no connection needed). The same
/// rules as `App\Services\CheckInService` in the backend:
///
///  - only an `active` or `completed` event admits;
///  - inside the event's date window (the event's day, Asia/Gaza, sent by the
///    server as instants);
///  - the first entry is the attendance; a later scan that day lets the
///    guest back in (stepped out, came back) and records nothing;
///  - companions up to the invitation's maximum (asked at the first entry).
///
/// Warnings never refuse: the guest declined the RSVP, a men's / women's
/// gate for the other audience, a genuine invitation that is not in the
/// downloaded list yet.
class DoorRules {
  DoorRules._();

  static const Set<String> admittingStatuses = {'active', 'completed'};

  static const String eventNotActive = 'event_not_active';
  static const String notYetValid = 'qr_not_yet_valid';
  static const String expired = 'qr_expired';
  static const String tooManyCompanions = 'too_many_companions';
  static const String notFound = 'not_found';
  static const String otherEvent = 'other_event';

  static const String warnDeclined = 'declined';
  static const String warnWrongGate = 'wrong_gate';
  static const String warnUnlisted = 'unlisted';

  /// Why the event itself refuses entry at [nowUtc], or null.
  static String? eventBlocker(DoorEventInfo event, DateTime nowUtc) {
    if (!admittingStatuses.contains(event.status)) return eventNotActive;
    final from = event.validFrom;
    final until = event.validUntil;
    if (from != null && nowUtc.isBefore(from)) return notYetValid;
    if (until != null && nowUtc.isAfter(until)) return expired;
    return null;
  }

  static String? companionsBlocker(int companions, int? max) =>
      (max != null && companions > max) ? tooManyCompanions : null;

  static List<String> warnings({required DoorGuest guest, DoorGate? gate, bool unlisted = false}) {
    final out = <String>[];
    if (unlisted) out.add(warnUnlisted);
    if (guest.declined) out.add(warnDeclined);
    if (gate != null && _wrongGate(gate.audience, guest.gender)) out.add(warnWrongGate);
    return out;
  }

  static bool _wrongGate(String audience, String? gender) =>
      (audience == 'men' && gender == 'female') || (audience == 'women' && gender == 'male');
}
