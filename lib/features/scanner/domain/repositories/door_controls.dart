import '../entities/door_entities.dart';

/// The door's connection and venue controls (the status bar, the gate, the
/// venue hub). Implemented by the door engine.
abstract class DoorControls {
  DoorStatus get status;
  Stream<DoorStatus> get statusStream;

  Future<void> syncNow();
  Future<void> setGate(int? gateId);

  /// Starts this phone as the venue hub; the text to show in its join QR.
  /// With a [notificationTitle] it keeps serving in the background
  /// (Android: a foreground service showing that notification).
  Future<String?> startHubJoinCode({String? notificationTitle, String? notificationText});
  Future<void> stopHub();

  /// Joins the venue hub from its scanned QR text. False when the QR is not
  /// a hub of this event.
  Future<bool> joinHubFromCode(String qrText);
  Future<void> detachHub();

  /// After the user signed in again: try syncing again.
  Future<void> clearAuthProblem();

  /// Re-reads counts (e.g. phones connected to the hub) without syncing.
  Future<void> refreshStatus();
}
