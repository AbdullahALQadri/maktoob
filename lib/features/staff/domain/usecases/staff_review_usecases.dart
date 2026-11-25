import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/staff_review_entities.dart';
import '../repositories/staff_repository.dart';
import '../repositories/staff_reviews_repository.dart';
import 'staff_usecases.dart';

class GetStaffIdentitiesUseCase implements UseCase<List<StaffIdentity>, NoParams> {
  GetStaffIdentitiesUseCase(this.repository);

  final StaffReviewsRepository repository;

  @override
  StaffResult<List<StaffIdentity>> call(NoParams params) => repository.identities();
}

class GetStaffIdentityUseCase implements UseCase<StaffIdentity, int> {
  GetStaffIdentityUseCase(this.repository);

  final StaffReviewsRepository repository;

  @override
  StaffResult<StaffIdentity> call(int id) => repository.identity(id);
}

class ReviewStaffIdentityUseCase implements UseCase<Unit, StaffReview> {
  ReviewStaffIdentityUseCase(this.repository);

  final StaffReviewsRepository repository;

  @override
  StaffResult<Unit> call(StaffReview review) => review.approve
      ? repository.approveIdentity(review.id, notes: review.note.trim().isEmpty ? null : review.note.trim())
      : repository.rejectIdentity(review.id, review.note.trim());
}

class GetStaffInstitutionsUseCase implements UseCase<List<StaffInstitution>, NoParams> {
  GetStaffInstitutionsUseCase(this.repository);

  final StaffReviewsRepository repository;

  @override
  StaffResult<List<StaffInstitution>> call(NoParams params) => repository.institutions();
}

class GetStaffInstitutionUseCase implements UseCase<StaffInstitution, int> {
  GetStaffInstitutionUseCase(this.repository);

  final StaffReviewsRepository repository;

  @override
  StaffResult<StaffInstitution> call(int id) => repository.institution(id);
}

class ReviewStaffInstitutionUseCase implements UseCase<Unit, StaffReview> {
  ReviewStaffInstitutionUseCase(this.repository);

  final StaffReviewsRepository repository;

  @override
  StaffResult<Unit> call(StaffReview review) => review.approve
      ? repository.approveInstitution(review.id, notes: review.note.trim().isEmpty ? null : review.note.trim())
      : repository.rejectInstitution(review.id, review.note.trim());
}

/// Opens one private file of a review: an ID photo, or an institution's
/// document.
class OpenStaffFileUseCase implements UseCase<Uint8List, StaffFile> {
  OpenStaffFileUseCase(this.repository);

  final StaffReviewsRepository repository;

  @override
  StaffResult<Uint8List> call(StaffFile file) => file.side != null
      ? repository.identityPhoto(file.ownerId, file.side!)
      : repository.institutionDocument(file.ownerId, file.documentId!);
}

class StaffFile extends Equatable {
  /// A side (`front` / `back`) of an identity document.
  const StaffFile.identity(this.ownerId, String this.side) : documentId = null;

  const StaffFile.institution(this.ownerId, int this.documentId) : side = null;

  final int ownerId;
  final String? side;
  final int? documentId;

  @override
  List<Object?> get props => [ownerId, side, documentId];
}
