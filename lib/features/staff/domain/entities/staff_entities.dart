import 'package:equatable/equatable.dart';

/// A member of the Maktoob team signed in to the staff mode.
class StaffUser extends Equatable {
  const StaffUser({required this.name, this.email});

  final String name;
  final String? email;

  @override
  List<Object?> get props => [name, email];
}

/// What is waiting today. A queue this member may not review is null.
class StaffToday extends Equatable {
  const StaffToday({
    this.paymentRequestsPending,
    this.identitiesPending,
    this.institutionsPending,
    this.eventsToday,
    this.eventsAwaitingPayment,
  });

  final int? paymentRequestsPending;
  final int? identitiesPending;
  final int? institutionsPending;
  final int? eventsToday;
  final int? eventsAwaitingPayment;

  @override
  List<Object?> get props =>
      [paymentRequestsPending, identitiesPending, institutionsPending, eventsToday, eventsAwaitingPayment];
}

/// A payment a client sent for review: a first payment, or more invitations.
class StaffPaymentRequest extends Equatable {
  const StaffPaymentRequest({
    required this.id,
    required this.amount,
    required this.status,
    this.clientName,
    this.clientPhone,
    this.eventTitle,
    this.method,
    this.walletProvider,
    this.isUpgrade = false,
    this.targetInvitations,
    this.clientNotes,
    this.adminNotes,
    this.originalCurrency,
    this.originalAmount,
    this.createdAt,
    this.imageUrls = const [],
  });

  final int id;

  /// In shekels, computed by the server.
  final double amount;

  /// `pending`, `approved` or `rejected`.
  final String status;
  final String? clientName;
  final String? clientPhone;
  final String? eventTitle;

  /// `cash`, `bank_transfer` or `wallet`.
  final String? method;
  final String? walletProvider;
  final bool isUpgrade;
  final int? targetInvitations;
  final String? clientNotes;
  final String? adminNotes;

  /// Set when the client paid in another currency.
  final String? originalCurrency;
  final double? originalAmount;
  final DateTime? createdAt;

  /// The receipt images.
  final List<String> imageUrls;

  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
        id,
        amount,
        status,
        clientName,
        clientPhone,
        eventTitle,
        method,
        walletProvider,
        isUpgrade,
        targetInvitations,
        clientNotes,
        adminNotes,
        originalCurrency,
        originalAmount,
        createdAt,
        imageUrls,
      ];
}

class StaffClientRow extends Equatable {
  const StaffClientRow({
    required this.id,
    required this.name,
    this.phone,
    this.isActive = true,
    this.isVerified = false,
    this.isInstitution = false,
    this.eventsCount = 0,
  });

  final int id;
  final String name;
  final String? phone;
  final bool isActive;

  /// The mobile number was confirmed by a code.
  final bool isVerified;
  final bool isInstitution;
  final int eventsCount;

  @override
  List<Object?> get props => [id, name, phone, isActive, isVerified, isInstitution, eventsCount];
}

class StaffEventRow extends Equatable {
  const StaffEventRow({
    required this.id,
    required this.title,
    required this.status,
    this.date,
    this.clientName,
    this.invitationsCount = 0,
  });

  final int id;
  final String title;

  /// `draft`, `pending_payment`, `active`, `completed` or `cancelled`.
  final String status;
  final DateTime? date;
  final String? clientName;
  final int invitationsCount;

  @override
  List<Object?> get props => [id, title, status, date, clientName, invitationsCount];
}
