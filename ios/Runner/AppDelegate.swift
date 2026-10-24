import Flutter
import UIKit
import UserNotifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets firebase_messaging / flutter_local_notifications show banners while
    // the app is open and report taps.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    GeneratedPluginRegistrant.register(with: self)

    // Offline sync (door check-ins, queued writes) runs in a background
    // engine: give it the app's plugins (SQLite, secure storage, HTTP).
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    // Must match BackgroundSync.periodicId (lib/core/offline/background_sync.dart)
    // and BGTaskSchedulerPermittedIdentifiers in Info.plist. iOS decides when.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "com.maktoob.maktoob.offlineSync",
      earliestBeginInSeconds: NSNumber(value: 15 * 60)
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
