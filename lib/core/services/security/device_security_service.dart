import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';

/// Service for device security checks (root/jailbreak detection).
///
/// Checks if the device is compromised before allowing sensitive operations.
/// In debug mode, checks are skipped to allow development on emulators.
class DeviceSecurityService {
  static final DeviceSecurityService _instance = DeviceSecurityService._();

  factory DeviceSecurityService() => _instance;

  DeviceSecurityService._();

  bool _isDeviceSecure = true;
  bool _hasChecked = false;

  /// Whether the device passed all security checks.
  bool get isDeviceSecure => _isDeviceSecure;

  /// Run all device security checks.
  ///
  /// Returns `true` if the device is safe, `false` if compromised.
  /// In debug mode, always returns `true`.
  Future<bool> checkDeviceSecurity() async {
    if (_hasChecked) return _isDeviceSecure;

    // Skip security checks in debug mode for development convenience
    if (kDebugMode) {
      _isDeviceSecure = true;
      _hasChecked = true;
      return true;
    }

    try {
      final isJailBroken = await SafeDevice.isJailBroken;
      final isRealDevice = await SafeDevice.isRealDevice;

      _isDeviceSecure = !isJailBroken && isRealDevice;
      _hasChecked = true;

      if (!_isDeviceSecure) {
        debugPrint('Device security check failed: '
            'jailbroken=$isJailBroken, realDevice=$isRealDevice');
      }

      return _isDeviceSecure;
    } catch (e) {
      debugPrint('Device security check error: $e');
      // Fail open in case of error to avoid blocking users
      _isDeviceSecure = true;
      _hasChecked = true;
      return true;
    }
  }

  /// Reset cached check result (for re-checking).
  void reset() {
    _hasChecked = false;
    _isDeviceSecure = true;
  }
}
