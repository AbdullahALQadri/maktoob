import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_routes.dart';
import 'config/screens/main_shell.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_strings.dart';
import 'core/widgets/network/offline_wrapper.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';
import 'features/authentication/presentation/cubit/auth_state.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/register_screen.dart';
import 'features/events/presentation/cubit/events_list/events_list_cubit.dart';
import 'features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'features/events/presentation/cubit/create_event/create_event_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/invitation/presentation/cubit/invitation_cubit.dart';
import 'features/invitation/presentation/screens/invitation_flow_shell.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'features/scanner/presentation/cubit/scanner_cubit.dart';
import 'features/venues/presentation/cubit/venues_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'injection_container.dart' as di;

class Maktoob extends StatelessWidget {
  const Maktoob({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth is checked first on app start
        BlocProvider<AuthCubit>(
          lazy: false,
          create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
        ),
        // Home is loaded after authentication
        BlocProvider<HomeCubit>(
          lazy: true,
          create: (_) => di.sl<HomeCubit>(),
        ),
        // Events list is accessed from bottom nav
        BlocProvider<EventsListCubit>(
          lazy: true,
          create: (_) => di.sl<EventsListCubit>(),
        ),
        // Lazy load - only create when event details screen is accessed
        BlocProvider<EventDetailsCubit>(
          lazy: true,
          create: (_) => di.sl<EventDetailsCubit>(),
        ),
        // Lazy load - only create when create event screen is accessed
        BlocProvider<CreateEventCubit>(
          lazy: true,
          create: (_) => di.sl<CreateEventCubit>(),
        ),
        // Lazy load - only create when venues screen is accessed
        BlocProvider<VenuesCubit>(
          lazy: true,
          create: (_) => di.sl<VenuesCubit>(),
        ),
        // Lazy load - only create when scanner screen is accessed
        BlocProvider<ScannerCubit>(
          lazy: true,
          create: (_) => di.sl<ScannerCubit>(),
        ),
        // Lazy load - only create when payment screen is accessed
        BlocProvider<PaymentCubit>(
          lazy: true,
          create: (_) => di.sl<PaymentCubit>(),
        ),
        // Settings is lazy loaded when settings screen is accessed
        BlocProvider<SettingsCubit>(
          lazy: true,
          create: (_) => di.sl<SettingsCubit>(),
        ),
        // Invitation feature - Golden Scenario flow
        BlocProvider<InvitationCubit>(
          lazy: true,
          create: (_) => di.sl<InvitationCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Apply DevicePreview in debug mode
          Widget result = child ?? const SizedBox.shrink();

          if (kDebugMode) {
            result = DevicePreview.appBuilder(context, result);
          }

          // Wrap with OfflineWrapper to show offline banner
          return OfflineWrapper(child: result);
        },
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that handles authentication state and navigation
/// Modified for Golden Scenario: shows invitation flow for unauthenticated users
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showRegister = false;
  bool _showAuthScreens = false; // True when user explicitly wants to login

  void _goToRegister() {
    setState(() {
      _showRegister = true;
      _showAuthScreens = true;
    });
  }

  void _goToLogin() {
    setState(() {
      _showRegister = false;
      _showAuthScreens = true;
    });
  }

  void _goToGoldenFlow() {
    setState(() {
      _showAuthScreens = false;
    });
  }

  void _onAuthSuccess() {
    // Load data after successful authentication
    context.read<HomeCubit>().loadHomeData();
    context.read<EventsListCubit>().loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          // After registration, go to login
          _goToLogin();
        }
      },
      builder: (context, state) {
        // Show loading while checking auth status
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is authenticated - show main app
        if (state is AuthAuthenticated) {
          return const MainShell();
        }

        // User is not authenticated
        // If user explicitly requested auth screens, show them
        if (_showAuthScreens) {
          if (_showRegister) {
            return RegisterScreen(
              onLoginTap: _goToLogin,
              onRegisterSuccess: _goToLogin,
            );
          }
          return LoginScreen(
            onRegisterTap: _goToRegister,
            onLoginSuccess: _onAuthSuccess,
          );
        }

        // Otherwise, show Golden Scenario flow (Landing page first)
        return InvitationFlowShell(
          onLogin: _goToLogin,
          onGoToDashboard: _goToLogin, // Prompt login when going to dashboard
        );
      },
    );
  }
}
