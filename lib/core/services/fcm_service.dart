import 'dart:async';
import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';

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
class FcmService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  final StreamController<String> _tokenCtrl = StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _messageCtrl =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription? _onMessageSub;
  StreamSubscription? _onMessageOpenedSub;
  StreamSubscription? _onTokenRefreshSub;

  Stream<String> get tokenStream => _tokenCtrl.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageCtrl.stream;

  /// Returns the latest token if any. Safe to call after [initialize].
  Future<String?> getToken() => _fm.getToken();

  Future<void> initialize() async {
    // Request permission (iOS prompts; Android 13+ also prompts)
    await _fm.requestPermission(alert: true, badge: true, sound: true);

    // Initial token (broadcast so listeners can register it with the backend)
    final token = await _fm.getToken();
    if (token != null && !_tokenCtrl.isClosed) _tokenCtrl.add(token);

    _onTokenRefreshSub = _fm.onTokenRefresh.listen((t) {
      if (!_tokenCtrl.isClosed) _tokenCtrl.add(t);
    });

    // Foreground push → forward data payload
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      dev.log('FCM foreground: ${m.data}', name: 'FcmService');
      if (m.data.isNotEmpty && !_messageCtrl.isClosed) {
        _messageCtrl.add(Map<String, dynamic>.from(m.data));
      }
    });

    // User tapped a notification while app was in background
    _onMessageOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      dev.log('FCM tap (background): ${m.data}', name: 'FcmService');
      if (m.data.isNotEmpty && !_messageCtrl.isClosed) {
        _messageCtrl.add(Map<String, dynamic>.from(m.data));
      }
    });

    // App was terminated and was opened by tapping the notification
    final initial = await _fm.getInitialMessage();
    if (initial != null && initial.data.isNotEmpty && !_messageCtrl.isClosed) {
      dev.log('FCM tap (terminated): ${initial.data}', name: 'FcmService');
      _messageCtrl.add(Map<String, dynamic>.from(initial.data));
    }
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedSub?.cancel();
    await _onTokenRefreshSub?.cancel();
    await _tokenCtrl.close();
    await _messageCtrl.close();
  }
}
