import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Keys for secure storage items.
class SecureStorageKeys {
  static const String token = 'auth_token';

  /// Door tokens (paired staff phones, scanner accounts) live under this
  /// prefix. They survive the host's logout and a 401 on the client token:
  /// a door phone must never lose its way to upload check-ins.
  static const String doorPrefix = 'door_';
}

/// Keys for Hive cache boxes.
class HiveBoxes {
  static const String cache = 'app_cache';
  static const String events = 'events_cache';
  static const String venues = 'venues_cache';
  static const String home = 'home_cache';

  /// Last good response of cacheable GETs, served when offline
  /// (OfflineCacheInterceptor).
  static const String http = 'http_cache';
}

/// Encrypted secure storage service for sensitive data (tokens, user info).
///
/// Uses [FlutterSecureStorage] for tokens and credentials.
/// Uses [Hive] for API response caching and offline data.
class SecureStorageService {
  late final FlutterSecureStorage _secureStorage;
  late final Box _cacheBox;
  late final Box _httpBox;

  static final SecureStorageService _instance = SecureStorageService._();

  factory SecureStorageService() => _instance;

  SecureStorageService._();

  /// The one storage configuration. The background sync isolate builds its
  /// own instance with exactly these options, or it could not read the keys.
  static const FlutterSecureStorage storage = FlutterSecureStorage(
    // v10 moves data saved under v9's EncryptedSharedPreferences to its own
    // ciphers on first read. Keep a backup while it does and never wipe on an
    // error: door tokens must survive (pending check-ins depend on them).
    // Stay on v10 until every installed app has run it once; v11 can no
    // longer read v9 data.
    aOptions: AndroidOptions(migrateWithBackup: true, resetOnError: false),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Initialize Hive and open cache boxes.
  Future<void> init() async {
    await Hive.initFlutter();

    _secureStorage = storage;

    _cacheBox = await Hive.openBox(HiveBoxes.cache);
    _httpBox = await Hive.openBox(HiveBoxes.http);
  }

  /// Cached GET responses (see OfflineCacheInterceptor).
  Box get httpCache => _httpBox;

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

  /// Door secrets (tokens of paired / scanner door sessions).
  Future<void> writeDoorSecret(String key, String value) =>
      _secureStorage.write(key: '${SecureStorageKeys.doorPrefix}$key', value: value);

  Future<String?> readDoorSecret(String key) =>
      _secureStorage.read(key: '${SecureStorageKeys.doorPrefix}$key');

  Future<void> deleteDoorSecret(String key) =>
      _secureStorage.delete(key: '${SecureStorageKeys.doorPrefix}$key');

  /// Clear the account's secure data (on logout or a 401). Door secrets
  /// stay: their check-ins may not be uploaded yet.
  Future<void> clearSecureData() async {
    final all = await _secureStorage.readAll();
    for (final key in all.keys) {
      if (!key.startsWith(SecureStorageKeys.doorPrefix)) {
        await _secureStorage.delete(key: key);
      }
    }
  }

  // ===========================================================================
  // HIVE CACHE STORAGE (for API caching & offline data)
  // ===========================================================================

  /// Clear all cached data.
  Future<void> clearCache() async {
    await _cacheBox.clear();
    await _httpBox.clear();
  }

  /// Clear everything (secure + cache) on logout.
  Future<void> clearAll() async {
    await clearSecureData();
    await clearCache();
  }
}
