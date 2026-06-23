import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in_guest_entity.dart';
import '../repositories/scanner_repository.dart';

class ScanQrCodeParams extends Equatable {
  final String qrData;
  final int? venueId;
  final int? eventId;

  const ScanQrCodeParams({required this.qrData, this.venueId, this.eventId});

  @override
  List<Object?> get props => [qrData, venueId, eventId];
}

class ScanQrCodeUseCase extends UseCase<CheckInGuestEntity, ScanQrCodeParams> {
  final ScannerRepository repository;

  ScanQrCodeUseCase(this.repository);

  @override
  Future<Either<Failure, CheckInGuestEntity>> call(
      ScanQrCodeParams params) async {
    return await repository.scanQrCode(
      params.qrData,
      venueId: params.venueId,
      eventId: params.eventId,
    );
  }
}
