import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:maktoob/features/authentication/presentation/screens/splash_screen.dart';

import 'config/locale/app_localizations_setup.dart';
import 'config/screens/main_shell.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_colors.dart';
import 'core/utils/app_strings.dart';
import 'core/widgets/network/offline_wrapper.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';
import 'features/authentication/presentation/cubit/auth_state.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/register_screen.dart';
import 'features/events/presentation/cubit/create_event/create_event_cubit.dart';
import 'features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'features/events/presentation/cubit/events_list/events_list_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/invitation/presentation/cubit/invitation_cubit.dart';
import 'features/invitation/presentation/screens/invitation_wizard_screen.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'features/scanner/presentation/cubit/scanner_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'features/venues/presentation/cubit/venues_cubit.dart';
import 'injection_container.dart' as di;

class Maktoob extends StatelessWidget {
  const Maktoob({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Settings is loaded first for language preference
        BlocProvider<SettingsCubit>(
          lazy: false,
          create: (_) => di.sl<SettingsCubit>(),
        ),
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
        // Invitation feature - Golden Scenario flow
        BlocProvider<InvitationCubit>(
          lazy: true,
          create: (_) => di.sl<InvitationCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final isArabic = settingsState.language == AppLanguage.ar;
          final locale = Locale(isArabic ? 'ar' : 'en');

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // Apply DevicePreview in debug mode
              Widget result = child ?? const SizedBox.shrink();

              if (kDebugMode) {
                result = DevicePreview.appBuilder(context, result);
              }

              // Wrap with OfflineWrapper to show offline banner
              // Also wrap with Directionality for RTL/LTR support
              return Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: OfflineWrapper(child: result),
              );
            },
            title: AppStrings.appName,
            // theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            // Localization settings
            locale: locale,
            supportedLocales: AppLocalizationsSetup.supportedLocales,
            localizationsDelegates:
                AppLocalizationsSetup.localizationsDelegates,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              return AppLocalizationsSetup.localeResolutionCallback(
                deviceLocale,
                supportedLocales,
              );
            },
            // home: const SplashScreen(),
            // home: const AuthWrapper(),
            home: const MainShell(),
          );
        },
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
  bool _showAuthScreens = true; // Start with auth screens by default

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
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
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

        // Otherwise, show new 7-page event wizard
        return InvitationWizardScreen(
          onLogin: _goToLogin,
          onComplete: _goToLogin, // Prompt login when wizard completes
        );
      },
    );
  }
}
