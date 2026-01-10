import 'package:equatable/equatable.dart';

enum AppLanguage { ar, en }

class SettingsState extends Equatable {
  final AppLanguage language;
  final bool isLoading;

  const SettingsState({
    this.language = AppLanguage.ar, // Arabic as default
    this.isLoading = false,
  });

  SettingsState copyWith({
    AppLanguage? language,
    bool? isLoading,
  }) {
    return SettingsState(
      language: language ?? this.language,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [language, isLoading];
}
