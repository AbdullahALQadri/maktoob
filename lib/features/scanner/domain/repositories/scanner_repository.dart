import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/check_in_guest_entity.dart';
import '../entities/scan_result_entity.dart';

abstract class ScannerRepository {
  /// Sends QR code data to server for validation
  Future<Either<Failure, ScanResultEntity>> scanQrCode(String qrData);

  /// Checks in a guest by their ID
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(String guestId);

  /// Gets the list of all guests with optional search filter
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList({
    String? searchQuery,
  });

  /// Gets a specific guest by ID
  Future<Either<Failure, CheckInGuestEntity>> getGuestById(String guestId);
}
