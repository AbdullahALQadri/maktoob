import '../../../../core/utils/gaza_time.dart';
import '../../domain/entities/event_details_info.dart';

/// Reads `details` from `GET /events/{id}`. Every key is optional: an older
/// backend (no `details`) gives null and the screen falls back to the event.
abstract final class EventDetailsInfoModel {
  static EventDetailsInfo? fromJson(Object? json) {
    if (json is! Map) return null;
    final venue = _map(json['venue']);
    final replies = _map(json['replies']);
    final billing = _map(json['billing']);
    final package = _map(billing['package']);

    return EventDetailsInfo(
      startsAt: GazaTime.wallClock(json['starts_at']),
      endsAt: GazaTime.wallClock(json['ends_at']),
      venueName: _text(venue['name']),
      venueAddress: _text(venue['address']),
      mapUrl: _text(venue['map_url']),
      description: _text(json['description']),
      occasionAnswers: _list(json['occasion_answers'])
          .map((a) => OccasionAnswer(
                key: '${a['key'] ?? ''}',
                labelAr: _text(a['label_ar']) ?? _text(a['label_en']) ?? '${a['key'] ?? ''}',
                labelEn: _text(a['label_en']) ?? _text(a['label_ar']) ?? '${a['key'] ?? ''}',
                value: _text(a['value']) ?? '',
                onInvitation: a['on_invitation'] == true,
              ))
          .where((a) => a.value.isNotEmpty)
          .toList(),
      replies: EventReplySettings(
        requireResponse: replies['require_response'] != false,
        responseDeadline: DateTime.tryParse('${replies['response_deadline'] ?? ''}'),
        allowCompanions: replies['allow_companions'] != false,
        maxCompanions: _int(replies['max_companions']),
        askReason: replies['ask_reason'] == true,
      ),
      messages: _list(json['messages'])
          .map((m) => GuestMessage(key: '${m['key'] ?? ''}', ar: _text(m['ar']), en: _text(m['en'])))
          .where((m) => m.ar != null || m.en != null)
          .toList(),
      deliveryMethod: _text(json['delivery_method']),
      billing: EventBilling(
        packageNameAr: _text(package['name_ar']),
        packageNameEn: _text(package['name_en']),
        customPackage: billing['custom_package'] == true,
        invitationLimit: _int(billing['invitation_limit']),
        invitationsUsed: _int(billing['invitations_used']) ?? 0,
        invoiceNumber: _text(billing['invoice_number']),
        total: _double(billing['total']),
        paid: _double(billing['paid']) ?? 0,
      ),
      invitationsSentAt: GazaTime.wallClock(json['invitations_sent_at']),
      createdAt: GazaTime.wallClock(json['created_at']),
    );
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static List<Map<String, dynamic>> _list(Object? value) =>
      value is List ? value.whereType<Map>().map(Map<String, dynamic>.from).toList() : const [];

  static String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static int? _int(Object? value) => value is int ? value : int.tryParse('${value ?? ''}');

  static double? _double(Object? value) => value is num ? value.toDouble() : double.tryParse('${value ?? ''}');
}
