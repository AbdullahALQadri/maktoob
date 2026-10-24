import 'package:equatable/equatable.dart';

/// Everything the host entered for one event, the same fields the portal and
/// the admin show (`GET /events/{id}` → `details`, App\Support\EventDetails).
class EventDetailsInfo extends Equatable {
  /// Wall-clock Gaza time, as the host announced it.
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? venueName;
  final String? venueAddress;

  /// A Google Maps link: the pin, else the link the host saved.
  final String? mapUrl;
  final String? description;
  final List<OccasionAnswer> occasionAnswers;
  final EventReplySettings replies;

  /// Only the texts the host wrote; the others use the platform default.
  final List<GuestMessage> messages;

  /// whatsapp | sms | email | app | manual
  final String? deliveryMethod;
  final EventBilling billing;
  final DateTime? invitationsSentAt;
  final DateTime? createdAt;

  const EventDetailsInfo({
    this.startsAt,
    this.endsAt,
    this.venueName,
    this.venueAddress,
    this.mapUrl,
    this.description,
    this.occasionAnswers = const [],
    this.replies = const EventReplySettings(),
    this.messages = const [],
    this.deliveryMethod,
    this.billing = const EventBilling(),
    this.invitationsSentAt,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        startsAt, endsAt, venueName, venueAddress, mapUrl, description, occasionAnswers,
        replies, messages, deliveryMethod, billing, invitationsSentAt, createdAt,
      ];
}

/// The host's answer to one of the occasion's questions (groom, bride, family…).
class OccasionAnswer extends Equatable {
  final String key;
  final String labelAr;
  final String labelEn;
  final String value;

  /// Printed on the invitation page as well.
  final bool onInvitation;

  const OccasionAnswer({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.value,
    this.onInvitation = false,
  });

  String label(String languageCode) => languageCode == 'en' ? labelEn : labelAr;

  @override
  List<Object?> get props => [key, labelAr, labelEn, value, onInvitation];
}

/// A text guests read (invitation, reply after accepting, thank-you…).
class GuestMessage extends Equatable {
  /// invitation | acceptance | refusal | ask_reason_prompt | ask_reason_question | thank_you
  final String key;
  final String? ar;
  final String? en;

  const GuestMessage({required this.key, this.ar, this.en});

  /// The text in [languageCode], else the one the host wrote.
  String text(String languageCode) => (languageCode == 'en' ? (en ?? ar) : (ar ?? en)) ?? '';

  @override
  List<Object?> get props => [key, ar, en];
}

/// How guests answer the invitation.
class EventReplySettings extends Equatable {
  final bool requireResponse;
  final DateTime? responseDeadline;
  final bool allowCompanions;

  /// 0 = not allowed, null = no limit.
  final int? maxCompanions;
  final bool askReason;

  const EventReplySettings({
    this.requireResponse = true,
    this.responseDeadline,
    this.allowCompanions = true,
    this.maxCompanions,
    this.askReason = false,
  });

  @override
  List<Object?> get props => [requireResponse, responseDeadline, allowCompanions, maxCompanions, askReason];
}

/// The package, the invitation allowance and the money (always ₪).
class EventBilling extends Equatable {
  final String? packageNameAr;
  final String? packageNameEn;
  final bool customPackage;

  /// Null = no limit.
  final int? invitationLimit;
  final int invitationsUsed;
  final String? invoiceNumber;
  final double? total;
  final double paid;

  const EventBilling({
    this.packageNameAr,
    this.packageNameEn,
    this.customPackage = false,
    this.invitationLimit,
    this.invitationsUsed = 0,
    this.invoiceNumber,
    this.total,
    this.paid = 0,
  });

  String? packageName(String languageCode) =>
      languageCode == 'en' ? (packageNameEn ?? packageNameAr) : (packageNameAr ?? packageNameEn);

  @override
  List<Object?> get props =>
      [packageNameAr, packageNameEn, customPackage, invitationLimit, invitationsUsed, invoiceNumber, total, paid];
}
