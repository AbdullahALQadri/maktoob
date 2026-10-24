import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in_guest_entity.dart';
import '../repositories/scanner_repository.dart';

class CheckInGuestUseCase extends UseCase<CheckInGuestEntity, CheckInGuestParams> {
  final ScannerRepository repository;

  CheckInGuestUseCase(this.repository);

  @override
  Future<Either<Failure, CheckInGuestEntity>> call(CheckInGuestParams params) async {
    return await repository.checkInGuest(
      params.invitationId,
      actualCompanions: params.actualCompanions,
      notes: params.notes,
      manual: params.manual,
      maxCompanions: params.maxCompanions,
    );
  }
}

class CheckInGuestParams extends Equatable {
  final String invitationId;
  final int? actualCompanions;
  final String? notes;

  /// Picked from the guest list (no QR shown).
  final bool manual;

  /// From a signed QR not in the downloaded list.
  final int? maxCompanions;

  const CheckInGuestParams({
    required this.invitationId,
    this.actualCompanions,
    this.notes,
    this.manual = false,
    this.maxCompanions,
  });

  @override
  List<Object?> get props => [invitationId, actualCompanions, notes, manual, maxCompanions];
}
