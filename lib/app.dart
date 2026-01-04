import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'config/locale/app_localizations_setup.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_strings.dart';
import 'injection_container.dart';

class Maktoob extends StatelessWidget {
  const Maktoob({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // locale: localeState.locale,
      builder: DevicePreview.appBuilder,
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // supportedLocales: AppLocalizationsSetup.supportedLocales,
      // localeResolutionCallback:
      // AppLocalizationsSetup.localeResolutionCallback,
      // localizationsDelegates:
      // AppLocalizationsSetup.localizationsDelegates,
    );
  }
}
