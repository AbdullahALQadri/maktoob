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

  /// A payment request for this event is awaiting admin review.
  final bool hasPendingPayment;

  /// A guest action (send / add / resend / remove / cancel) is in flight.
  final bool isBusy;

  /// Translation key of the last successful action, shown once as a snack.
  /// [noticeArgs] fills its `{count}` placeholder.
  final String? notice;
  final int noticeCount;

  const EventDetailsState({
    this.status = EventDetailsStatus.initial,
    this.event,
    this.guests = const [],
    this.filteredGuests = const [],
    this.currentTab = EventDetailsTab.overview,
    this.guestSearchQuery = '',
    this.errorMessage,
    this.isDeleting = false,
    this.hasPendingPayment = false,
    this.isBusy = false,
    this.notice,
    this.noticeCount = 0,
  });

  bool get isLoading => status == EventDetailsStatus.loading;
  bool get isSuccess => status == EventDetailsStatus.success;
  bool get isFailure => status == EventDetailsStatus.failure;
  bool get hasEvent => event != null;

  int get attendingCount => guests.where((g) => g.status == GuestStatus.attending).length;
  int get pendingCount => guests.where((g) => g.status == GuestStatus.pending).length;
  int get declinedCount => guests.where((g) => g.status == GuestStatus.declined).length;
  int get checkedInCount => guests.where((g) => g.isCheckedIn).length;

  /// Invitations that haven't gone out yet (new, or a failed send).
  int get unsentCount => guests
      .where((g) => g.invitationStatus == 'pending' || g.invitationStatus == 'failed')
      .length;

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
    bool? hasPendingPayment,
    bool? isBusy,
    String? notice,
    int? noticeCount,
    bool clearNotice = false,
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
      hasPendingPayment: hasPendingPayment ?? this.hasPendingPayment,
      isBusy: isBusy ?? this.isBusy,
      notice: clearNotice ? null : (notice ?? this.notice),
      noticeCount: noticeCount ?? this.noticeCount,
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
        hasPendingPayment,
        isBusy,
        notice,
        noticeCount,
      ];
}
