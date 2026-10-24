import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/check_in_guest_entity.dart';
import '../entities/door_entities.dart';

/// The door: works offline (the door pack) and syncs when it can.
abstract class ScannerRepository {
  /// Opens [session] (downloads the pack when there is a connection).
  Future<DoorStatus> open(DoorSession session);

  Future<void> close();

  DoorStatus get status;
  Stream<DoorStatus> get statusStream;

  /// Looks a scanned QR up on the phone. Never needs the network.
  Future<Either<Failure, CheckInGuestEntity>> scanQrCode(String qrCode);

  /// Lets the guest in: the server decides when reachable, then the venue
  /// hub, else this phone; the check-in is kept until it is uploaded.
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(
    String invitationId, {
    int? actualCompanions,
    String? notes,
    bool manual = false,
    int? maxCompanions,
  });

  /// Every invitee of the event with who is already inside (local).
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList({String? searchQuery});

  Future<void> syncNow();
}
