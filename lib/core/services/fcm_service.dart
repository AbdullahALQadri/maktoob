import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/app_colors.dart';

/// Top-level entry point for FCM background messages.
/// Must be a top-level (or static) function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // We don't act here — the OS will display the notification automatically.
  // When the user taps it, FirebaseMessaging.onMessageOpenedApp delivers the
  // payload to FcmService.messageStream which the AiDesignCubit subscribes to.
  dev.log('FCM background: ${message.messageId} ${message.data}', name: 'FcmService');
}

/// Wraps FirebaseMessaging into two streams the rest of the app subscribes to:
///   - [tokenStream]: emits whenever the FCM device token changes (or is first received)
///   - [messageStream]: emits the `data` map from any push the user receives, whether
///                     foreground, background-tap, or terminated-tap.
///   - [tapStream]: emits only when the user taps a notification (to open
///                  what it is about). A tap that launched the app arrives
///                  before anyone listens: read it once with [takeLaunchTap].
///
/// Foreground pushes are shown as a banner too (Android draws nothing for
/// them on its own), so "your event is active" is never silent.
class FcmService {
  /// False when Firebase could not start (e.g. an iOS build without
  /// GoogleService-Info.plist). The service then stays silent: its streams
  /// never emit and [getToken] returns null, so the app keeps working
  /// without push.
  final bool available;

  FcmService({this.available = true});

  FirebaseMessaging get _fm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Same id the backend sends in `android.notification.channel_id`.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ai_generation',
    'Maktoob',
    importance: Importance.high,
  );

  final StreamController<String> _tokenCtrl = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _messageCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _tapCtrl =
      StreamController<Map<String, dynamic>>.broadcast();

  Map<String, dynamic>? _launchTap;

  StreamSubscription? _onMessageSub;
  StreamSubscription? _onMessageOpenedSub;
  StreamSubscription? _onTokenRefreshSub;

  Stream<String> get tokenStream => _tokenCtrl.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageCtrl.stream;
  Stream<Map<String, dynamic>> get tapStream => _tapCtrl.stream;

  /// The notification that launched the app, once (null afterwards).
  Map<String, dynamic>? takeLaunchTap() {
    final tap = _launchTap;
    _launchTap = null;
    return tap;
  }

  void _emitTap(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    if (!_messageCtrl.isClosed) _messageCtrl.add(data);
    if (_tapCtrl.hasListener) {
      _tapCtrl.add(data);
    } else {
      _launchTap = data;
    }
  }

  Future<void> _initLocalNotifications() async {
    try {
      await _local.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_maktoob'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) return;
          try {
            _emitTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
          } catch (_) {}
        },
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
      // iOS draws the banner itself while the app is open.
      await _fm.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
    } catch (e) {
      dev.log('Local notifications unavailable: $e', name: 'FcmService');
    }
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    if (n == null || !Platform.isAndroid) return;
    try {
      await _local.show(
        m.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            importance: Importance.high,
            priority: Priority.high,
            // Sent by the platform: the Maktoob mark, never a person.
            icon: 'ic_stat_maktoob',
            color: AppColors.primary,
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(n.body ?? ''),
          ),
        ),
        payload: jsonEncode(m.data),
      );
    } catch (e) {
      dev.log('Foreground banner not shown: $e', name: 'FcmService');
    }
  }

  /// Returns the latest token if any. Safe to call after [initialize].
  Future<String?> getToken() async {
    if (!available) return null;
    try {
      if (Platform.isIOS && !await _waitForApnsToken()) return null;
      return await _fm.getToken();
    } catch (e) {
      dev.log('FCM token unavailable: $e', name: 'FcmService');
      return null;
    }
  }

  /// iOS hands out an FCM token only after APNs registered the device, which
  /// lands a moment after launch. Asking earlier throws `apns-token-not-set`.
  Future<bool> _waitForApnsToken() async {
    for (var i = 0; i < 10; i++) {
      if (await _fm.getAPNSToken() != null) return true;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return false;
  }

  Future<void> initialize() async {
    if (!available) return;
    // Request permission (iOS prompts; Android 13+ also prompts)
    try {
      await _fm.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      dev.log('Notification permission request failed: $e', name: 'FcmService');
    }
    await _initLocalNotifications();

    // Initial token (broadcast so listeners can register it with the backend).
    // A late APNs token on iOS still reaches the backend via onTokenRefresh.
    final token = await getToken();
    if (token != null && !_tokenCtrl.isClosed) _tokenCtrl.add(token);

    _onTokenRefreshSub = _fm.onTokenRefresh.listen((t) {
      if (!_tokenCtrl.isClosed) _tokenCtrl.add(t);
    });

    // Foreground push → forward data payload
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      dev.log('FCM foreground: ${m.data}', name: 'FcmService');
      _showForeground(m);
      if (m.data.isNotEmpty && !_messageCtrl.isClosed) {
        _messageCtrl.add(Map<String, dynamic>.from(m.data));
      }
    });

    // User tapped a notification while app was in background
    _onMessageOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      dev.log('FCM tap (background): ${m.data}', name: 'FcmService');
      _emitTap(Map<String, dynamic>.from(m.data));
    });

    // App was terminated and was opened by tapping the notification
    final initial = await _fm.getInitialMessage();
    if (initial != null && initial.data.isNotEmpty) {
      dev.log('FCM tap (terminated): ${initial.data}', name: 'FcmService');
      _emitTap(Map<String, dynamic>.from(initial.data));
    }

    // App launched by tapping one of our foreground banners.
    try {
      final launch = await _local.getNotificationAppLaunchDetails();
      final payload = launch?.notificationResponse?.payload;
      if ((launch?.didNotificationLaunchApp ?? false) &&
          payload != null &&
          payload.isNotEmpty) {
        _emitTap(Map<String, dynamic>.from(jsonDecode(payload) as Map));
      }
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedSub?.cancel();
    await _onTokenRefreshSub?.cancel();
    await _tokenCtrl.close();
    await _messageCtrl.close();
    await _tapCtrl.close();
  }
}
