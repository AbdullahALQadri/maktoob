import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'bloc_observer.dart';
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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Run orientation lock and DI initialization in parallel for faster startup
      await Future.wait([
        di.init(),
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]),
      ]);

      // Initialize FCM service (requests permission, captures token, wires streams)
      // Run unawaited — token registration happens via tokenStream listeners
      unawaited(di.sl<FcmService>().initialize());

      // Run device security check (root/jailbreak detection)
      final securityService = di.sl<DeviceSecurityService>();
      await securityService.checkDeviceSecurity();

      // Set up BLoC Observer only in debug mode to reduce overhead in release
      if (kDebugMode) {
        Bloc.observer = MyBlocObserver();
      }

      // Block compromised devices in release mode
      if (!securityService.isDeviceSecure) {
        runApp(const CompromisedDeviceApp());
        return;
      }

      // Run the app (use DevicePreview only in debug mode)
      runApp(
        kDebugMode
            ? DevicePreview(enabled: false, builder: (context) => const Maktoob())
            : const Maktoob(),
      );
    },
    (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Uncaught Zone Error: $error');
      }
    },
  );
}
