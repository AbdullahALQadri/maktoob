import 'package:equatable/equatable.dart';

import '../../../../core/utils/venue_text.dart';
import '../../../institution/domain/entities/event_role.dart';
import 'event_details_info.dart';

export '../../../institution/domain/entities/event_role.dart';
export 'event_details_info.dart';

/// Mirrors the backend enum: draft, pending_payment, active, completed,
/// cancelled.
enum EventStatus { active, draft, pendingPayment, completed, cancelled }

extension EventStatusApi on EventStatus {
  /// The backend's snake_case value.
  String get apiValue => switch (this) {
        EventStatus.active => 'active',
        EventStatus.draft => 'draft',
        EventStatus.pendingPayment => 'pending_payment',
        EventStatus.completed => 'completed',
        EventStatus.cancelled => 'cancelled',
      };

  /// Parses a backend status; unknown values fall back to [EventStatus.draft].
  static EventStatus parse(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'active':
        return EventStatus.active;
      case 'pending_payment':
        return EventStatus.pendingPayment;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
      case 'canceled':
        return EventStatus.cancelled;
      default:
        return EventStatus.draft;
    }
  }
}

class EventEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final String date;
  final String time;
  final String venue;
  final int? venueId;
  final String? venueAddress;
  final String? description;
  final int invitations;
  final int responses;
  final int attending;
  final int declined;
  final int pending;
  final int checkedIn;
  final EventStatus status;
  final DateTime? eventDate;
  final DateTime? rsvpDeadline;
  final String? packageName;
  final String? packagePrice;
  final String? templateName;
  final int maxCompanions;
  final bool allowCompanions;
  final String? imageUrl;

  /// The backend status string as sent.
  final String? rawStatus;

  /// The event's invoice total in ₪ (`invoice_total`), when known.
  final double? invoiceTotal;

  /// Door attendance (statistics): companions who came with checked-in
  /// guests, and everyone through the door (guests + companions).
  final int checkedInCompanions;
  final int attendees;

  /// The caller's role on this event (`my_role`): owner | manager |
  /// door_staff | viewer. Null on older payloads = treat as owner.
  final String? myRole;

  /// Delivery channels the event's package allows (`allowed_channels`).
  final List<String> allowedChannels;

  /// When the invitations first went out (`invitations_sent_at`).
  final DateTime? invitationsSentAt;

  /// The event's invitation allowance (sum of its packages, else
  /// `max_invitations`). Null = no limit configured.
  final int? invitationLimit;

  /// Invitations still available under [invitationLimit]
  /// (`remaining_invitations`, else limit − `invitations_used`).
  /// Null = unlimited.
  final int? remainingInvitations;

  /// Everything the host entered (`details`), on the event's own page only.
  final EventDetailsInfo? details;

  const EventEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.time,
    required this.venue,
    this.venueId,
    this.venueAddress,
    this.description,
    required this.invitations,
    required this.responses,
    required this.attending,
    this.declined = 0,
    this.pending = 0,
    this.checkedIn = 0,
    required this.status,
    this.eventDate,
    this.rsvpDeadline,
    this.packageName,
    this.packagePrice,
    this.templateName,
    this.maxCompanions = 2,
    this.allowCompanions = true,
    this.imageUrl,
    this.rawStatus,
    this.invoiceTotal,
    this.checkedInCompanions = 0,
    this.attendees = 0,
    this.myRole,
    this.allowedChannels = const ['whatsapp'],
    this.invitationsSentAt,
    this.invitationLimit,
    this.remainingInvitations,
    this.details,
  });

  bool get isActive => status == EventStatus.active;

  /// Where the occasion is, on one line (the address only when it adds to the name).
  String get venueLine => VenueText.line(venue, venueAddress);

  /// Host-side guest actions (send, add, resend, remove) need a live event.
  bool get canManageGuests => isActive && role.canManage;

  /// Owner may cancel anything not already finished.
  bool get canCancel =>
      role.canOwn &&
      status != EventStatus.cancelled &&
      status != EventStatus.completed;

  /// Role-based permissions (institution team members).
  EventRole get role => EventRole.fromString(myRole);

  /// Saved, waiting for the host to pay before it goes live.
  bool get isPendingPayment =>
      status == EventStatus.pendingPayment || rawStatus == 'pending_payment';

  double get responseRate =>
      invitations > 0 ? (responses / invitations) * 100 : 0;

  int get other => responses - attending;

  bool get isInactive =>
      status == EventStatus.draft ||
      status == EventStatus.pendingPayment ||
      status == EventStatus.completed ||
      status == EventStatus.cancelled;

  @override
  List<Object?> get props => [
        myRole,
        allowedChannels,
        invitationsSentAt,
        invitationLimit,
        remainingInvitations,
        details,
        id,
        name,
        type,
        date,
        time,
        venue,
        venueId,
        venueAddress,
        description,
        invitations,
        responses,
        attending,
        declined,
        pending,
        checkedIn,
        status,
        eventDate,
        rsvpDeadline,
        packageName,
        packagePrice,
        templateName,
        maxCompanions,
        allowCompanions,
        imageUrl,
        rawStatus,
        invoiceTotal,
        checkedInCompanions,
        attendees,
      ];
}
