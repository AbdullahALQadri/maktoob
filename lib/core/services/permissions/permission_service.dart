import 'package:flutter/foundation.dart';

/// A service class for managing app permissions.
///
/// This service provides a unified API for requesting and checking
/// various device permissions like camera, location, storage, etc.
///
/// Example usage:
/// ```dart
/// // Check camera permission
/// final hasCamera = await PermissionService.instance.hasPermission(
///   AppPermission.camera,
/// );
///
/// // Request permission
/// if (!hasCamera) {
///   final granted = await PermissionService.instance.requestPermission(
///     AppPermission.camera,
///   );
/// }
/// ```
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  /// Returns the singleton instance of PermissionService.
  static PermissionService get instance => _instance;

  PermissionService._internal();

  /// Checks if a permission is granted.
  Future<bool> hasPermission(AppPermission permission) async {
    try {
      // Implementation depends on permission_handler package
      // Uncomment and implement when the package is added
      /*
      final Permission p = _mapPermission(permission);
      final status = await p.status;
      return status.isGranted;
      */
      return true;
    } catch (e) {
      debugPrint('Check permission error: $e');
      return false;
    }
  }

  /// Requests a permission.
  ///
  /// Returns `true` if the permission was granted, `false` otherwise.
  Future<bool> requestPermission(AppPermission permission) async {
    try {
      // Implementation depends on permission_handler package
      // Uncomment and implement when the package is added
      /*
      final Permission p = _mapPermission(permission);
      final status = await p.request();
      return status.isGranted;
      */
      debugPrint('Requested permission: ${permission.name}');
      return true;
    } catch (e) {
      debugPrint('Request permission error: $e');
      return false;
    }
  }

  /// Requests multiple permissions at once.
  ///
  /// Returns a map of permission to granted status.
  Future<Map<AppPermission, bool>> requestPermissions(
    List<AppPermission> permissions,
  ) async {
    final results = <AppPermission, bool>{};

    for (final permission in permissions) {
      results[permission] = await requestPermission(permission);
    }

    return results;
  }

  /// Checks if a permission is permanently denied.
  Future<bool> isPermanentlyDenied(AppPermission permission) async {
    try {
      // Implementation depends on permission_handler package
      /*
      final Permission p = _mapPermission(permission);
      final status = await p.status;
      return status.isPermanentlyDenied;
      */
      return false;
    } catch (e) {
      debugPrint('Check permanently denied error: $e');
      return false;
    }
  }

  /// Opens app settings where the user can grant permissions.
  Future<bool> openAppSettings() async {
    try {
      // Implementation depends on permission_handler package
      // return await openAppSettings();
      debugPrint('Opening app settings');
      return true;
    } catch (e) {
      debugPrint('Open app settings error: $e');
      return false;
    }
  }

  /// Gets the current status of a permission.
  Future<PermissionStatus> getPermissionStatus(AppPermission permission) async {
    try {
      // Implementation depends on permission_handler package
      /*
      final Permission p = _mapPermission(permission);
      final status = await p.status;

      if (status.isGranted) return PermissionStatus.granted;
      if (status.isDenied) return PermissionStatus.denied;
      if (status.isPermanentlyDenied) return PermissionStatus.permanentlyDenied;
      if (status.isRestricted) return PermissionStatus.restricted;
      if (status.isLimited) return PermissionStatus.limited;
      */
      return PermissionStatus.granted;
    } catch (e) {
      debugPrint('Get permission status error: $e');
      return PermissionStatus.unknown;
    }
  }

  /// Checks if should show rationale for a permission.
  Future<bool> shouldShowRationale(AppPermission permission) async {
    try {
      // Implementation depends on permission_handler package
      /*
      final Permission p = _mapPermission(permission);
      return await p.shouldShowRequestRationale;
      */
      return false;
    } catch (e) {
      debugPrint('Should show rationale error: $e');
      return false;
    }
  }

  /// Requests camera permission.
  Future<bool> requestCameraPermission() async {
    return requestPermission(AppPermission.camera);
  }

  /// Requests location permission.
  Future<bool> requestLocationPermission({bool always = false}) async {
    return requestPermission(
      always ? AppPermission.locationAlways : AppPermission.locationWhenInUse,
    );
  }

  /// Requests storage permission.
  Future<bool> requestStoragePermission() async {
    return requestPermission(AppPermission.storage);
  }

  /// Requests notification permission.
  Future<bool> requestNotificationPermission() async {
    return requestPermission(AppPermission.notification);
  }

  /// Requests microphone permission.
  Future<bool> requestMicrophonePermission() async {
    return requestPermission(AppPermission.microphone);
  }

  /// Requests contacts permission.
  Future<bool> requestContactsPermission() async {
    return requestPermission(AppPermission.contacts);
  }

  /// Requests calendar permission.
  Future<bool> requestCalendarPermission() async {
    return requestPermission(AppPermission.calendar);
  }

  /// Requests photos permission.
  Future<bool> requestPhotosPermission() async {
    return requestPermission(AppPermission.photos);
  }
}

/// App permissions that can be requested.
enum AppPermission {
  camera,
  microphone,
  locationWhenInUse,
  locationAlways,
  storage,
  photos,
  contacts,
  calendar,
  notification,
  bluetooth,
  phone,
  sms,
  sensors,
  mediaLibrary,
}

/// Status of a permission.
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  unknown,
}

/// Helper extension on PermissionStatus.
extension PermissionStatusExtension on PermissionStatus {
  /// Returns true if the permission is granted.
  bool get isGranted => this == PermissionStatus.granted;

  /// Returns true if the permission is denied.
  bool get isDenied => this == PermissionStatus.denied;

  /// Returns true if the permission is permanently denied.
  bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;

  /// Returns true if the permission is restricted.
  bool get isRestricted => this == PermissionStatus.restricted;

  /// Returns true if the permission is limited.
  bool get isLimited => this == PermissionStatus.limited;
}
