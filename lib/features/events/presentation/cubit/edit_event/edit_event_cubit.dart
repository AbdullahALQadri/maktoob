import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/repositories/events_repository.dart';
import 'edit_event_state.dart';

class EditEventCubit extends Cubit<EditEventState> {
  final EventsRepository eventsRepository;

  EditEventCubit({required this.eventsRepository}) : super(const EditEventState());

  void initializeWithEvent(EventEntity event) {
    final editsDirectly = event.detailsEditable;

    emit(
      state.copyWith(
        status: EditEventStatus.loaded,
        event: event,
        editsDirectly: editsDirectly,
        answers: {for (final a in event.details?.occasionAnswers ?? const []) a.key: a.value},
        name: event.name,
        venue: event.venueLine,
        description: event.description,
        eventDate: event.eventDate,
        rsvpDeadline: event.rsvpDeadline,
        maxCompanions: event.maxCompanions,
        allowCompanions: event.allowCompanions,
      ),
    );

    if (!editsDirectly) {
      _loadEditRequests(event.id);
    }
  }

  void updateAnswer(String key, String value) => emit(state.copyWith(answers: {...state.answers, key: value}));

  Future<void> _loadEditRequests(String eventId) async {
    final result = await eventsRepository.getEditRequests(eventId);
    result.fold((_) {}, (requests) => emit(state.copyWith(previousRequests: requests)));
  }

  void updateName(String value) => emit(state.copyWith(name: value));
  void updateVenue(String value) => emit(state.copyWith(venue: value));
  void updateDescription(String value) => emit(state.copyWith(description: value));
  void updateEventDate(DateTime value) => emit(state.copyWith(eventDate: value));
  void updateRsvpDeadline(DateTime value) => emit(state.copyWith(rsvpDeadline: value));
  void updateMaxCompanions(int value) => emit(state.copyWith(maxCompanions: value));
  void updateAllowCompanions(bool value) {
    if (value) {
      // When enabling, restore default if was 0
      emit(state.copyWith(allowCompanions: true, maxCompanions: state.maxCompanions == 0 ? 2 : state.maxCompanions));
    } else {
      // When disabling, set max companions to 0
      emit(state.copyWith(allowCompanions: false, maxCompanions: 0));
    }
  }

  Future<bool> saveChanges() async {
    if (!state.hasChanges) return false;

    final params = UpdateEventParams(
      name: state.name != state.event!.name ? state.name : null,
      // The place is one line: a changed place clears the old separate address.
      venue: state.placeChanged ? state.venue.trim() : null,
      venueAddress: state.placeChanged ? '' : null,
      description: state.description != state.event!.description ? state.description : null,
      eventDate: state.eventDate != state.event!.eventDate ? state.eventDate : null,
      rsvpDeadline: state.rsvpDeadline != state.event!.rsvpDeadline ? state.rsvpDeadline : null,
      maxCompanions: state.maxCompanions != state.event!.maxCompanions ? state.maxCompanions : null,
      allowCompanions: state.allowCompanions != state.event!.allowCompanions ? state.allowCompanions : null,
      // The backend replaces the whole map, so every answer goes, trimmed.
      occasionAnswers: state.answersChanged
          ? {for (final a in state.savedAnswers) a.key: (state.answers[a.key] ?? a.value).trim()}
          : null,
    );

    if (state.editsDirectly) {
      return _directUpdate(params);
    } else {
      return _submitEditRequest(params);
    }
  }

  Future<bool> _directUpdate(UpdateEventParams params) async {
    // A card already drawn still prints the old names / date / place.
    final redoDesign = (state.event!.imageUrl ?? '').isNotEmpty && state.cardDetailsChanged;
    emit(state.copyWith(status: EditEventStatus.saving));

    final result = await eventsRepository.updateEvent(state.event!.id, params);

    return result.fold(
      (failure) {
        emit(state.copyWith(status: EditEventStatus.failure, errorMessage: failure.message));
        return false;
      },
      (updatedEvent) {
        emit(state.copyWith(status: EditEventStatus.saved, event: updatedEvent, redoDesign: redoDesign));
        return true;
      },
    );
  }

  Future<bool> _submitEditRequest(UpdateEventParams params) async {
    emit(state.copyWith(status: EditEventStatus.submittingRequest));

    final result = await eventsRepository.submitEditRequest(state.event!.id, params);

    return result.fold(
      (failure) {
        emit(state.copyWith(status: EditEventStatus.failure, errorMessage: failure.message));
        return false;
      },
      (editRequest) {
        final updatedRequests = [editRequest, ...state.previousRequests];
        emit(state.copyWith(status: EditEventStatus.requestSubmitted, previousRequests: updatedRequests));
        return true;
      },
    );
  }
}
