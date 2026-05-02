import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/fcm_service.dart';
import '../../core/utils/app_strings.dart';
import '../../features/ai_design/data/repositories/ai_design_repository.dart';
import '../../features/ai_design/presentation/cubit/ai_design_cubit.dart';
import '../../features/ai_design/presentation/pages/ai_design_page.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/events/presentation/screens/event_details_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/venues/presentation/screens/venue_screen.dart';
import '../../features/scanner/presentation/screens/scanner_events_screen.dart';
import '../../features/payment/presentation/screens/payment_upload_screen.dart';
import '../screens/main_shell.dart';

/// Route names used across the app to avoid typos and ensure maintainability.
class Routes {
  static const String initial     = '/';
  static const String splash      = '/splash';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String main        = '/main';
  static const String home        = '/home';
  static const String eventDetails = '/event-details';
  static const String venue       = '/venue';
  static const String scanner     = '/scanner';
  static const String payment     = '/payment';
  static const String aiDesign    = '/ai-design';
}

/// Main AppRoutes class to manage routing logic.
class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Initial Route - Main Shell with bottom navigation
      case Routes.initial:
        return _buildRoute(const MainShell(), settings);

      // Splash Screen
      case Routes.splash:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          SplashScreen(onFinished: args?['onFinished'] ?? () {}),
          settings,
        );

      // Login Screen
      case Routes.login:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          LoginScreen(
            onRegisterTap: args?['onRegisterTap'],
            onLoginSuccess: args?['onLoginSuccess'],
          ),
          settings,
        );

      // Register Screen
      case Routes.register:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          RegisterScreen(
            onLoginTap: args?['onLoginTap'],
            onRegisterSuccess: args?['onRegisterSuccess'],
          ),
          settings,
        );

      // Main Shell with navigation
      case Routes.main:
        return _buildRoute(const MainShell(), settings);

      // Home Screen
      case Routes.home:
        return _buildRoute(const HomeScreen(), settings);

      // Event Details Screen
      case Routes.eventDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          EventDetailsScreen(
            eventId: args?['eventId'] ?? '',
            onBack: args?['onBack'] ?? () {},
          ),
          settings,
        );

      // Venue Screen
      case Routes.venue:
        return _buildRoute(const VenueScreen(), settings);

      // QR Scanner Screen (Events Selection)
      case Routes.scanner:
        return _buildRoute(const ScannerEventsScreen(), settings);

      // Payment Upload Screen
      case Routes.payment:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          PaymentUploadScreen(
            eventId: args?['eventId'],
            onComplete: args?['onComplete'] ?? () {},
          ),
          settings,
        );

      // AI Design Studio — 3-page generation flow
      case Routes.aiDesign:
        final args        = settings.arguments as Map<String, dynamic>?;
        final eventId     = (args?['eventId']     as int?) ?? 0;
        final eventTypeId = (args?['eventTypeId'] as int?) ?? 0;
        if (eventId == 0 || eventTypeId == 0) {
          return _undefinedRoute(settings.name);
        }
        return _buildRoute(
          BlocProvider(
            create: (_) => AiDesignCubit(
              repository:  GetIt.I<AiDesignRepository>(),
              fcmService:  GetIt.I<FcmService>(),
              eventId:     eventId,
              eventTypeId: eventTypeId,
            ),
            child: AiDesignPage(eventId: eventId, eventTypeId: eventTypeId),
          ),
          settings,
        );

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
