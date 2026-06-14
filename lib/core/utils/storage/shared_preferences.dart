import 'package:shared_preferences/shared_preferences.dart';

import 'secure_storage_service.dart';

enum PrefKeys { loggedIn, isAdmin, locale, themeMode }

/// SharedPreferences controller for non-sensitive flags only.
///
/// IMPORTANT: Tokens and user credentials are stored in [SecureStorageService].
/// This controller is only for non-sensitive preferences like login state flags,
/// locale, and theme settings.
class SharedPrefController {
  late final SharedPreferences _sharedPreferences;
  final SecureStorageService _secureStorage = SecureStorageService();

  static final SharedPrefController _instance = SharedPrefController._();

  factory SharedPrefController() => _instance;

  SharedPrefController._();

  Future<void> initPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // ===========================================================================
  // TOKEN OPERATIONS (delegated to SecureStorageService)
  // ===========================================================================

  /// Save user token securely and set login flag.
  Future<void> save({required String token}) async {
    await _secureStorage.saveToken(token);
    await _sharedPreferences.setBool(PrefKeys.loggedIn.name, true);
  }

  /// Read token from secure storage.
  Future<String?> getTokenAsync() async {
    return await _secureStorage.getToken();
  }

  /// Read login state flag.
  bool get loggedIn =>
      _sharedPreferences.getBool(PrefKeys.loggedIn.name) ?? false;

  // ===========================================================================
  // NON-SENSITIVE FLAGS
  // ===========================================================================

  /// Save admin flag.
  Future<void> saveBool({required bool admin}) async {
    await _sharedPreferences.setBool(PrefKeys.isAdmin.name, admin);
  }

  /// Read admin flag.
  bool get isAdmin =>
      _sharedPreferences.getBool(PrefKeys.isAdmin.name) ?? false;

  // ===========================================================================
  // CLEAR
  // ===========================================================================

  /// Clear all stored preferences and secure data.
  Future<bool> clear() async {
    await _secureStorage.clearAll();
    return await _sharedPreferences.clear();
  }
}
