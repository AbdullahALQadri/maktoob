import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/staff_entities.dart';
import '../repositories/staff_repository.dart';

class SignInStaffUseCase implements UseCase<StaffUser, StaffCredentials> {
  SignInStaffUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<StaffUser> call(StaffCredentials c) => repository.signIn(c.email.trim(), c.password);
}

class StaffCredentials extends Equatable {
  const StaffCredentials(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RestoreStaffUseCase implements UseCase<StaffUser?, NoParams> {
  RestoreStaffUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<StaffUser?> call(NoParams params) => repository.restore();
}

class SignOutStaffUseCase {
  SignOutStaffUseCase(this.repository);

  final StaffRepository repository;

  Future<void> call() => repository.signOut();
}

class GetStaffTodayUseCase implements UseCase<StaffToday, NoParams> {
  GetStaffTodayUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<StaffToday> call(NoParams params) => repository.today();
}

class GetStaffPaymentRequestsUseCase implements UseCase<List<StaffPaymentRequest>, NoParams> {
  GetStaffPaymentRequestsUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<List<StaffPaymentRequest>> call(NoParams params) => repository.paymentRequests();
}

class GetStaffPaymentRequestUseCase implements UseCase<StaffPaymentRequest, int> {
  GetStaffPaymentRequestUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<StaffPaymentRequest> call(int id) => repository.paymentRequest(id);
}

/// Approves a payment request, or refuses it with a reason.
class ReviewStaffPaymentRequestUseCase implements UseCase<Unit, StaffReview> {
  ReviewStaffPaymentRequestUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<Unit> call(StaffReview review) => review.approve
      ? repository.approve(review.id, notes: review.note.trim().isEmpty ? null : review.note.trim())
      : repository.reject(review.id, review.note.trim());
}

class StaffReview extends Equatable {
  const StaffReview.approve(this.id, {this.note = ''}) : approve = true;

  const StaffReview.reject(this.id, this.note) : approve = false;

  final int id;
  final bool approve;

  /// A note for the file when approving; the reason for the client when refusing.
  final String note;

  @override
  List<Object?> get props => [id, approve, note];
}

class GetStaffClientsUseCase implements UseCase<List<StaffClientRow>, String> {
  GetStaffClientsUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<List<StaffClientRow>> call(String search) => repository.clients(search: search.trim());
}

class GetStaffEventsUseCase implements UseCase<List<StaffEventRow>, String> {
  GetStaffEventsUseCase(this.repository);

  final StaffRepository repository;

  @override
  StaffResult<List<StaffEventRow>> call(String search) => repository.events(search: search.trim());
}
