/// The phone's view of the server's clock. A phone that has had no network
/// for days often shows the wrong time; the door rules (event day window)
/// and the recorded scan times use the server time, measured on each answer.
class DoorClock {
  /// server minus device, in milliseconds.
  int offsetMs;

  DoorClock([this.offsetMs = 0]);

  DateTime nowUtc() => DateTime.now().toUtc().add(Duration(milliseconds: offsetMs));

  /// Update from a server timestamp received just now.
  void observe(DateTime? serverTime) {
    if (serverTime == null) return;
    offsetMs = serverTime.toUtc().difference(DateTime.now().toUtc()).inMilliseconds;
  }
}
