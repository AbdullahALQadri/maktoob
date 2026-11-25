import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/staff_entities.dart';
import '../../domain/usecases/staff_usecases.dart';

class StaffRequestState extends Equatable {
  const StaffRequestState({this.request, this.loading = true, this.busy = false, this.message, this.reviewed});

  final StaffPaymentRequest? request;
  final bool loading;

  /// A decision is being sent.
  final bool busy;

  /// A one-off problem to show.
  final String? message;

  /// Set once the decision was saved: true = approved, false = refused.
  final bool? reviewed;

  StaffRequestState copyWith({bool? busy, String? message, bool? reviewed}) => StaffRequestState(
        request: request,
        loading: false,
        busy: busy ?? this.busy,
        message: message,
        reviewed: reviewed ?? this.reviewed,
      );

  @override
  List<Object?> get props => [request, loading, busy, message, reviewed];
}

/// One payment request open for review.
class StaffRequestCubit extends Cubit<StaffRequestState> {
  StaffRequestCubit({required this.getRequest, required this.review, required this.id})
      : super(const StaffRequestState());

  final GetStaffPaymentRequestUseCase getRequest;
  final ReviewStaffPaymentRequestUseCase review;
  final int id;

  Future<void> load() async {
    emit(const StaffRequestState());
    final result = await getRequest(id);
    if (isClosed) return;
    emit(result.fold(
      (failure) => StaffRequestState(loading: false, message: failure.message ?? ''),
      (request) => StaffRequestState(request: request, loading: false),
    ));
  }

  Future<void> approve([String note = '']) => _send(StaffReview.approve(id, note: note));

  /// A refusal needs its reason: the client reads it.
  Future<void> reject(String reason) async {
    if (reason.trim().isEmpty) return emit(state.copyWith(message: 'staff_reason_required'));
    await _send(StaffReview.reject(id, reason));
  }

  Future<void> _send(StaffReview decision) async {
    if (state.busy || state.reviewed != null) return;
    emit(state.copyWith(busy: true));
    final result = await review(decision);
    if (isClosed) return;
    emit(result.fold(
      (failure) => state.copyWith(busy: false, message: failure.message ?? ''),
      (_) => state.copyWith(busy: false, reviewed: decision.approve),
    ));
  }
}
