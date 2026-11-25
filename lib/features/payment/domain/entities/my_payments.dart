import 'package:equatable/equatable.dart';

/// "My payments": everything about the host's money in one place, as the
/// portal shows it (`GET /payments/overview`).
class MyPayments extends Equatable {
  /// Sum of the confirmed (not refunded) payments, in ILS.
  final double paidTotal;

  /// Confirmed payments, newest first, each with its printable receipt.
  final List<PaymentReceipt> receipts;

  /// Events waiting for their payment with no receipt under review.
  final List<PaymentDue> due;

  /// Receipts the host sent that the team is reviewing or refused.
  final List<SentReceipt> sent;

  const MyPayments({
    required this.paidTotal,
    required this.receipts,
    required this.due,
    required this.sent,
  });

  bool get isEmpty => receipts.isEmpty && due.isEmpty && sent.isEmpty;

  @override
  List<Object?> get props => [paidTotal, receipts, due, sent];
}

class PaymentReceipt extends Equatable {
  final int id;
  final String receiptNumber;
  final String? eventId;
  final String? eventTitle;
  final double amount;

  /// `cash`, `bank_transfer` or `wallet`.
  final String method;
  final String? walletProvider;
  final String? reference;

  /// `paid` or `refunded`.
  final String status;
  final DateTime? paidAt;

  /// Signed link to the printable receipt (valid for a short while; the
  /// screen re-fetches before opening an old one). Null when refunded.
  final String? receiptUrl;

  const PaymentReceipt({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.method,
    required this.status,
    this.eventId,
    this.eventTitle,
    this.walletProvider,
    this.reference,
    this.paidAt,
    this.receiptUrl,
  });

  bool get isRefunded => status == 'refunded';

  @override
  List<Object?> get props => [id, receiptNumber, amount, method, status, paidAt, receiptUrl];
}

class PaymentDue extends Equatable {
  final String eventId;
  final String eventTitle;
  final double amount;

  const PaymentDue({required this.eventId, required this.eventTitle, required this.amount});

  @override
  List<Object?> get props => [eventId, eventTitle, amount];
}

class SentReceipt extends Equatable {
  final int id;
  final String requestNumber;
  final String? eventId;
  final String? eventTitle;
  final double amount;

  /// `pending` (under review) or `rejected`.
  final String status;

  /// Why the team refused it (rejected only).
  final String? reason;
  final DateTime? sentAt;

  const SentReceipt({
    required this.id,
    required this.requestNumber,
    required this.amount,
    required this.status,
    this.eventId,
    this.eventTitle,
    this.reason,
    this.sentAt,
  });

  bool get isRejected => status == 'rejected';

  @override
  List<Object?> get props => [id, requestNumber, amount, status, reason, sentAt];
}
