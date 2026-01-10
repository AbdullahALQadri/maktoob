import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A service class for managing local storage using SharedPreferences.
///
/// This service provides a clean API for storing and retrieving data locally.
/// It supports primitive types (String, int, double, bool) as well as
/// JSON-encodable objects.
///
/// Example usage:
/// ```dart
/// // Initialize
/// await SharedPreferencesService.instance.init();
///
/// // Save and retrieve values
/// await SharedPreferencesService.instance.setString('username', 'john_doe');
/// final username = SharedPreferencesService.instance.getString('username');
///
/// // Save and retrieve objects
/// await SharedPreferencesService.instance.setObject('user', user.toJson());
/// final userData = SharedPreferencesService.instance.getObject('user');
/// ```
class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  /// Returns the singleton instance of SharedPreferencesService.
  static SharedPreferencesService get instance => _instance;

  SharedPreferences? _prefs;

  SharedPreferencesService._internal();

  /// Initializes the SharedPreferences instance.
  /// Must be called before using any other methods.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Throws an exception if the service is not initialized.
  void _ensureInitialized() {
    if (_prefs == null) {
      throw Exception(
        'SharedPreferencesService not initialized. Call init() first.',
      );
    }
  }

  // ===== String Operations =====

  /// Saves a string value.
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    return await _prefs!.setString(key, value);
  }

  /// Retrieves a string value.
  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// Retrieves a string value with a default fallback.
  String getStringOrDefault(String key, {String defaultValue = ''}) {
    return getString(key) ?? defaultValue;
  }

  // ===== Int Operations =====

  /// Saves an integer value.
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    return await _prefs!.setInt(key, value);
  }

  /// Retrieves an integer value.
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// Retrieves an integer value with a default fallback.
  int getIntOrDefault(String key, {int defaultValue = 0}) {
    return getInt(key) ?? defaultValue;
  }

  // ===== Double Operations =====

  /// Saves a double value.
  Future<bool> setDouble(String key, double value) async {
    _ensureInitialized();
    return await _prefs!.setDouble(key, value);
  }

  /// Retrieves a double value.
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  /// Retrieves a double value with a default fallback.
  double getDoubleOrDefault(String key, {double defaultValue = 0.0}) {
    return getDouble(key) ?? defaultValue;
  }

  // ===== Bool Operations =====

  /// Saves a boolean value.
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    return await _prefs!.setBool(key, value);
  }

  /// Retrieves a boolean value.
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// Retrieves a boolean value with a default fallback.
  bool getBoolOrDefault(String key, {bool defaultValue = false}) {
    return getBool(key) ?? defaultValue;
  }

  // ===== StringList Operations =====

  /// Saves a list of strings.
  Future<bool> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    return await _prefs!.setStringList(key, value);
  }

  /// Retrieves a list of strings.
  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  /// Retrieves a list of strings with a default fallback.
  List<String> getStringListOrDefault(String key,
      {List<String> defaultValue = const []}) {
    return getStringList(key) ?? defaultValue;
  }

  // ===== Object Operations (JSON) =====

  /// Saves a JSON-encodable object.
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    _ensureInitialized();
    final jsonString = jsonEncode(value);
    return await _prefs!.setString(key, jsonString);
  }

  /// Retrieves a JSON object.
  Map<String, dynamic>? getObject(String key) {
    _ensureInitialized();
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Saves a list of JSON-encodable objects.
  Future<bool> setObjectList(
      String key, List<Map<String, dynamic>> value) async {
    _ensureInitialized();
    final jsonString = jsonEncode(value);
    return await _prefs!.setString(key, jsonString);
  }

  /// Retrieves a list of JSON objects.
  List<Map<String, dynamic>>? getObjectList(String key) {
    _ensureInitialized();
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  // ===== Utility Operations =====

  /// Checks if a key exists.
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Removes a value by key.
  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs!.remove(key);
  }

  /// Removes multiple values by keys.
  Future<void> removeAll(List<String> keys) async {
    _ensureInitialized();
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }

  /// Clears all stored values.
  Future<bool> clear() async {
    _ensureInitialized();
    return await _prefs!.clear();
  }

  /// Returns all stored keys.
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }

  /// Reloads the cached preferences.
  Future<void> reload() async {
    _ensureInitialized();
    await _prefs!.reload();
  }
}

/// Common preference keys used throughout the app.
class PreferenceKeys {
  PreferenceKeys._();

  // Auth
  static const String isLoggedIn = 'is_logged_in';
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';

  // User preferences
  static const String isDarkMode = 'is_dark_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';

  // Onboarding
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String isFirstLaunch = 'is_first_launch';

  // App settings
  static const String lastSyncTime = 'last_sync_time';
  static const String appVersion = 'app_version';

  // Biometric
  static const String biometricEnabled = 'biometric_enabled';
}
