import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_localizations_delegate.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // للحصول على نسخة AppLocalizations من السياق
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // ربط الـ delegate الخاص بهذا الملف مع النظام
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<void> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'lang/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map<String, String>((key, value) {
        return MapEntry(key, value.toString());
      });
    } catch (e) {
      // في حال فشل تحميل الملف، نجعل الخريطة فارغة لمنع الأعطال
      _localizedStrings = {};
    }
  }

  // ترجمة مفتاح نصي
  String translate(String key) {
    return _localizedStrings[key] ?? '** $key not found';
    // return _localizedStrings[key] ?? '**';
  }

  /// Translate [key] if it exists, otherwise return [fallback] unchanged.
  /// Use for values that MIGHT be an i18n key (e.g. the custom-package name,
  /// which is stored as a key) or might already be display text (a standard
  /// package name) — avoids rendering raw keys or "** key not found".
  String translateOr(String key, String fallback) {
    return _localizedStrings[key] ?? fallback;
  }

  // خاصية لمساعدتك في التمييز بين اللغة الإنجليزية وغيرها
  bool get isEnLocale => locale.languageCode == 'en';
}
