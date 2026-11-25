import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';

/// Something read from the server: loading, there, or a problem.
class StaffLoadState<T> extends Equatable {
  const StaffLoadState({this.value, this.loading = true, this.error});

  final T? value;
  final bool loading;
  final String? error;

  @override
  List<Object?> get props => [value, loading, error];
}

/// Loads one thing for a staff screen (today, a queue, a list) and can load
/// it again with a search. What is shown stays while it refreshes.
class StaffLoadCubit<T> extends Cubit<StaffLoadState<T>> {
  StaffLoadCubit(this._read) : super(StaffLoadState<T>());

  final Future<Either<Failure, T>> Function(String search) _read;
  String _search = '';

  Future<void> load([String? search]) async {
    final query = _search = search ?? _search;
    emit(StaffLoadState<T>(value: state.value));
    final result = await _read(query);
    // A newer search was typed while this one was on its way.
    if (isClosed || query != _search) return;
    emit(result.fold(
      (failure) => StaffLoadState<T>(value: state.value, loading: false, error: failure.message ?? ''),
      (value) => StaffLoadState<T>(value: value, loading: false),
    ));
  }
}
