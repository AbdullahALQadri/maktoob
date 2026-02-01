import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/entities/scan_result_entity.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_remote_data_source.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource remoteDataSource;

  ScannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ScanResultEntity>> scanQrCode(String qrData) async {
    try {
      final result = await remoteDataSource.scanQrCode(qrData);
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(String guestId) async {
    try {
      final result = await remoteDataSource.checkInGuest(guestId);
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList({
    String? searchQuery,
  }) async {
    try {
      final result = await remoteDataSource.getGuestList(searchQuery: searchQuery);
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckInGuestEntity>> getGuestById(String guestId) async {
    try {
      final result = await remoteDataSource.getGuestById(guestId);
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }
}
