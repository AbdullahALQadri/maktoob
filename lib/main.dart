import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'bloc_observer.dart';
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

      // Run orientation lock and DI initialization in parallel for faster startup
      await Future.wait([
        di.init(),
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]),
      ]);

      // Set up BLoC Observer only in debug mode to reduce overhead in release
      if (kDebugMode) {
        Bloc.observer = MyBlocObserver();
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
