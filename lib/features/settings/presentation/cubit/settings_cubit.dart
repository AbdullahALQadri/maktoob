import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _languageKey = 'app_language';
  static const String _firstLaunchKey = 'first_launch_done';

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(_firstLaunchKey) != true;

      if (isFirstLaunch) {
        // First launch - use device locale
        final deviceLocale = ui.PlatformDispatcher.instance.locale;
        final deviceLanguageCode = deviceLocale.languageCode;

        // Default to Arabic if device language is not English
        final language =
            deviceLanguageCode == 'en' ? AppLanguage.en : AppLanguage.ar;

        // Save the preference
        await prefs.setString(
            _languageKey, language == AppLanguage.ar ? 'ar' : 'en');
        await prefs.setBool(_firstLaunchKey, true);

        emit(state.copyWith(language: language, isLoading: false));
      } else {
        // Not first launch - use saved preference
        final languageCode = prefs.getString(_languageKey) ?? 'ar';
        final language =
            languageCode == 'en' ? AppLanguage.en : AppLanguage.ar;
        emit(state.copyWith(language: language, isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _languageKey, language == AppLanguage.ar ? 'ar' : 'en');
      emit(state.copyWith(language: language, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Get the current locale
  ui.Locale get currentLocale {
    return ui.Locale(state.language == AppLanguage.ar ? 'ar' : 'en');
  }
}
