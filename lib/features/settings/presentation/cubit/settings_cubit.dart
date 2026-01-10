import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  static const String _languageKey = 'app_language';

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'ar';
      final language = languageCode == 'en' ? AppLanguage.en : AppLanguage.ar;
      emit(state.copyWith(language: language, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language == AppLanguage.ar ? 'ar' : 'en');
      emit(state.copyWith(language: language, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
