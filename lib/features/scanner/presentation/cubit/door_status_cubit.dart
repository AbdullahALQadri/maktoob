import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/door_entities.dart';
import '../../domain/repositories/door_controls.dart';

/// The door's status bar: connection (server / venue hub / alone), what is
/// waiting to upload, the gate, and the venue hub controls.
class DoorStatusCubit extends Cubit<DoorStatus> {
  final DoorControls controls;
  StreamSubscription<DoorStatus>? _sub;

  DoorStatusCubit({required this.controls}) : super(controls.status) {
    _sub = controls.statusStream.listen((s) {
      if (!isClosed) emit(s);
    });
  }

  Future<void> syncNow() => controls.syncNow();

  Future<void> setGate(int? gateId) => controls.setGate(gateId);

  /// The join QR text, or null when the hub could not start (no list yet).
  Future<String?> startHub({String? notificationTitle, String? notificationText}) =>
      controls.startHubJoinCode(notificationTitle: notificationTitle, notificationText: notificationText);

  Future<void> stopHub() => controls.stopHub();

  Future<bool> joinHub(String qrText) => controls.joinHubFromCode(qrText);

  Future<void> leaveHub() => controls.detachHub();

  Future<void> refresh() => controls.refreshStatus();

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
