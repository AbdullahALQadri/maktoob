import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'bloc_observer.dart';
import 'core/services/notification_service.dart';
import 'core/utils/storage/shared_preferences.dart';
import 'injection_container.dart' as di;

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Init Shared Preferences
      // await SharedPrefController().initPreferences();

      // Init Dependency Injection
      // await di.init();

      // Lock device orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set up BLoC Observer
      // Bloc.observer = MyBlocObserver();

      // Run the app (use DevicePreview if needed)
      runApp(
        DevicePreview(enabled: false, builder: (context) => const Maktoob()),
      );
    },
    (error, stackTrace) {
      debugPrint('🔴 main 🔴 Uncaught Zone Error: $error');
    },
  );

  // Catch uncaught Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❗ main ❗ Flutter Error: ${details.exception}');
  };
}
