import 'package:equatable/equatable.dart';
import '../../../domain/entities/edit_request_entity.dart';
import '../../../domain/entities/event_entity.dart';

enum EditEventStatus { initial, loading, loaded, saving, saved, submittingRequest, requestSubmitted, failure }

class EditEventState extends Equatable {
  final EditEventStatus status;
  final EventEntity? event;

  /// Unpaid (draft or waiting for payment): saved at once. Active: sent to
  /// the team as a request. Same rule as the portal (Event::DETAILS_EDITABLE).
  final bool editsDirectly;

  // Form fields
  final String name;

  /// The place on one line (an older separate address is folded in).
  final String venue;
  final String? description;
  final DateTime? eventDate;
  final DateTime? rsvpDeadline;
  final int maxCompanions;
  final bool allowCompanions;

  /// The occasion's answers (groom, bride, family…) by key; edited directly only.
  final Map<String, String> answers;

  /// Set on a direct save that changed what the card prints while a card exists.
  final bool redoDesign;

  // Edit requests (for active events)
  final List<EditRequestEntity> previousRequests;
  final String? errorMessage;

  const EditEventState({
    this.status = EditEventStatus.initial,
    this.event,
    this.editsDirectly = true,
    this.name = '',
    this.venue = '',
    this.description,
    this.eventDate,
    this.rsvpDeadline,
    this.maxCompanions = 2,
    this.allowCompanions = true,
    this.answers = const {},
    this.redoDesign = false,
    this.previousRequests = const [],
    this.errorMessage,
  });

  bool get isLoading => status == EditEventStatus.loading;
  bool get isSaving => status == EditEventStatus.saving || status == EditEventStatus.submittingRequest;
  bool get isSuccess => status == EditEventStatus.saved || status == EditEventStatus.requestSubmitted;

  /// One request at a time: the team reviews it before another can be sent.
  bool get hasPendingRequest => !editsDirectly && previousRequests.any((r) => r.status == EditRequestStatus.pending);

  bool get canSave => hasChanges && !hasPendingRequest;

  bool get placeChanged => event != null && venue.trim() != event!.venueLine;

  /// The answers as the event has them now.
  List<OccasionAnswer> get savedAnswers => event?.details?.occasionAnswers ?? const [];

  bool get answersChanged => editsDirectly && savedAnswers.any((a) => (answers[a.key] ?? a.value).trim() != a.value);

  /// What the invitation card prints: names, title, date, place.
  bool get cardDetailsChanged =>
      event != null && (name != event!.name || placeChanged || eventDate != event!.eventDate || answersChanged);

  bool get hasChanges {
    if (event == null) return false;
    return name != event!.name ||
        placeChanged ||
        description != event!.description ||
        eventDate != event!.eventDate ||
        rsvpDeadline != event!.rsvpDeadline ||
        maxCompanions != event!.maxCompanions ||
        allowCompanions != event!.allowCompanions ||
        answersChanged;
  }

  EditEventState copyWith({
    EditEventStatus? status,
    EventEntity? event,
    bool? editsDirectly,
    String? name,
    String? venue,
    String? description,
    DateTime? eventDate,
    DateTime? rsvpDeadline,
    int? maxCompanions,
    bool? allowCompanions,
    Map<String, String>? answers,
    bool? redoDesign,
    List<EditRequestEntity>? previousRequests,
    String? errorMessage,
  }) {
    return EditEventState(
      status: status ?? this.status,
      event: event ?? this.event,
      editsDirectly: editsDirectly ?? this.editsDirectly,
      name: name ?? this.name,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      rsvpDeadline: rsvpDeadline ?? this.rsvpDeadline,
      maxCompanions: maxCompanions ?? this.maxCompanions,
      allowCompanions: allowCompanions ?? this.allowCompanions,
      answers: answers ?? this.answers,
      redoDesign: redoDesign ?? this.redoDesign,
      previousRequests: previousRequests ?? this.previousRequests,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    event,
    editsDirectly,
    name,
    venue,
    description,
    eventDate,
    rsvpDeadline,
    maxCompanions,
    allowCompanions,
    answers,
    redoDesign,
    previousRequests,
    errorMessage,
  ];
}
