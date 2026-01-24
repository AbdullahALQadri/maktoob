import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

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

  /// Maps AppPermission to permission_handler Permission.
  ph.Permission _mapPermission(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return ph.Permission.camera;
      case AppPermission.microphone:
        return ph.Permission.microphone;
      case AppPermission.locationWhenInUse:
        return ph.Permission.locationWhenInUse;
      case AppPermission.locationAlways:
        return ph.Permission.locationAlways;
      case AppPermission.storage:
        return ph.Permission.storage;
      case AppPermission.photos:
        return ph.Permission.photos;
      case AppPermission.contacts:
        return ph.Permission.contacts;
      case AppPermission.calendar:
        return ph.Permission.calendar;
      case AppPermission.notification:
        return ph.Permission.notification;
      case AppPermission.bluetooth:
        return ph.Permission.bluetooth;
      case AppPermission.phone:
        return ph.Permission.phone;
      case AppPermission.sms:
        return ph.Permission.sms;
      case AppPermission.sensors:
        return ph.Permission.sensors;
      case AppPermission.mediaLibrary:
        return ph.Permission.mediaLibrary;
    }
  }

  /// Converts permission_handler PermissionStatus to our PermissionStatus.
  PermissionStatus _mapStatus(ph.PermissionStatus status) {
    if (status.isGranted) return PermissionStatus.granted;
    if (status.isDenied) return PermissionStatus.denied;
    if (status.isPermanentlyDenied) return PermissionStatus.permanentlyDenied;
    if (status.isRestricted) return PermissionStatus.restricted;
    if (status.isLimited) return PermissionStatus.limited;
    return PermissionStatus.unknown;
  }

  /// Checks if a permission is granted.
  Future<bool> hasPermission(AppPermission permission) async {
    try {
      // Special handling for photos - check multiple permissions
      if (permission == AppPermission.photos) {
        return await _hasPhotosPermission();
      }

      final ph.Permission p = _mapPermission(permission);
      final status = await p.status;
      return status.isGranted || status.isLimited;
    } catch (e) {
      debugPrint('Check permission error: $e');
      return false;
    }
  }

  /// Special handler to check if photos permission is granted.
  Future<bool> _hasPhotosPermission() async {
    try {
      // Check photos permission (Android 13+ / iOS)
      var status = await ph.Permission.photos.status;
      if (status.isGranted || status.isLimited) {
        return true;
      }

      // Check storage permission (Android < 13)
      status = await ph.Permission.storage.status;
      if (status.isGranted || status.isLimited) {
        return true;
      }

      // Check mediaLibrary
      status = await ph.Permission.mediaLibrary.status;
      if (status.isGranted || status.isLimited) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Check photos permission error: $e');
      return false;
    }
  }

  /// Requests a permission.
  ///
  /// Returns `true` if the permission was granted, `false` otherwise.
  Future<bool> requestPermission(AppPermission permission) async {
    try {
      // Special handling for photos - try multiple permissions for compatibility
      if (permission == AppPermission.photos) {
        return await _requestPhotosPermission();
      }

      final ph.Permission p = _mapPermission(permission);
      final status = await p.request();
      debugPrint('Requested permission: ${permission.name}, status: $status');
      return status.isGranted || status.isLimited;
    } catch (e) {
      debugPrint('Request permission error: $e');
      return false;
    }
  }

  /// Special handler for photos permission that tries multiple approaches.
  Future<bool> _requestPhotosPermission() async {
    try {
      // First try photos permission (Android 13+ / iOS)
      var status = await ph.Permission.photos.request();
      debugPrint('Photos permission status: $status');
      if (status.isGranted || status.isLimited) {
        return true;
      }

      // If photos didn't work, try storage (Android < 13)
      status = await ph.Permission.storage.request();
      debugPrint('Storage permission status: $status');
      if (status.isGranted || status.isLimited) {
        return true;
      }

      // Try mediaLibrary as another fallback
      status = await ph.Permission.mediaLibrary.request();
      debugPrint('MediaLibrary permission status: $status');
      if (status.isGranted || status.isLimited) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Request photos permission error: $e');
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

    // Convert to permission_handler permissions
    final phPermissions = permissions.map((p) => _mapPermission(p)).toList();

    try {
      // Request all permissions at once
      final statuses = await phPermissions.request();

      // Map results back
      for (int i = 0; i < permissions.length; i++) {
        final status = statuses[phPermissions[i]];
        results[permissions[i]] =
            status?.isGranted == true || status?.isLimited == true;
      }
    } catch (e) {
      debugPrint('Request permissions error: $e');
      // Fallback to individual requests
      for (final permission in permissions) {
        results[permission] = await requestPermission(permission);
      }
    }

    return results;
  }

  /// Checks if a permission is permanently denied.
  Future<bool> isPermanentlyDenied(AppPermission permission) async {
    try {
      // Special handling for photos
      if (permission == AppPermission.photos) {
        return await _isPhotosPermissionPermanentlyDenied();
      }

      final ph.Permission p = _mapPermission(permission);
      final status = await p.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      debugPrint('Check permanently denied error: $e');
      return false;
    }
  }

  /// Check if photos permission is permanently denied.
  Future<bool> _isPhotosPermissionPermanentlyDenied() async {
    try {
      // Check if all possible photo permissions are permanently denied
      final photosStatus = await ph.Permission.photos.status;
      final storageStatus = await ph.Permission.storage.status;
      final mediaStatus = await ph.Permission.mediaLibrary.status;

      // Only return true if all are permanently denied
      return photosStatus.isPermanentlyDenied &&
          storageStatus.isPermanentlyDenied &&
          mediaStatus.isPermanentlyDenied;
    } catch (e) {
      debugPrint('Check photos permanently denied error: $e');
      return false;
    }
  }

  /// Opens app settings where the user can grant permissions.
  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      debugPrint('Open app settings error: $e');
      return false;
    }
  }

  /// Gets the current status of a permission.
  Future<PermissionStatus> getPermissionStatus(AppPermission permission) async {
    try {
      final ph.Permission p = _mapPermission(permission);
      final status = await p.status;
      return _mapStatus(status);
    } catch (e) {
      debugPrint('Get permission status error: $e');
      return PermissionStatus.unknown;
    }
  }

  /// Checks if should show rationale for a permission.
  Future<bool> shouldShowRationale(AppPermission permission) async {
    try {
      final ph.Permission p = _mapPermission(permission);
      return await p.shouldShowRequestRationale;
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
