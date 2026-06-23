import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/check_in_guest_entity.dart';

abstract class ScannerRepository {
  /// Validates a scanned QR code and returns the invitation. Owner mode passes
  /// [eventId]; scanner mode passes [venueId].
  Future<Either<Failure, CheckInGuestEntity>> scanQrCode(
    String qrCode, {
    int? venueId,
    int? eventId,
  });

  /// Confirms check-in for an invitation.
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(
    String invitationId, {
    int? venueId,
    int? eventId,
    int? actualCompanions,
    String? notes,
  });

  /// Lists the full invitee roster (all invitations + check-in status).
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList({
    int? venueId,
    int? eventId,
    String? searchQuery,
  });
}
