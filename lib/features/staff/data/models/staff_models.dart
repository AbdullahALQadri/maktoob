import '../../domain/entities/staff_entities.dart';

/// Readers for the admin API answers the staff mode shows.
class StaffModels {
  const StaffModels._();

  static StaffUser user(dynamic json) {
    final map = _map(json);
    return StaffUser(name: '${map['name'] ?? ''}', email: _text(map['email']));
  }

  static StaffToday today(dynamic json) {
    final map = _map(json);
    return StaffToday(
      paymentRequestsPending: _int(map['payment_requests_pending']),
      identitiesPending: _int(map['identities_pending']),
      institutionsPending: _int(map['institutions_pending']),
      eventsToday: _int(map['events_today']),
      eventsAwaitingPayment: _int(map['events_awaiting_payment']),
    );
  }

  static StaffPaymentRequest paymentRequest(dynamic json, {dynamic imageUrls}) {
    final map = _map(json);
    final client = _map(map['client']);
    final event = _map(map['event']);
    return StaffPaymentRequest(
      id: _int(map['id']) ?? 0,
      amount: _number(map['amount']) ?? 0,
      status: '${map['status'] ?? 'pending'}',
      clientName: _text(client['name']),
      clientPhone: _text(client['phone']),
      eventTitle: _text(event['title']),
      method: _text(map['payment_method']),
      walletProvider: _text(map['wallet_provider']),
      isUpgrade: map['kind'] == 'upgrade',
      targetInvitations: _int(map['target_invitations']),
      clientNotes: _text(map['client_notes']),
      adminNotes: _text(map['admin_notes']),
      originalCurrency: _text(map['original_currency']),
      originalAmount: _number(map['original_amount']),
      createdAt: DateTime.tryParse('${map['created_at'] ?? ''}'),
      imageUrls: [for (final url in imageUrls is List ? imageUrls : const []) '$url'],
    );
  }

  static StaffClientRow client(dynamic json) {
    final map = _map(json);
    return StaffClientRow(
      id: _int(map['id']) ?? 0,
      name: '${map['name'] ?? ''}',
      phone: _text(map['phone']),
      isActive: _bool(map['is_active'], fallback: true),
      isVerified: _bool(map['is_verified']),
      isInstitution: map['account_type'] == 'institution',
      eventsCount: _int(map['events_count']) ?? 0,
    );
  }

  static StaffEventRow event(dynamic json) {
    final map = _map(json);
    return StaffEventRow(
      id: _int(map['id']) ?? 0,
      title: '${map['title'] ?? ''}',
      status: '${map['status'] ?? ''}',
      date: DateTime.tryParse('${map['event_date'] ?? ''}'),
      clientName: _text(_map(map['client'])['name']),
      invitationsCount: _int(map['invitations_count']) ?? 0,
    );
  }

  /// The rows of a paginated answer (`data` is the list).
  static List<T> rows<T>(Map<String, dynamic> response, T Function(dynamic) read) {
    final list = response['data'];
    return [for (final item in list is List ? list : const []) read(item)];
  }

  static Map<String, dynamic> data(Map<String, dynamic> response) => _map(response['data']);

  static Map<String, dynamic> _map(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : const {};

  static int? _int(dynamic value) => value is num ? value.toInt() : int.tryParse('${value ?? ''}');

  /// MySQL sends decimals as text.
  static double? _number(dynamic value) => value is num ? value.toDouble() : double.tryParse('${value ?? ''}');

  static bool _bool(dynamic value, {bool fallback = false}) =>
      value == null ? fallback : value == true || value == 1 || value == '1';

  static String? _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
