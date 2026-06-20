import 'package:equatable/equatable.dart';

enum EventStatus { active, draft, completed }

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
  });

  double get responseRate =>
      invitations > 0 ? (responses / invitations) * 100 : 0;

  int get other => responses - attending;

  bool get isInactive =>
      status == EventStatus.draft || status == EventStatus.completed;

  @override
  List<Object?> get props => [
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
      ];
}
