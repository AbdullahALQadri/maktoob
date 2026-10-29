import '../../../../config/locale/app_localizations.dart';
import '../../domain/entities/door_entities.dart';

/// Door rule codes → the words staff read. An offline door has no server
/// message, so every refusal and warning is a code translated here.
class DoorTexts {
  DoorTexts._();

  static const _reasons = {
    'event_not_active',
    'qr_not_yet_valid',
    'qr_expired',
    'too_many_companions',
    'not_found',
    'other_event',
    'no_pack',
    'not_in_event',
    'invalid',
  };

  /// Why the door refuses. [message] (the server's own text) wins.
  static String reason(AppLocalizations t, String? code, {String? message, int? maxCompanions, String? validOn}) {
    if (message != null && message.isNotEmpty) return message;
    final key = _reasons.contains(code) ? 'door_reason_$code' : 'door_reason_refused';
    return t.translate(key).replaceAll('{max}', '${maxCompanions ?? ''}').replaceAll('{date}', validOn ?? '');
  }

  static String warning(AppLocalizations t, String code, {DoorGate? gate}) {
    final audience = gate == null ? '' : t.translate('door_audience_${gate.audience}');
    return t.translate('door_warn_$code').replaceAll('{audience}', audience);
  }

  static String audience(AppLocalizations t, String audience) => t.translate('door_audience_$audience');

  static String hhmm(DateTime at) {
    final l = at.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  /// "5 min ago" style, for the status bar.
  static String ago(AppLocalizations t, DateTime? at) {
    if (at == null) return t.translate('door_never');
    final d = DateTime.now().toUtc().difference(at.toUtc());
    if (d.inMinutes < 1) return t.translate('door_just_now');
    if (d.inMinutes < 60) return t.translate('door_minutes_ago').replaceAll('{n}', '${d.inMinutes}');
    if (d.inHours < 24) return t.translate('door_hours_ago').replaceAll('{n}', '${d.inHours}');
    return t.translate('door_days_ago').replaceAll('{n}', '${d.inDays}');
  }

  static String problem(AppLocalizations t, String code) => t.translate('door_problem_$code');
}
