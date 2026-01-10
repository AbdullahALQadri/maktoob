import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A service class for managing biometric authentication.
///
/// This service provides biometric authentication capabilities
/// including fingerprint and face recognition support.
///
/// Example usage:
/// ```dart
/// // Check if biometrics are available
/// final isAvailable = await BiometricService.instance.isBiometricAvailable();
///
/// // Authenticate
/// if (isAvailable) {
///   final success = await BiometricService.instance.authenticate(
///     reason: 'Please authenticate to access your account',
///   );
///   if (success) {
///     // Authentication successful
///   }
/// }
/// ```
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  /// Returns the singleton instance of BiometricService.
  static BiometricService get instance => _instance;

  BiometricService._internal();

  /// Whether to use fake authentication for testing.
  bool useFakeAuth = false;

  /// Available biometric types on the device.
  List<BiometricType> _availableBiometrics = [];

  /// Returns the available biometric types.
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  /// Checks if biometric authentication is available on the device.
  Future<bool> isBiometricAvailable() async {
    if (useFakeAuth) return true;

    try {
      // Implementation depends on local_auth package
      // Uncomment and implement when the package is added
      /*
      final LocalAuthentication auth = LocalAuthentication();
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        final biometrics = await auth.getAvailableBiometrics();
        _availableBiometrics = biometrics.map((b) {
          switch (b) {
            case LocalAuthBiometricType.fingerprint:
              return BiometricType.fingerprint;
            case LocalAuthBiometricType.face:
              return BiometricType.face;
            case LocalAuthBiometricType.iris:
              return BiometricType.iris;
            default:
              return BiometricType.unknown;
          }
        }).toList();
        return biometrics.isNotEmpty;
      }
      */
      return false;
    } on PlatformException catch (e) {
      debugPrint('Biometric availability check error: $e');
      return false;
    } catch (e) {
      debugPrint('Biometric availability error: $e');
      return false;
    }
  }

  /// Authenticates the user using biometrics.
  ///
  /// Returns `true` if authentication is successful, `false` otherwise.
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = true,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    if (useFakeAuth) {
      debugPrint('Using fake biometric authentication');
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    try {
      // Implementation depends on local_auth package
      // Uncomment and implement when the package is added
      /*
      final LocalAuthentication auth = LocalAuthentication();

      final result = await auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
        ),
      );

      debugPrint('Biometric authentication result: $result');
      return result;
      */
      return false;
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Cancels any ongoing authentication.
  Future<void> cancelAuthentication() async {
    // Implementation depends on local_auth package
    // await LocalAuthentication().stopAuthentication();
    debugPrint('Biometric authentication cancelled');
  }

  /// Checks if the device has enrolled biometrics.
  Future<bool> hasEnrolledBiometrics() async {
    if (useFakeAuth) return true;

    try {
      // Implementation depends on local_auth package
      /*
      final LocalAuthentication auth = LocalAuthentication();
      final biometrics = await auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
      */
      return false;
    } catch (e) {
      debugPrint('Check enrolled biometrics error: $e');
      return false;
    }
  }

  /// Returns whether fingerprint authentication is available.
  bool get hasFingerprintSupport =>
      _availableBiometrics.contains(BiometricType.fingerprint);

  /// Returns whether face authentication is available.
  bool get hasFaceIdSupport =>
      _availableBiometrics.contains(BiometricType.face);

  /// Returns a user-friendly name for the available biometric.
  String get biometricName {
    if (hasFaceIdSupport) return 'Face ID';
    if (hasFingerprintSupport) return 'Fingerprint';
    return 'Biometric';
  }

  /// Sets whether to use fake authentication (for testing).
  void setFakeAuth(bool value) {
    useFakeAuth = value;
  }
}

/// Types of biometric authentication.
enum BiometricType {
  fingerprint,
  face,
  iris,
  unknown,
}

/// Result of a biometric authentication attempt.
class BiometricResult {
  final bool success;
  final BiometricError? error;
  final String? message;

  const BiometricResult({
    required this.success,
    this.error,
    this.message,
  });

  factory BiometricResult.success() {
    return const BiometricResult(success: true);
  }

  factory BiometricResult.failure(BiometricError error, {String? message}) {
    return BiometricResult(
      success: false,
      error: error,
      message: message,
    );
  }
}

/// Possible biometric authentication errors.
enum BiometricError {
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  cancelled,
  timeout,
  unknown,
}
