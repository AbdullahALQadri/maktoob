import 'package:flutter/material.dart';

import '../../core/utils/app_strings.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';

/// Route names used across the app to avoid typos and ensure maintainability.
class Routes {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String createEvent = '/create-event';
}

/// Main AppRoutes class to manage routing logic.
class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Initial Route - Create Event Screen (Home Page)
      case Routes.initial:
        return _buildRoute(const CreateEventScreen(), settings);

      // Splash Screen
      case Routes.splash:
        return _buildRoute(const SplashScreen(), settings);

      // Create Event Screen
      case Routes.createEvent:
        return _buildRoute(const CreateEventScreen(), settings);

      // Fallback
      default:
        return _undefinedRoute(settings.name);
    }
  }

  /// Helper to return a MaterialPageRoute for a screen
  static MaterialPageRoute _buildRoute(Widget screen, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => screen, settings: settings);
  }

  /// Route for undefined screens
  static Route<dynamic> _undefinedRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Route Not Found")),
        body: Center(
          child: Text("${AppStrings.noRoute}\n\nRoute: $routeName"),
        ),
      ),
    );
  }
}
