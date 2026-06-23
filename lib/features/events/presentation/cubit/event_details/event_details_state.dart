import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/guest_entity.dart';

enum EventDetailsStatus { initial, loading, success, failure }

enum EventDetailsTab { overview, guests, details }

class EventDetailsState extends Equatable {
  final EventDetailsStatus status;
  final EventEntity? event;
  final List<GuestEntity> guests;
  final List<GuestEntity> filteredGuests;
  final EventDetailsTab currentTab;
  final String guestSearchQuery;
  final String? errorMessage;
  final bool isDeleting;
  final bool isSending;

  const EventDetailsState({
    this.status = EventDetailsStatus.initial,
    this.event,
    this.guests = const [],
    this.filteredGuests = const [],
    this.currentTab = EventDetailsTab.overview,
    this.guestSearchQuery = '',
    this.errorMessage,
    this.isDeleting = false,
    this.isSending = false,
  });

  bool get isLoading => status == EventDetailsStatus.loading;
  bool get isSuccess => status == EventDetailsStatus.success;
  bool get isFailure => status == EventDetailsStatus.failure;
  bool get hasEvent => event != null;

  int get attendingCount => guests.where((g) => g.status == GuestStatus.attending).length;
  int get pendingCount => guests.where((g) => g.status == GuestStatus.pending).length;
  int get declinedCount => guests.where((g) => g.status == GuestStatus.declined).length;
  int get checkedInCount => guests.where((g) => g.isCheckedIn).length;

  double get responseRate {
    if (event == null || event!.invitations == 0) return 0;
    return (event!.responses / event!.invitations) * 100;
  }

  double get attendingRate {
    if (event == null || event!.responses == 0) return 0;
    return (event!.attending / event!.responses) * 100;
  }

  double get checkedInRate {
    if (attendingCount == 0) return 0;
    return (checkedInCount / attendingCount) * 100;
  }

  EventDetailsState copyWith({
    EventDetailsStatus? status,
    EventEntity? event,
    List<GuestEntity>? guests,
    List<GuestEntity>? filteredGuests,
    EventDetailsTab? currentTab,
    String? guestSearchQuery,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isDeleting,
    bool? isSending,
  }) {
    return EventDetailsState(
      status: status ?? this.status,
      event: event ?? this.event,
      guests: guests ?? this.guests,
      filteredGuests: filteredGuests ?? this.filteredGuests,
      currentTab: currentTab ?? this.currentTab,
      guestSearchQuery: guestSearchQuery ?? this.guestSearchQuery,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isDeleting: isDeleting ?? this.isDeleting,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [
        status,
        event,
        guests,
        filteredGuests,
        currentTab,
        guestSearchQuery,
        errorMessage,
        isDeleting,
        isSending,
      ];
}
