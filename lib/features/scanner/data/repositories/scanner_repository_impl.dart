import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_remote_data_source.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource remoteDataSource;

  ScannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CheckInGuestEntity>> scanQrCode(
    String qrCode, {
    int? venueId,
    int? eventId,
  }) async {
    try {
      final result = await remoteDataSource.scanQrCode(
        qrCode,
        venueId: venueId,
        eventId: eventId,
      );
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(
    String invitationId, {
    int? venueId,
    int? eventId,
    int? actualCompanions,
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.checkInGuest(
        invitationId,
        venueId: venueId,
        eventId: eventId,
        actualCompanions: actualCompanions,
        notes: notes,
      );
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList({
    int? venueId,
    int? eventId,
    String? searchQuery,
  }) async {
    try {
      final result = await remoteDataSource.getGuestList(
        venueId: venueId,
        eventId: eventId,
        searchQuery: searchQuery,
      );
      return Right(result);
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }
}
