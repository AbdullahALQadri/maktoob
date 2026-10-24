import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/guest_entity.dart';
import '../../../domain/entities/event_entity.dart';
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
    emit(state.copyWith(status: EventDetailsStatus.loading, clearErrorMessage: true));

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
        clearErrorMessage: true,
      )),
    );

    final event = state.event;
    if (event != null && event.isPendingPayment) {
      final pending = await eventsRepository.hasPendingPaymentRequest(eventId);
      if (!isClosed) emit(state.copyWith(hasPendingPayment: pending));
    }
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

  // ---- Guest actions on a live event --------------------------------------

  /// Send every invitation that hasn't gone out yet (first send, or guests
  /// added since). The server only ever sends `pending` rows.
  Future<bool> sendInvitations(String method) {
    return _runAction<Map<String, dynamic>>(
      (id) => eventsRepository.sendInvitations(id, method),
      onSuccess: (r) => _notice('event_invitations_sent', r['dispatched']),
    );
  }

  /// Add guests by name + phone. Before the first send they wait as unsent;
  /// after it they're sent right away (server side).
  Future<bool> addGuests(List<Map<String, String>> guests) {
    return _runAction<Map<String, dynamic>>(
      (id) => eventsRepository.addGuests(id, guests),
      onSuccess: (r) {
        final created = _int(r['created']);
        final invalid = (r['invalid_phones'] as List?)?.length ?? 0;
        final dupes = _int(r['duplicates']);
        final overLimit = _int(r['over_limit_count']);
        if (created == 0 && overLimit > 0) {
          emit(state.copyWith(errorMessage: 'event_guests_over_limit'));
        } else if (created == 0 && invalid > 0) {
          emit(state.copyWith(errorMessage: 'event_guests_invalid_phone'));
        } else if (created == 0 && dupes > 0) {
          emit(state.copyWith(errorMessage: 'event_guests_already_invited'));
        } else {
          // Some rows didn't fit the package: say so instead of a plain "added".
          _notice(
            overLimit > 0
                ? 'event_guests_added_partial'
                : (_int(r['sent']) > 0 ? 'event_guests_added_sent' : 'event_guests_added'),
            created,
          );
        }
      },
    );
  }

  Future<bool> resendInvitation(String invitationId) {
    return _runAction(
      (_) => eventsRepository.resendInvitation(invitationId),
      onSuccess: (_) => _notice('event_invitation_resent', 1),
    );
  }

  Future<bool> removeInvitation(String invitationId) {
    return _runAction(
      (_) => eventsRepository.removeInvitation(invitationId),
      onSuccess: (_) => _notice('event_guest_removed', 1),
    );
  }

  /// Cancel the event (owner). Guests can no longer answer.
  Future<bool> cancelEvent() {
    return _runAction(
      (id) => eventsRepository.updateEvent(
        id,
        const UpdateEventParams(status: EventStatus.cancelled),
      ),
      onSuccess: (_) => _notice('event_cancelled_notice', 1),
    );
  }

  Future<bool> _runAction<T>(
    Future<dynamic> Function(String eventId) call, {
    required void Function(T result) onSuccess,
  }) async {
    final event = state.event;
    if (event == null || state.isBusy) return false;
    emit(state.copyWith(isBusy: true, clearErrorMessage: true, clearNotice: true));

    final result = await call(event.id);
    if (isClosed) return false;

    return await result.fold(
      (failure) async {
        // Offline: queued, sent when the connection returns.
        if (failure is QueuedOfflineFailure) {
          emit(state.copyWith(isBusy: false));
          _notice(failure.message!, 1);
          return true;
        }
        emit(state.copyWith(isBusy: false, errorMessage: failure.message));
        return false;
      },
      (value) async {
        onSuccess(value as T);
        await _reloadSilently(event.id);
        if (!isClosed) emit(state.copyWith(isBusy: false));
        return true;
      },
    );
  }

  void _notice(String key, dynamic count) {
    emit(state.copyWith(notice: key, noticeCount: _int(count)));
  }

  static int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  /// Reload without the full-screen skeleton (after an action).
  Future<void> _reloadSilently(String eventId) async {
    final result = await getEventDetailsUseCase(GetEventDetailsParams(eventId: eventId));
    if (isClosed) return;
    result.fold((_) {}, (details) {
      final query = state.guestSearchQuery;
      emit(state.copyWith(event: details.event, guests: details.guests, filteredGuests: details.guests));
      if (query.isNotEmpty) searchGuests(query);
    });
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
