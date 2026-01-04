// import 'package:flutter/cupertino.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
//
// import '../../core/utils/app_strings.dart';
// import 'app_localizations.dart';
//
// class AppLocalizationsSetup {
//   static const Iterable<Locale> supportedLocales = [
//     // Locale('en'),
//     Locale(AppStrings.englishCode),
//     // Locale('ar'),
//     Locale(AppStrings.arabicCode),
//
//     // Locale('uk'),
//     Locale(AppStrings.ukrainianCode),
//   ];
//
//   static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
//       [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//         DefaultCupertinoLocalizations.delegate,
//       ];
//
//   static Locale localeResolutionCallback(
//     Locale? deviceLocale,
//     Iterable<Locale> supportedLocales,
//   ) {
//     if (deviceLocale != null) {
//       for (Locale supportedLocale in supportedLocales) {
//         if (supportedLocale.languageCode == deviceLocale.languageCode) {
//           return supportedLocale;
//         }
//       }
//     }
//     // لو لم يتم العثور على لغة متطابقة نرجع اللغة الأولى (الإنجليزية مثلاً)
//     return supportedLocales.first;
//   }
// }
