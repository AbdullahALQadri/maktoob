import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../features/scanner/data/lan/hub_keep_alive.dart';

/// The venue hub as an Android foreground service ("connectedDevice": this
/// phone serves the other door phones on the local network). While it runs,
/// Android keeps the app's process alive with the CPU and Wi-Fi awake, so
/// the hub keeps answering with the screen off or the app in the background.
/// The persistent notification brings the app back on tap.
class AndroidHubService implements HubKeepAlive {
  static const int _serviceId = 8787;

  bool get _supported => !kIsWeb && Platform.isAndroid;

  @override
  Future<void> start({required String title, required String text}) async {
    if (!_supported) return;
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'door_hub',
          channelName: title,
          channelDescription: text,
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(showNotification: false),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );
      // Android 13+: without it the service still runs, only the notification
      // is hidden. Ask, but never wait on the answer to start serving.
      if (await FlutterForegroundTask.checkNotificationPermission() != NotificationPermission.granted) {
        unawaited(FlutterForegroundTask.requestNotificationPermission());
      }
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(notificationTitle: title, notificationText: text);
        return;
      }
      await FlutterForegroundTask.startService(
        serviceId: _serviceId,
        serviceTypes: const [ForegroundServiceTypes.connectedDevice],
        notificationTitle: title,
        notificationText: text,
        notificationInitialRoute: '/',
        callback: hubServiceCallback,
      );
    } catch (e) {
      // The hub still works while the app is open.
      debugPrint('Hub foreground service unavailable: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (!_supported) return;
    try {
      if (await FlutterForegroundTask.isRunningService) await FlutterForegroundTask.stopService();
    } catch (_) {}
  }
}

/// The service's own isolate has nothing to do: the hub's server lives in
/// the app's main isolate, which the service keeps alive.
@pragma('vm:entry-point')
void hubServiceCallback() {
  FlutterForegroundTask.setTaskHandler(_HubTaskHandler());
}

class _HubTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}
