import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/scanner/domain/entities/check_in_guest_entity.dart';
import 'package:maktoob/features/scanner/domain/entities/door_entities.dart';
import 'package:maktoob/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:maktoob/features/scanner/domain/usecases/check_in_guest_usecase.dart';
import 'package:maktoob/features/scanner/domain/usecases/get_guest_list_usecase.dart';
import 'package:maktoob/features/scanner/domain/usecases/scan_qr_code_usecase.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_cubit.dart';

CheckInGuestEntity guestEntity({
  bool canCheckIn = true,
  String? blockerCode,
  int? max,
  bool declined = false,
  bool already = false,
  bool returning = false,
  List<String> warnings = const [],
}) => CheckInGuestEntity(
  id: '7',
  name: 'سارة',
  status: already ? 'checked_in' : (declined ? 'not_attending' : 'attending'),
  companions: 3,
  checkedIn: already,
  qrCode: 'qr',
  canCheckIn: canCheckIn,
  blockerCode: blockerCode,
  maxCompanions: max,
  declinedRsvp: declined,
  warnings: [if (declined) 'declined', ...warnings],
  checkedInAt: already ? DateTime.utc(2026, 10, 10, 17, 5) : null,
  checkedInDevice: already ? 'Women 1' : null,
  returning: returning,
);

/// The door as the cubit sees it, with scripted answers.
class FakeScannerRepository implements ScannerRepository {
  Either<Failure, CheckInGuestEntity> scan = Right(guestEntity());
  Failure? checkInFailure;

  /// What the check-in answers instead of the default success.
  CheckInGuestEntity? checkInResult;
  int? sentCompanions;
  bool? sentManual;
  int checkInCalls = 0;
  List<CheckInGuestEntity> list = const [];
  final StreamController<DoorStatus> _status = StreamController<DoorStatus>.broadcast();

  @override
  DoorStatus get status => const DoorStatus();

  @override
  Stream<DoorStatus> get statusStream => _status.stream;

  @override
  Future<DoorStatus> open(DoorSession session) async => const DoorStatus();

  @override
  Future<void> close() async {}

  @override
  Future<void> syncNow() async {}

  @override
  Future<Either<Failure, CheckInGuestEntity>> scanQrCode(String qrCode) async => scan;

  @override
  Future<Either<Failure, CheckInGuestEntity>> checkInGuest(
    String invitationId, {
    int? actualCompanions,
    String? notes,
    bool manual = false,
    int? maxCompanions,
  }) async {
    checkInCalls++;
    sentCompanions = actualCompanions;
    sentManual = manual;
    if (checkInFailure != null) return Left(checkInFailure!);
    if (checkInResult != null) return Right(checkInResult!);
    final scanned = scan.getOrElse(() => guestEntity());
    return Right(
      scanned.copyWith(checkedIn: true, companions: actualCompanions, checkedInAt: DateTime.utc(2026, 10, 10, 18)),
    );
  }

  @override
  Future<Either<Failure, List<CheckInGuestEntity>>> getGuestList({String? searchQuery}) async => Right(list);
}

Future<ScannerCubit> cubitFor(FakeScannerRepository repo) async {
  final cubit = ScannerCubit(
    repository: repo,
    scanQrCodeUseCase: ScanQrCodeUseCase(repo),
    checkInGuestUseCase: CheckInGuestUseCase(repo),
    getGuestListUseCase: GetGuestListUseCase(repo),
  );
  await cubit.openSession(DoorSession.client(1, 'عرس'));
  return cubit;
}
