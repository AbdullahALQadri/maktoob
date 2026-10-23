import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/check_in_guest_entity.dart';

abstract class ScannerRepository {
  /// Validates a scanned QR code against a venue and returns the invitation.
  Future<Either<Failure, CheckInGuestEntity>> scanQrCode(String qrCode, int eventId);

  /// Confirms check-in for an invitation at a venue.
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(
    String invitationId,
    int eventId, {
    int? actualCompanions,
    String? notes,
  });

  /// Lists guests already checked in at a venue (attendance).
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList(
    int eventId, {
    String? searchQuery,
  });
}
