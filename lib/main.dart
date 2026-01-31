import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'bloc_observer.dart';
import 'core/services/security/device_security_service.dart';
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

      // Run device security check (root/jailbreak detection)
      final securityService = di.sl<DeviceSecurityService>();
      await securityService.checkDeviceSecurity();

      // Set up BLoC Observer only in debug mode to reduce overhead in release
      if (kDebugMode) {
        Bloc.observer = MyBlocObserver();
      }

      // Block compromised devices in release mode
      if (!securityService.isDeviceSecure) {
        runApp(const _CompromisedDeviceApp());
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

/// Shown when the device fails security checks (rooted/jailbroken).
class _CompromisedDeviceApp extends StatelessWidget {
  const _CompromisedDeviceApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Security Warning',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This app cannot run on rooted or jailbroken devices for security reasons.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
