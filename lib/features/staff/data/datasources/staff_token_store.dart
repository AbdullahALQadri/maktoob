import '../../../../core/utils/storage/secure_storage_service.dart';

/// Where the staff sign-in is kept. Its own key: the client's sign-in (and
/// its sign-out) never touch it.
abstract class StaffTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

extension StaffPhone on StaffTokenStore {
  /// A member of the team is signed in on this phone.
  Future<bool> get hasSignIn async => (await read() ?? '').isNotEmpty;
}

class SecureStaffTokenStore implements StaffTokenStore {
  const SecureStaffTokenStore();

  static const _key = 'staff_token';

  @override
  Future<String?> read() => SecureStorageService.storage.read(key: _key);

  @override
  Future<void> write(String token) => SecureStorageService.storage.write(key: _key, value: token);

  @override
  Future<void> clear() => SecureStorageService.storage.delete(key: _key);
}
