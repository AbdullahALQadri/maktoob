/// Keeps the venue hub serving while the phone is in a pocket: the app may
/// go to the background and the screen may turn off. On Android this is a
/// foreground service (lib/core/offline/android_hub_service.dart); iOS has no
/// such thing, so there the hub screen must stay open.
abstract class HubKeepAlive {
  /// [title] / [text]: the persistent notification, in the user's language.
  Future<void> start({required String title, required String text});

  Future<void> stop();
}
