import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/check_in_guest_entity.dart';
import '../../domain/entities/door_entities.dart';
import '../../domain/logic/door_rules.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../door_engine.dart';

/// The scanner on top of the offline door engine: the scan is answered from
/// the phone, the check-in by the server / the venue hub / the phone.
class ScannerRepositoryImpl implements ScannerRepository {
  final DoorEngine engine;

  ScannerRepositoryImpl({required this.engine});

  @override
  Future<DoorStatus> open(DoorSession session) => engine.open(session);

  @override
  Future<void> close() => engine.close();

  @override
  DoorStatus get status => engine.status;

  @override
  Stream<DoorStatus> get statusStream => engine.statusStream;

  @override
  Future<void> syncNow() => engine.syncNow();

  @override
  Future<Either<Failure, CheckInGuestEntity>> scanQrCode(String qrCode) async {
    try {
      final verdict = await engine.lookup(qrCode);
      final guest = verdict.guest;
      // Nothing to show (unknown QR, another event's QR, no list yet).
      if (guest == null) return Left(DoorRefusedFailure(reason: verdict.blocker ?? DoorRules.notFound));
      return Right(
        toEntity(
          guest,
          qrCode: qrCode,
          blocker: verdict.blocker,
          warnings: verdict.warnings,
          unlisted: verdict.unlisted,
          maxCompanions: verdict.maxCompanions,
        ),
      );
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(
    String invitationId, {
    int? actualCompanions,
    String? notes,
    bool manual = false,
    int? maxCompanions,
  }) async {
    final id = int.tryParse(invitationId);
    if (id == null) return const Left(DoorRefusedFailure(reason: DoorRules.notFound));
    try {
      final result = await engine.admit(
        id,
        companions: actualCompanions ?? 0,
        manual: manual,
        notes: notes,
        maxCompanions: maxCompanions,
      );
      if (result.admitted) {
        final guest = result.guest ?? DoorGuest(id: id, name: '');
        return Right(
          toEntity(
            guest,
            warnings: result.warnings,
            unlisted: result.warnings.contains(DoorRules.warnUnlisted),
            decidedOffline: result.decidedBy != DoorDecidedBy.server,
            returning: result.returning,
          ),
        );
      }
      return Left(
        DoorRefusedFailure(
          reason: result.code ?? 'refused',
          maxCompanions: result.maxCompanions,
          message: result.message,
        ),
      );
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList({String? searchQuery}) async {
    try {
      final guests = await engine.guests(query: searchQuery ?? '');
      return Right(guests.map((g) => toEntity(g)).toList());
    } catch (e) {
      return Left(ScannerFailure(message: e.toString()));
    }
  }

  /// The door guest as the scanner screens show it.
  static CheckInGuestEntity toEntity(
    DoorGuest guest, {
    String qrCode = '',
    String? blocker,
    List<String> warnings = const [],
    bool unlisted = false,
    int? maxCompanions,
    bool decidedOffline = false,
    bool returning = false,
  }) {
    final checkIn = guest.checkIn;
    return CheckInGuestEntity(
      id: '${guest.id}',
      name: guest.name,
      status: checkIn != null ? 'checked_in' : guest.rsvp,
      companions: checkIn?.companions ?? guest.companions,
      checkedIn: checkIn != null,
      qrCode: qrCode,
      canCheckIn: blocker == null,
      blockerCode: blocker,
      maxCompanions: maxCompanions ?? guest.maxCompanions,
      declinedRsvp: guest.declined,
      warnings: warnings,
      gender: guest.gender,
      phoneTail: guest.phoneTail,
      checkedInAt: checkIn?.checkedInAt,
      checkedInDevice: checkIn?.deviceName,
      checkedInGateId: checkIn?.gateId,
      unlisted: unlisted,
      decidedOffline: decidedOffline,
      returning: returning,
    );
  }
}
