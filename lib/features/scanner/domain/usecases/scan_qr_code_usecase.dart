import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scan_result_entity.dart';
import '../repositories/scanner_repository.dart';

class ScanQrCodeParams extends Equatable {
  final String qrData;

  const ScanQrCodeParams({required this.qrData});

  @override
  List<Object?> get props => [qrData];
}

class ScanQrCodeUseCase extends UseCase<ScanResultEntity, ScanQrCodeParams> {
  final ScannerRepository repository;

  ScanQrCodeUseCase(this.repository);

  @override
  Future<Either<Failure, ScanResultEntity>> call(
      ScanQrCodeParams params) async {
    return await repository.scanQrCode(params.qrData);
  }
}
