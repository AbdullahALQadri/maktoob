import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Keys for secure storage items.
class SecureStorageKeys {
  static const String token = 'auth_token';

  /// Dedicated token for the scanner-staff session (kept separate from the
  /// client token so a scanner login does not clobber the organizer session).
  static const String scannerToken = 'scanner_auth_token';
}

/// Keys for Hive cache boxes.
class HiveBoxes {
  static const String cache = 'app_cache';
  static const String events = 'events_cache';
  static const String venues = 'venues_cache';
  static const String home = 'home_cache';
}

/// Encrypted secure storage service for sensitive data (tokens, user info).
///
/// Uses [FlutterSecureStorage] for tokens and credentials.
/// Uses [Hive] for API response caching and offline data.
class SecureStorageService {
  late final FlutterSecureStorage _secureStorage;
  late final Box _cacheBox;

  static final SecureStorageService _instance = SecureStorageService._();

  factory SecureStorageService() => _instance;

  SecureStorageService._();

  /// Initialize Hive and open cache boxes.
  Future<void> init() async {
    await Hive.initFlutter();

    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    _cacheBox = await Hive.openBox(HiveBoxes.cache);
  }

  // ===========================================================================
  // SECURE TOKEN STORAGE (encrypted)
  // ===========================================================================

  /// Save authentication token securely.
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: SecureStorageKeys.token, value: token);
  }

  /// Read authentication token.
  Future<String?> getToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.token);
  }

  /// Check if token exists (user is logged in).
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all secure storage (on logout).
  Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }

  // ===========================================================================
  // SCANNER-STAFF TOKEN (separate session from the client token)
  // ===========================================================================

  Future<void> saveScannerToken(String token) async {
    await _secureStorage.write(key: SecureStorageKeys.scannerToken, value: token);
  }

  Future<String?> getScannerToken() async {
    return await _secureStorage.read(key: SecureStorageKeys.scannerToken);
  }

  Future<void> clearScannerToken() async {
    await _secureStorage.delete(key: SecureStorageKeys.scannerToken);
  }

  // ===========================================================================
  // HIVE CACHE STORAGE (for API caching & offline data)
  // ===========================================================================

  /// Cache API response data with a key.
  Future<void> cacheData(String key, dynamic data) async {
    await _cacheBox.put(key, data);
  }

  /// Read cached data by key.
  dynamic getCachedData(String key) {
    return _cacheBox.get(key);
  }

  /// Check if cache exists for a key.
  bool hasCachedData(String key) {
    return _cacheBox.containsKey(key);
  }

  /// Remove specific cached data.
  Future<void> removeCachedData(String key) async {
    await _cacheBox.delete(key);
  }

  /// Clear all cached data.
  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  /// Clear everything (secure + cache) on logout.
  Future<void> clearAll() async {
    await clearSecureData();
    await clearCache();
  }
}
