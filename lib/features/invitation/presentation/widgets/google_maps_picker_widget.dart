import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/services/permissions/permission_service.dart';
import '../../data/models/location_model.dart';

class GoogleMapsPickerWidget extends StatefulWidget {
  final LocationModel? initialLocation;
  final Function(LocationModel) onLocationSelected;
  final bool restrictToGaza;

  const GoogleMapsPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    this.restrictToGaza = false, // Set to false for testing - can mark anywhere
  });

  @override
  State<GoogleMapsPickerWidget> createState() => _GoogleMapsPickerWidgetState();
}

class _GoogleMapsPickerWidgetState extends State<GoogleMapsPickerWidget> {
  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  String? _selectedAddress;
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasLocationPermission = false;
  bool _isCheckingPermission = true;

  // Gaza bounds
  static const double _gazaMinLat = 31.2169;
  static const double _gazaMaxLat = 31.5965;
  static const double _gazaMinLng = 34.2192;
  static const double _gazaMaxLng = 34.5584;

  // Gaza center for initial camera position
  static const LatLng _gazaCenter = LatLng(31.4167, 34.3333);

  // Camera bounds to restrict map view to Gaza
  static final LatLngBounds _gazaBounds = LatLngBounds(
    southwest: const LatLng(_gazaMinLat, _gazaMinLng),
    northeast: const LatLng(_gazaMaxLat, _gazaMaxLng),
  );

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedAddress = widget.initialLocation!.address;
    }
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isCheckingPermission = true;
    });

    try {
      final hasPermission = await PermissionService.instance.hasPermission(
        AppPermission.locationWhenInUse,
      );

      if (hasPermission) {
        setState(() {
          _hasLocationPermission = true;
          _isCheckingPermission = false;
        });
      } else {
        // Request permission
        final granted = await PermissionService.instance.requestPermission(
          AppPermission.locationWhenInUse,
        );

        if (granted) {
          setState(() {
            _hasLocationPermission = true;
            _isCheckingPermission = false;
          });
        } else {
          // Check if permanently denied
          final isPermanentlyDenied = await PermissionService.instance
              .isPermanentlyDenied(AppPermission.locationWhenInUse);

          setState(() {
            _hasLocationPermission = false;
            _isCheckingPermission = false;
          });

          if (isPermanentlyDenied && mounted) {
            _showPermissionDeniedDialog();
          }
        }
      }
    } catch (e) {
      setState(() {
        _hasLocationPermission = false;
        _isCheckingPermission = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إذن الموقع مطلوب'),
        content: const Text(
          'يحتاج التطبيق إلى إذن الموقع لعرض موقعك الحالي على الخريطة. '
          'يمكنك متابعة اختيار الموقع يدويًا أو منح الإذن من الإعدادات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('متابعة بدون إذن'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionService.instance.openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  bool _isWithinGaza(LatLng position) {
    if (!widget.restrictToGaza) return true; // Allow anywhere for testing
    return position.latitude >= _gazaMinLat &&
        position.latitude <= _gazaMaxLat &&
        position.longitude >= _gazaMinLng &&
        position.longitude <= _gazaMaxLng;
  }

  Future<void> _onMapTapped(LatLng position) async {
    if (!_isWithinGaza(position)) {
      if (mounted) {
        setState(() {
          _errorMessage = 'يرجى اختيار موقع داخل قطاع غزة فقط';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _selectedPosition = position;
        _errorMessage = null;
        _isLoading = true;
      });
    }

    String address = 'موقع محدد (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

    try {
      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final addressParts = <String>[];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressParts.add(placemark.country!);
        }

        address = addressParts.isNotEmpty ? addressParts.join(', ') : 'موقع محدد';
      }
    } catch (e) {
      // Keep the coordinate-based address set above
      debugPrint('Geocoding error: $e');
    }

    if (mounted) {
      setState(() {
        _selectedAddress = address;
        _isLoading = false;
      });
    }
  }

  void _confirmSelection() {
    if (_selectedPosition != null && _selectedAddress != null) {
      final location = LocationModel(
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        address: _selectedAddress!,
      );
      widget.onLocationSelected(location);
      // Navigation is handled by the callback - don't call Navigator.pop here
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking permission
    if (_isCheckingPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('اختر الموقع'),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر الموقع'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition ?? _gazaCenter,
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
            markers: _selectedPosition != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedPosition!,
                      infoWindow: InfoWindow(
                        title: 'الموقع المحدد',
                        snippet: _selectedAddress,
                      ),
                    ),
                  }
                : {},
            cameraTargetBounds: widget.restrictToGaza ? CameraTargetBounds(_gazaBounds) : CameraTargetBounds.unbounded,
            minMaxZoomPreference: const MinMaxZoomPreference(3, 18),
            mapType: MapType.normal,
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: _hasLocationPermission,
            zoomControlsEnabled: true,
          ),

          // Address display and confirm button
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Selected address card
                if (_selectedPosition != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'الموقع المحدد',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_isLoading)
                          const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          Text(
                            _selectedAddress ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                  ),

                // Confirm button
                if (_selectedPosition != null && !_isLoading)
                  AppButton(
                    text: 'تأكيد الموقع',
                    onPressed: _confirmSelection,
                    width: double.infinity,
                  ),

                // Instructions
                if (_selectedPosition == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'انقر على الخريطة لتحديد موقع الحدث',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
