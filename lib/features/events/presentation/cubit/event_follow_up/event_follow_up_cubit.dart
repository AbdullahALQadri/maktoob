import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/event_follow_up.dart';
import '../../../domain/usecases/event_follow_up_usecases.dart';

class EventFollowUpState extends Equatable {
  const EventFollowUpState({
    this.progress,
    this.activity = const [],
    this.resending = false,
    this.message,
    this.messageIsError = false,
    this.messageCount = 0,
  });

  final EventProgress? progress;
  final List<ActivityItem> activity;
  final bool resending;

  /// A translation key (ours) or server text, shown once as a snackbar.
  final String? message;
  final bool messageIsError;
  final int messageCount;

  EventFollowUpState copyWith({
    EventProgress? progress,
    List<ActivityItem>? activity,
    bool? resending,
    String? message,
    bool messageIsError = false,
    int messageCount = 0,
  }) => EventFollowUpState(
    progress: progress ?? this.progress,
    activity: activity ?? this.activity,
    resending: resending ?? this.resending,
    message: message,
    messageIsError: messageIsError,
    messageCount: messageCount,
  );

  @override
  List<Object?> get props => [progress, activity, resending, message, messageIsError, messageCount];
}

/// The event page's follow-up: setup steps, latest activity, resending what
/// did not arrive and fixing a guest before sending.
class EventFollowUpCubit extends Cubit<EventFollowUpState> {
  EventFollowUpCubit({
    required this.getFollowUp,
    required this.resendFailedInvitations,
    required this.updateUnsentGuest,
  }) : super(const EventFollowUpState());

  final GetEventFollowUpUseCase getFollowUp;
  final ResendFailedInvitationsUseCase resendFailedInvitations;
  final UpdateUnsentGuestUseCase updateUnsentGuest;

  Future<void> load(String eventId) async {
    final results = await Future.wait([getFollowUp.progress(eventId), getFollowUp.activity(eventId)]);
    if (isClosed) return;
    final progress = results[0].fold((_) => null, (p) => p as EventProgress);
    final activity = results[1].fold((_) => null, (a) => a as List<ActivityItem>);
    emit(state.copyWith(progress: progress, activity: activity));
  }

  Future<void> resendFailed(String eventId) async {
    if (state.resending) return;
    emit(state.copyWith(resending: true));
    final result = await resendFailedInvitations(eventId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(resending: false, message: failure.message, messageIsError: true)),
      (sent) => emit(state.copyWith(resending: false, message: 'event_resend_failed_done', messageCount: sent)),
    );
  }

  /// True when saved; a refusal (a sent invitation, a bad number) shows why.
  Future<bool> fixGuest(String eventId, String invitationId, {required String name, required String phone}) async {
    final result = await updateUnsentGuest(eventId, invitationId, name: name, phone: phone);
    if (isClosed) return false;
    return result.fold(
      (failure) {
        emit(state.copyWith(message: failure.message, messageIsError: true));
        return false;
      },
      (_) {
        emit(state.copyWith(message: 'event_guest_fixed'));
        return true;
      },
    );
  }
}
