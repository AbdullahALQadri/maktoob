import 'package:equatable/equatable.dart';

/// Where an extra service stands on a paid event. Only moves forward:
/// requested → awaitingPayment → confirmed → completed, or declined /
/// withdrawn. `pending` is a service bought with the original invoice.
enum AddOnStatus {
  pending,
  requested,
  awaitingPayment,
  confirmed,
  completed,
  declined,
  withdrawn,
  cancelled;

  static AddOnStatus fromApi(String? value) => switch (value) {
        'requested' => AddOnStatus.requested,
        'awaiting_payment' => AddOnStatus.awaitingPayment,
        'confirmed' => AddOnStatus.confirmed,
        'completed' => AddOnStatus.completed,
        'declined' => AddOnStatus.declined,
        'withdrawn' => AddOnStatus.withdrawn,
        'cancelled' => AddOnStatus.cancelled,
        _ => AddOnStatus.pending,
      };

  /// Translation key for the status chip.
  String get labelKey => switch (this) {
        AddOnStatus.requested => 'add_on_status_requested',
        AddOnStatus.awaitingPayment => 'add_on_status_awaiting_payment',
        AddOnStatus.confirmed => 'add_on_status_confirmed',
        AddOnStatus.completed => 'add_on_status_completed',
        AddOnStatus.declined => 'add_on_status_declined',
        AddOnStatus.withdrawn => 'add_on_status_withdrawn',
        AddOnStatus.cancelled => 'add_on_status_cancelled',
        AddOnStatus.pending => 'add_on_status_included',
      };
}

/// A service on the event (from the invoice, or requested after payment).
class EventAddOnEntity extends Equatable {
  final int serviceId;
  final String nameAr;
  final String? nameEn;
  final int quantity;
  final double totalPrice;
  final AddOnStatus status;
  final String? decisionNote;
  final bool canWithdraw;

  const EventAddOnEntity({
    required this.serviceId,
    required this.nameAr,
    this.nameEn,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.decisionNote,
    required this.canWithdraw,
  });

  String name(bool isArabic) =>
      isArabic || (nameEn ?? '').isEmpty ? nameAr : nameEn!;

  @override
  List<Object?> get props =>
      [serviceId, nameAr, nameEn, quantity, totalPrice, status, decisionNote, canWithdraw];
}

/// A catalogue service the host may still ask for.
class OfferedServiceEntity extends Equatable {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;

  const OfferedServiceEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
  });

  String name(bool isArabic) =>
      isArabic || (nameEn ?? '').isEmpty ? nameAr : nameEn!;

  String? description(bool isArabic) =>
      isArabic || (descriptionEn ?? '').isEmpty ? descriptionAr : descriptionEn;

  @override
  List<Object?> get props => [id, nameAr, nameEn, descriptionAr, descriptionEn, price];
}

/// GET /events/{id}/add-ons: the event's services, what can be asked for,
/// and what is due (only the approved services' own price).
class EventAddOnsEntity extends Equatable {
  final bool canRequest;
  final List<EventAddOnEntity> services;
  final List<OfferedServiceEntity> available;
  final double amountDue;
  final bool paymentUnderReview;

  const EventAddOnsEntity({
    required this.canRequest,
    required this.services,
    required this.available,
    required this.amountDue,
    required this.paymentUnderReview,
  });

  bool get canPay => amountDue > 0 && !paymentUnderReview;

  @override
  List<Object?> get props => [canRequest, services, available, amountDue, paymentUnderReview];
}
