import 'package:equatable/equatable.dart';

enum GuestStatus { attending, pending, declined }

class GuestEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final GuestStatus status;
  final int companions;
  final bool isCheckedIn;

  /// Public invitation page (/i/{short_url}); its QR encodes this URL and the
  /// door scanner accepts it.
  final String? invitationUrl;

  /// Delivery status of the invitation itself: pending/sent/delivered/opened/...
  final String? invitationStatus;
  final DateTime? sentAt;
  final DateTime? openedAt;
  final DateTime? respondedAt;
  final DateTime? checkedInAt;

  const GuestEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.companions = 0,
    this.isCheckedIn = false,
    this.invitationUrl,
    this.invitationStatus,
    this.sentAt,
    this.openedAt,
    this.respondedAt,
    this.checkedInAt,
  });

  bool get isValid => name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        status,
        companions,
        isCheckedIn,
        invitationUrl,
        invitationStatus,
        sentAt,
        openedAt,
        respondedAt,
        checkedInAt,
      ];
}
