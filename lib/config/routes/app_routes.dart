
import 'package:flutter/material.dart';

import '../../core/utils/app_strings.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';

/// Route names used across the app to avoid typos and ensure maintainability.
class Routes {
  static const String initial = '/';

}

/// Main AppRoutes class to manage routing logic.
class AppRoutes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Initial Splash Screen
      case Routes.initial:
        return _buildRoute(const SplashScreen(), settings);



      // Profile

      // case Routes.helpCenter:
      //   return _buildRoute(HelpCenterScreen(), settings);
      // case Routes.botChat:
      //   return _buildRoute(
      //     BlocProvider(
      //       create: (context) => sl<BotChatCubit>(),
      //       child: BotChatScreen(),
      //     ),
      //     settings,
      //   );

      ////////////////////////////////////// How to Add Advanced Route with Arguments + Bloc?
      // case '/client-task':
      //   final args = settings.arguments as List;
      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => MultiBlocProvider(
      //       providers: [
      //         BlocProvider(create: (_) => di.sl<MaidTasksCubit>()),
      //         BlocProvider(create: (_) => di.sl<PostTaskkCubit>()),
      //         BlocProvider(create: (_) => di.sl<StoreTaskCubit>()),
      //       ],
      //       child: MaidPageTaskScreen(
      //         initialTabIndex: args[0],
      //         startDate: args[1],
      //         endDate: args[2],
      //       ),
      //     ),
      //   );
      /////////////////////////////////////////////////////////////////////////////////
      ///////////////////////////////////////////////////Optional: Pass Arguments Example
      //Navigate with:
      //  Navigator.pushNamed(
      //    context,
      //    Routes.productDetails,
      //    arguments: {'id': 1, 'title': 'Shoes'},
      //  );
      ////In your route:
      // case Routes.productDetails:
      //   try {
      //     final args = settings.arguments as Map<String, dynamic>;
      //     return _buildRoute(ProductDetailsScreen(id: args['id']), settings);
      //   } catch (_) {
      //     return _undefinedRoute(settings.name);
      //   }
      /////////////////////////////////////////////////////////////////////////////////

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
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text("Route Not Found")),
            body: Center(
              child: Text("${AppStrings.noRoute}\n\nRoute: $routeName"),
            ),
          ),
    );
  }
}
