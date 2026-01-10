import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scan_result_entity.dart';
import '../repositories/scanner_repository.dart';

class ScanQrCodeUseCase extends UseCase<ScanResultEntity, NoParams> {
  final ScannerRepository repository;

  ScanQrCodeUseCase(this.repository);

  @override
  Future<Either<Failure, ScanResultEntity>> call(NoParams params) async {
    return await repository.scanQrCode();
  }
}
