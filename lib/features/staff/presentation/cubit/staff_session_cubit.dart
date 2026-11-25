import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/staff_entities.dart';
import '../../domain/usecases/staff_usecases.dart';

class StaffSessionState extends Equatable {
  const StaffSessionState({this.user, this.checking = true, this.busy = false, this.error});

  /// The member signed in, or null.
  final StaffUser? user;

  /// Still looking for a sign-in kept on this phone.
  final bool checking;
  final bool busy;
  final String? error;

  @override
  List<Object?> get props => [user, checking, busy, error];
}

/// Who is signed in to the staff mode on this phone.
class StaffSessionCubit extends Cubit<StaffSessionState> {
  StaffSessionCubit({required this.signIn, required this.restore, required this.signOut})
      : super(const StaffSessionState());

  final SignInStaffUseCase signIn;
  final RestoreStaffUseCase restore;
  final SignOutStaffUseCase signOut;

  /// Picks up the sign-in kept on this phone, if it still holds.
  Future<void> open() async {
    final result = await restore(const NoParams());
    if (isClosed) return;
    emit(StaffSessionState(user: result.fold((_) => null, (user) => user), checking: false));
  }

  Future<void> enter(String email, String password) async {
    emit(const StaffSessionState(checking: false, busy: true));
    final result = await signIn(StaffCredentials(email, password));
    if (isClosed) return;
    emit(result.fold(
      (failure) => StaffSessionState(checking: false, error: failure.message ?? ''),
      (user) => StaffSessionState(user: user, checking: false),
    ));
  }

  Future<void> leave() async {
    await signOut();
    if (!isClosed) emit(const StaffSessionState(checking: false));
  }
}
