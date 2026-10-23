import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_remote_data_source.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource remoteDataSource;

  ScannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CheckInGuestEntity>> scanQrCode(String qrCode, int eventId) async {
    try {
      final result = await remoteDataSource.scanQrCode(qrCode, eventId);
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(
    String invitationId,
    int eventId, {
    int? actualCompanions,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.checkInGuest(
        invitationId,
        eventId,
        actualCompanions: actualCompanions,
        notes: notes,
      );
      return Right(result);
    } on ConflictException catch (e) {
      return Left(AlreadyCheckedInFailure(message: e.message));
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList(
    int eventId, {
    String? searchQuery,
  }) async {
    try {
      final result = await remoteDataSource.getGuestList(eventId, searchQuery: searchQuery);
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }
}
