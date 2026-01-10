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
    return await repository.checkInGuest(params.guestId);
  }
}

class CheckInGuestParams extends Equatable {
  final String guestId;

  const CheckInGuestParams({required this.guestId});

  @override
  List<Object?> get props => [guestId];
}
