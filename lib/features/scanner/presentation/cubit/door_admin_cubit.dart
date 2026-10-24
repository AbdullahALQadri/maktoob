import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/door_models.dart';
import '../../domain/entities/door_entities.dart';
import '../../domain/repositories/door_admin_repository.dart';

class DoorAdminState extends Equatable {
  final bool loading;
  final bool offline;
  final String? error;
  final DoorSummaryModel? summary;
  final List<DoorGate> gates;
  final List<DoorCodeModel> codes;

  /// The code created last (the plain code is shown once).
  final DoorCodeCreated? created;

  const DoorAdminState({
    this.loading = false,
    this.offline = false,
    this.error,
    this.summary,
    this.gates = const [],
    this.codes = const [],
    this.created,
  });

  bool get canManage => summary?.canManage ?? false;

  DoorAdminState copyWith({
    bool? loading,
    bool? offline,
    String? error,
    bool clearError = false,
    DoorSummaryModel? summary,
    List<DoorGate>? gates,
    List<DoorCodeModel>? codes,
    DoorCodeCreated? created,
    bool clearCreated = false,
  }) => DoorAdminState(
    loading: loading ?? this.loading,
    offline: offline ?? this.offline,
    error: clearError ? null : (error ?? this.error),
    summary: summary ?? this.summary,
    gates: gates ?? this.gates,
    codes: codes ?? this.codes,
    created: clearCreated ? null : (created ?? this.created),
  );

  @override
  List<Object?> get props => [loading, offline, error, summary, gates, codes, created];
}

/// The host's door management (gates, staff codes, phones, report). Needs a
/// connection; offline it says so instead of failing.
class DoorAdminCubit extends Cubit<DoorAdminState> {
  final DoorAdminRepository repository;
  final DoorSession session;

  DoorAdminCubit({required this.repository, required this.session}) : super(const DoorAdminState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    final summary = await repository.summary(session);
    final failure = summary.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) return _fail(failure);
    final s = summary.getOrElse(() => throw StateError('unreachable'));

    final gates = await repository.gates(session);
    final codes = s.canManage ? await repository.codes(session) : null;

    emit(
      state.copyWith(
        loading: false,
        offline: false,
        summary: s,
        gates: gates.getOrElse(() => state.gates),
        codes: codes?.getOrElse(() => state.codes) ?? const [],
      ),
    );
  }

  void _fail(Failure f) => emit(
    state.copyWith(
      loading: false,
      offline: f is NetworkFailure,
      error: f is NetworkFailure ? null : (f.message ?? 'error'),
    ),
  );

  Future<bool> _run<T>(Future<Either<Failure, T>> Function() action) async {
    emit(state.copyWith(loading: true, clearError: true));
    final failure = (await action()).fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      _fail(failure);
      return false;
    }
    await load();
    return true;
  }

  Future<bool> addGate(String name, String audience) => _run(() => repository.addGate(session, name, audience));

  Future<bool> renameGate(int id, String name, String audience) =>
      _run(() => repository.updateGate(session, id, name: name, audience: audience));

  Future<bool> deleteGate(int id) => _run(() => repository.deleteGate(session, id));

  Future<bool> createCode({String? label, int? gateId, int? maxDevices}) async {
    emit(state.copyWith(loading: true, clearError: true, clearCreated: true));
    final result = await repository.createCode(session, label: label, gateId: gateId, maxDevices: maxDevices);
    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      _fail(failure);
      return false;
    }
    await load();
    emit(state.copyWith(created: result.getOrElse(() => throw StateError('unreachable'))));
    return true;
  }

  void dismissCreated() => emit(state.copyWith(clearCreated: true));

  Future<bool> cancelCode(int id) => _run(() => repository.cancelCode(session, id));

  Future<bool> removeDevice(int id) => _run(() => repository.removeDevice(session, id));
}
