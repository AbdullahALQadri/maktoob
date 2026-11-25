import '../../../../core/utils/gaza_time.dart';
import '../../domain/entities/my_payments.dart';

/// Parses `GET /payments/overview` (`{success, message, data:{paid_total,
/// payments[], due[], requests[]}}`). Tolerates a bare `data` object and
/// numbers sent as strings (MySQL decimals).
class MyPaymentsModel extends MyPayments {
  const MyPaymentsModel({
    required super.paidTotal,
    required super.receipts,
    required super.due,
    required super.sent,
  });

  factory MyPaymentsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    return MyPaymentsModel(
      paidTotal: _num(data['paid_total']),
      receipts: _list(data['payments']).map(_receipt).toList(),
      due: _list(data['due']).map(_due).toList(),
      sent: _list(data['requests']).map(_sent).toList(),
    );
  }

  static PaymentReceipt _receipt(Map<String, dynamic> j) => PaymentReceipt(
    id: _int(j['id']),
    receiptNumber: j['receipt_number']?.toString() ?? '',
    eventId: _id(j['event_id']),
    eventTitle: j['event_title']?.toString(),
    amount: _num(j['amount']),
    method: j['method']?.toString() ?? '',
    walletProvider: j['wallet_provider']?.toString(),
    reference: j['reference']?.toString(),
    status: j['status']?.toString() ?? 'paid',
    paidAt: GazaTime.wallClock(j['paid_at']),
    receiptUrl: j['receipt_url']?.toString(),
  );

  static PaymentDue _due(Map<String, dynamic> j) => PaymentDue(
    eventId: _id(j['event_id']) ?? '',
    eventTitle: j['event_title']?.toString() ?? '',
    amount: _num(j['amount']),
  );

  static SentReceipt _sent(Map<String, dynamic> j) => SentReceipt(
    id: _int(j['id']),
    requestNumber: j['request_number']?.toString() ?? '',
    eventId: _id(j['event_id']),
    eventTitle: j['event_title']?.toString(),
    amount: _num(j['amount']),
    status: j['status']?.toString() ?? 'pending',
    reason: j['admin_notes']?.toString(),
    sentAt: GazaTime.wallClock(j['created_at']),
  );

  static List<Map<String, dynamic>> _list(dynamic v) =>
      v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];

  static double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  static int _int(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  static String? _id(dynamic v) => v?.toString();
}
