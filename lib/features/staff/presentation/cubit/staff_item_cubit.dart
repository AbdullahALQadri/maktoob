import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/staff_usecases.dart';

class StaffItemState<T> extends Equatable {
  const StaffItemState({this.item, this.loading = true, this.busy = false, this.message, this.reviewed});

  final T? item;
  final bool loading;

  /// A decision is being sent.
  final bool busy;

  /// A one-off problem to show.
  final String? message;

  /// Set once the decision was saved: true = approved, false = refused.
  final bool? reviewed;

  StaffItemState<T> copyWith({bool? busy, String? message, bool? reviewed}) => StaffItemState<T>(
        item: item,
        loading: false,
        busy: busy ?? this.busy,
        message: message,
        reviewed: reviewed ?? this.reviewed,
      );

  @override
  List<Object?> get props => [item, loading, busy, message, reviewed];
}

/// One review open on the screen: what was sent, and the decision.
class StaffItemCubit<T> extends Cubit<StaffItemState<T>> {
  StaffItemCubit({required this.read, required this.review, required this.id}) : super(StaffItemState<T>());

  final Future<Either<Failure, T>> Function(int id) read;
  final Future<Either<Failure, Unit>> Function(StaffReview review) review;
  final int id;

  Future<void> load() async {
    emit(StaffItemState<T>());
    final result = await read(id);
    if (isClosed) return;
    emit(result.fold(
      (failure) => StaffItemState<T>(loading: false, message: failure.message ?? ''),
      (item) => StaffItemState<T>(item: item, loading: false),
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
