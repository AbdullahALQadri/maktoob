import 'package:equatable/equatable.dart';
import '../../../domain/entities/edit_request_entity.dart';
import '../../../domain/entities/event_entity.dart';

enum EditEventStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  submittingRequest,
  requestSubmitted,
  failure,
}

class EditEventState extends Equatable {
  final EditEventStatus status;
  final EventEntity? event;
  final bool isDraft;

  // Form fields
  final String name;
  final String venue;
  final String? venueAddress;
  final String? description;
  final DateTime? eventDate;
  final DateTime? rsvpDeadline;
  final int maxCompanions;
  final bool allowCompanions;

  // Edit requests (for active events)
  final List<EditRequestEntity> previousRequests;
  final String? errorMessage;

  const EditEventState({
    this.status = EditEventStatus.initial,
    this.event,
    this.isDraft = true,
    this.name = '',
    this.venue = '',
    this.venueAddress,
    this.description,
    this.eventDate,
    this.rsvpDeadline,
    this.maxCompanions = 2,
    this.allowCompanions = true,
    this.previousRequests = const [],
    this.errorMessage,
  });

  bool get isLoading => status == EditEventStatus.loading;
  bool get isSaving =>
      status == EditEventStatus.saving ||
      status == EditEventStatus.submittingRequest;
  bool get isSuccess =>
      status == EditEventStatus.saved ||
      status == EditEventStatus.requestSubmitted;

  bool get hasChanges {
    if (event == null) return false;
    return name != event!.name ||
        venue != event!.venue ||
        venueAddress != event!.venueAddress ||
        description != event!.description ||
        eventDate != event!.eventDate ||
        rsvpDeadline != event!.rsvpDeadline ||
        maxCompanions != event!.maxCompanions ||
        allowCompanions != event!.allowCompanions;
  }

  EditEventState copyWith({
    EditEventStatus? status,
    EventEntity? event,
    bool? isDraft,
    String? name,
    String? venue,
    String? venueAddress,
    String? description,
    DateTime? eventDate,
    DateTime? rsvpDeadline,
    int? maxCompanions,
    bool? allowCompanions,
    List<EditRequestEntity>? previousRequests,
    String? errorMessage,
  }) {
    return EditEventState(
      status: status ?? this.status,
      event: event ?? this.event,
      isDraft: isDraft ?? this.isDraft,
      name: name ?? this.name,
      venue: venue ?? this.venue,
      venueAddress: venueAddress ?? this.venueAddress,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      rsvpDeadline: rsvpDeadline ?? this.rsvpDeadline,
      maxCompanions: maxCompanions ?? this.maxCompanions,
      allowCompanions: allowCompanions ?? this.allowCompanions,
      previousRequests: previousRequests ?? this.previousRequests,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        event,
        isDraft,
        name,
        venue,
        venueAddress,
        description,
        eventDate,
        rsvpDeadline,
        maxCompanions,
        allowCompanions,
        previousRequests,
        errorMessage,
      ];
}
