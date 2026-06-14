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

  static AppLanguage _languageFromCode(String code) {
    switch (code) {
      case 'en':
        return AppLanguage.en;
      case 'tr':
        return AppLanguage.tr;
      default:
        return AppLanguage.ar;
    }
  }

  static String _codeFromLanguage(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'en';
      case AppLanguage.tr:
        return 'tr';
      case AppLanguage.ar:
        return 'ar';
    }
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

        final language = _languageFromCode(deviceLanguageCode);

        // Save the preference
        await prefs.setString(_languageKey, _codeFromLanguage(language));
        await prefs.setBool(_firstLaunchKey, true);

        emit(state.copyWith(language: language, isLoading: false));
      } else {
        // Not first launch - use saved preference
        final languageCode = prefs.getString(_languageKey) ?? 'ar';
        final language = _languageFromCode(languageCode);
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
      await prefs.setString(_languageKey, _codeFromLanguage(language));
      emit(state.copyWith(language: language, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
