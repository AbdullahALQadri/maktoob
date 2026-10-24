import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/fcm_service.dart';
import '../../core/utils/app_strings.dart';
import '../../features/ai_design/data/repositories/ai_design_repository.dart';
import '../../features/ai_design/presentation/cubit/ai_design_cubit.dart';
import '../../features/ai_design/presentation/pages/ai_design_page.dart';
import '../../features/ai_design/presentation/widgets/template_invitation_canvas.dart';
import '../../features/payment/presentation/cubit/payment_cubit.dart';
import '../../features/payment/presentation/screens/payment_upload_screen.dart';

/// Route names still opened by name (with arguments) from the wizard and
/// the event page. Every other screen is pushed directly.
class Routes {
  static const String payment = '/payment';
  static const String aiDesign = '/ai-design';
}

/// Builds the named routes for the app and for each tab's navigator.
class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Payment Upload Screen
      case Routes.payment:
        final args = settings.arguments as Map<String, dynamic>?;
        // A fresh cubit per visit: the app-wide one may still hold the last
        // event's receipt / success state.
        return _buildRoute(
          BlocProvider<PaymentCubit>(
            create: (_) => GetIt.I<PaymentCubit>(),
            child: PaymentUploadScreen(
              eventId: args?['eventId']?.toString(),
              onComplete: args?['onComplete'] ?? () {},
              amount: (args?['amount'] as num?)?.toDouble(),
              eventTitle: args?['eventTitle'] as String?,
              endpoint: args?['endpoint'] as String?,
            ),
          ),
          settings,
        );

      // AI Design Studio — 3-page generation flow
      case Routes.aiDesign:
        final args = settings.arguments as Map<String, dynamic>?;
        final eventId = (args?['eventId'] as int?) ?? 0;
        final eventTypeId = (args?['eventTypeId'] as int?) ?? 0;
        final eventTitle = args?['eventTitle'] as String?;
        if (eventId == 0 || eventTypeId == 0) {
          return _undefinedRoute(settings.name);
        }
        return _buildRoute(
          BlocProvider(
            create: (_) => AiDesignCubit(
              repository: GetIt.I<AiDesignRepository>(),
              fcmService: GetIt.I<FcmService>(),
              eventId: eventId,
              eventTypeId: eventTypeId,
              initialEventTitle: eventTitle,
            ),
            child: AiDesignPage(
              eventId: eventId,
              eventTypeId: eventTypeId,
              eventTitle: eventTitle,
              templateTexts: InvitationTexts(
                names: (args?['names'] as String?) ?? '',
                dateTime: (args?['dateTime'] as String?) ?? '',
                venue: (args?['venue'] as String?) ?? '',
              ),
            ),
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

  /// A name no screen answers to (a programming error, never a user path).
  static Route<dynamic> _undefinedRoute(String? routeName) {
    debugPrint('No route named $routeName');
    return MaterialPageRoute(
      builder: (_) => const Scaffold(body: Center(child: Text(AppStrings.noRoute))),
    );
  }
}
