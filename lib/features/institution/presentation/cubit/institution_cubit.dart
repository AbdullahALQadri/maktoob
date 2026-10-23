import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';

import '../../domain/entities/institution_entity.dart';
import '../../domain/repositories/institution_repository.dart';
import 'institution_state.dart';

/// Institution profile, approval status and the client's pending invites.
class InstitutionCubit extends Cubit<InstitutionState> {
  final InstitutionRepository repository;

  InstitutionCubit({required this.repository}) : super(const InstitutionInitial());

  Future<void> load({bool silent = false}) async {
    final current = state;
    if (!silent || current is! InstitutionLoaded) emit(const InstitutionLoading());
    final result = await repository.getOverview();
    result.fold(
      (f) => emit(InstitutionError(f.message ?? 'error')),
      (overview) => emit(InstitutionLoaded(overview)),
    );
  }

  /// `POST /institution/profile`. A rejected institution goes back to pending.
  /// Returns true on success.
  Future<bool> saveProfile(InstitutionProfileInput input) async {
    final current = state;
    final base = current is InstitutionLoaded
        ? current
        : const InstitutionLoaded(InstitutionOverviewEntity());
    final hadPending = base.overview.institution?.pendingChanges;
    emit(base.copyWith(isBusy: true));
    final result = await repository.saveProfile(input);
    return _applyOverview(base, result, (inst) {
      // On an approved account, identity edits wait for review: say so.
      final pending = inst?.pendingChanges;
      return (inst?.isIdentityLocked ?? false) && pending != null && pending != hadPending
          ? 'institution_changes_pending'
          : 'institution_profile_saved';
    });
  }

  /// Upload a verification document (PDF or image). Returns true on success.
  Future<bool> uploadDocument({required String type, required String filePath}) async {
    final base = _loadedOrEmpty();
    emit(base.copyWith(isBusy: true));
    final result = await repository.uploadDocument(type: type, filePath: filePath);
    return _applyOverview(base, result, (_) => 'institution_document_uploaded');
  }

  /// Delete a document (allowed only before approval).
  Future<bool> deleteDocument(int documentId) async {
    final base = _loadedOrEmpty();
    emit(base.copyWith(isBusy: true));
    final result = await repository.deleteDocument(documentId);
    return _applyOverview(base, result, (_) => 'institution_document_deleted');
  }

  InstitutionLoaded _loadedOrEmpty() {
    final current = state;
    return current is InstitutionLoaded
        ? current
        : const InstitutionLoaded(InstitutionOverviewEntity());
  }

  /// Emit [result] merged into [base]; responses may omit memberships / invites.
  bool _applyOverview(
    InstitutionLoaded base,
    Either<Failure, InstitutionOverviewEntity> result,
    String Function(InstitutionEntity? institution) successKey,
  ) {
    return result.fold(
      (f) {
        emit(base.copyWith(message: f.message, messageIsError: true));
        return false;
      },
      (o) {
        final merged = InstitutionOverviewEntity(
          isInstitutionAccount: true,
          institution: o.institution ?? base.overview.institution,
          memberships: o.memberships.isNotEmpty ? o.memberships : base.overview.memberships,
          pendingInvites: o.pendingInvites.isNotEmpty ? o.pendingInvites : base.overview.pendingInvites,
        );
        emit(InstitutionLoaded(merged, message: successKey(merged.institution)));
        return true;
      },
    );
  }

  Future<void> acceptInvite(int inviteId) => _inviteAction(
        () => repository.acceptInvite(inviteId),
        'institution_invite_accepted',
      );

  Future<void> declineInvite(int inviteId) => _inviteAction(
        () => repository.declineInvite(inviteId),
        'institution_invite_declined',
      );

  Future<void> _inviteAction(Future<dynamic> Function() call, String successKey) async {
    final current = state;
    if (current is! InstitutionLoaded) return;
    emit(current.copyWith(isBusy: true));
    final result = await call();
    await result.fold(
      (f) async => emit(current.copyWith(message: f.message, messageIsError: true)),
      (_) async {
        final fresh = await repository.getOverview();
        fresh.fold(
          (_) => emit(current.copyWith(message: successKey)),
          (overview) => emit(InstitutionLoaded(overview, message: successKey)),
        );
      },
    );
  }
}

/// Owner-only team management: list, invite by phone, change role, remove.
class InstitutionTeamCubit extends Cubit<InstitutionTeamState> {
  final InstitutionRepository repository;

  InstitutionTeamCubit({required this.repository}) : super(const InstitutionTeamInitial());

  List<InstitutionMemberEntity> get _members {
    final s = state;
    return s is InstitutionTeamLoaded ? s.members : const [];
  }

  Future<void> load() async {
    emit(const InstitutionTeamLoading());
    final result = await repository.getMembers();
    result.fold(
      (f) => emit(InstitutionTeamError(f.message ?? 'error')),
      (members) => emit(InstitutionTeamLoaded(members)),
    );
  }

  Future<bool> invite({required String phone, required String role}) =>
      _act(() => repository.inviteMember(phone: phone, role: role), 'institution_member_invited');

  Future<bool> changeRole(int memberId, String role) =>
      _act(() => repository.updateMemberRole(memberId, role), 'institution_member_role_updated');

  Future<bool> remove(int memberId) =>
      _act(() => repository.removeMember(memberId), 'institution_member_removed');

  Future<bool> _act(Future<dynamic> Function() call, String successKey) async {
    final before = _members;
    emit(InstitutionTeamLoaded(before, isBusy: true));
    final result = await call();
    return await result.fold(
      (f) async {
        emit(InstitutionTeamLoaded(before, message: f.message, messageIsError: true));
        return false;
      },
      (_) async {
        final fresh = await repository.getMembers();
        emit(InstitutionTeamLoaded(fresh.getOrElse(() => before), message: successKey));
        return true;
      },
    );
  }
}

/// `GET /institution/credits`: balance + ledger.
class InstitutionCreditsCubit extends Cubit<InstitutionCreditsState> {
  final InstitutionRepository repository;

  InstitutionCreditsCubit({required this.repository}) : super(const InstitutionCreditsInitial());

  Future<void> load() async {
    emit(const InstitutionCreditsLoading());
    final result = await repository.getCredits();
    result.fold(
      (f) => emit(InstitutionCreditsError(f.message ?? 'error')),
      (credits) => emit(InstitutionCreditsLoaded(credits)),
    );
  }
}
