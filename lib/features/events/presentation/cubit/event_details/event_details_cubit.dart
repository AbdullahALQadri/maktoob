import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/guest_entity.dart';
import '../../../domain/repositories/events_repository.dart';
import '../../../domain/usecases/get_event_details_usecase.dart';
import 'event_details_state.dart';

class EventDetailsCubit extends Cubit<EventDetailsState> {
  final GetEventDetailsUseCase getEventDetailsUseCase;
  final EventsRepository eventsRepository;

  EventDetailsCubit({
    required this.getEventDetailsUseCase,
    required this.eventsRepository,
  }) : super(const EventDetailsState());

  /// Load event details and guests
  Future<void> loadEventDetails(String eventId) async {
    emit(state.copyWith(status: EventDetailsStatus.loading));

    final result = await getEventDetailsUseCase(
      GetEventDetailsParams(eventId: eventId),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: EventDetailsStatus.failure,
        errorMessage: failure.message,
      )),
      (details) => emit(state.copyWith(
        status: EventDetailsStatus.success,
        event: details.event,
        guests: details.guests,
        filteredGuests: details.guests,
      )),
    );
  }

  /// Change the current tab
  void changeTab(EventDetailsTab tab) {
    emit(state.copyWith(currentTab: tab));
  }

  /// Change tab by index
  void changeTabByIndex(int index) {
    final tab = EventDetailsTab.values[index];
    emit(state.copyWith(currentTab: tab));
  }

  /// Get current tab index
  int get currentTabIndex => state.currentTab.index;

  /// Search guests
  void searchGuests(String query) {
    final filteredGuests = state.guests.where((guest) {
      return guest.name.toLowerCase().contains(query.toLowerCase()) ||
          guest.email.toLowerCase().contains(query.toLowerCase()) ||
          guest.phone.contains(query);
    }).toList();

    emit(state.copyWith(
      guestSearchQuery: query,
      filteredGuests: filteredGuests,
    ));
  }

  /// Clear guest search
  void clearGuestSearch() {
    emit(state.copyWith(
      guestSearchQuery: '',
      filteredGuests: state.guests,
    ));
  }

  /// Filter guests by status
  void filterGuestsByStatus(GuestStatus? status) {
    List<GuestEntity> filteredGuests;

    if (status == null) {
      filteredGuests = state.guests;
    } else {
      filteredGuests = state.guests.where((g) => g.status == status).toList();
    }

    // Apply search query if exists
    if (state.guestSearchQuery.isNotEmpty) {
      filteredGuests = filteredGuests.where((guest) {
        return guest.name.toLowerCase().contains(state.guestSearchQuery.toLowerCase()) ||
            guest.email.toLowerCase().contains(state.guestSearchQuery.toLowerCase()) ||
            guest.phone.contains(state.guestSearchQuery);
      }).toList();
    }

    emit(state.copyWith(filteredGuests: filteredGuests));
  }

  /// Delete the event
  Future<bool> deleteEvent() async {
    if (state.event == null) return false;

    emit(state.copyWith(isDeleting: true));

    final result = await eventsRepository.deleteEvent(state.event!.id);

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isDeleting: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(isDeleting: false));
        return true;
      },
    );
  }

  /// Refresh event details
  Future<void> refreshEventDetails() async {
    if (state.event != null) {
      await loadEventDetails(state.event!.id);
    }
  }

  /// Get status label
  String getGuestStatusLabel(GuestStatus status) {
    switch (status) {
      case GuestStatus.attending:
        return 'Attending';
      case GuestStatus.pending:
        return 'Pending';
      case GuestStatus.declined:
        return 'Declined';
    }
  }
}
