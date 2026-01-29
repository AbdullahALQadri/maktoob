import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/locale/app_localizations_setup.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_strings.dart';
import 'core/widgets/network/offline_wrapper.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';
import 'features/authentication/presentation/widgets/auth_wrapper.dart';
import 'features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'features/events/presentation/cubit/events_list/events_list_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/invitation/presentation/cubit/invitation_cubit.dart';
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
          final locale = Locale(
            settingsState.language == AppLanguage.ar
                ? 'ar'
                : settingsState.language == AppLanguage.tr
                    ? 'tr'
                    : 'en',
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
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
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
