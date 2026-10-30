import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'app.dart';
import 'bloc_observer.dart';
import 'core/offline/background_sync.dart';
import 'core/offline/pending_actions_queue.dart';
import 'features/scanner/data/datasources/door_remote_data_source.dart';
import 'features/scanner/data/datasources/door_store.dart';
import 'features/scanner/data/door_engine.dart';
import 'core/services/fcm_service.dart';
import 'core/services/security/device_security_service.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;

void main() {
  // Set up Flutter error handling early
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('Flutter Error: ${details.exception}');
    }
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase before anything else that might use it
      final pushAvailable = await _initFirebase();

      // Run orientation lock and DI initialization in parallel for faster startup
      await Future.wait([
        di.init(pushAvailable: pushAvailable),
        SystemChrome.setPreferredOrientations(
          _isTablet()
              ? DeviceOrientation.values
              : const [
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ],
        ),
      ]);

      // Initialize FCM service (requests permission, captures token, wires streams)
      // Run unawaited — token registration happens via tokenStream listeners
      unawaited(di.sl<FcmService>().initialize());

      // Offline-first: what was recorded with no connection (door
      // check-ins, queued writes) uploads by itself when the connection
      // returns, in the background too (WorkManager / BGTaskScheduler).
      unawaited(BackgroundSync.initialize());
      ForegroundSync.start(
        store: di.sl<DoorStore>(),
        remote: di.sl<DoorRemoteDataSource>(),
        engine: di.sl<DoorEngine>(),
        queue: di.sl<PendingActionsQueue>(),
        connectivity: di.sl<InternetConnection>()
            .onStatusChange
            .map((s) => s == InternetStatus.connected),
      );

      // Device check is informational only: never blocks the app (store
      // reviewers use emulators). Fire-and-forget, result is logged.
      unawaited(di.sl<DeviceSecurityService>().checkDeviceSecurity());

      // Set up BLoC Observer only in debug mode to reduce overhead in release
      if (kDebugMode) {
        Bloc.observer = MyBlocObserver();
      }

      runApp(const Maktoob());
    },
    (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Uncaught Zone Error: $error');
      }
    },
  );
}

/// Phones stay portrait; tablets (shortest side >= 600dp) rotate freely.
bool _isTablet() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) return false;
  final view = views.first;
  final size = view.physicalSize / view.devicePixelRatio;
  return size.shortestSide >= 600;
}

/// Starts Firebase; returns false (push off) instead of throwing, so a missing
/// config can never keep the app from launching.
///
/// iOS reads its config from ios/Runner/GoogleService-Info.plist (copied into
/// the bundle by the "Copy GoogleService-Info.plist" build phase); Android
/// uses the generated [DefaultFirebaseOptions].
Future<bool> _initFirebase() async {
  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    return true;
  } catch (e) {
    debugPrint('Firebase unavailable, push notifications are off: $e');
    return false;
  }
}
