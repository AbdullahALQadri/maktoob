import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../config/locale/app_localizations.dart';
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
  bool _mapLoadError = false;

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
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('map_location_permission_title')),
        content: Text(
          t.translate('map_location_permission_msg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.translate('map_continue_without')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionService.instance.openAppSettings();
            },
            child: Text(t.translate('map_open_settings')),
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
    final t = AppLocalizations.of(context)!;
    if (!_isWithinGaza(position)) {
      if (mounted) {
        setState(() {
          _errorMessage = t.translate('map_gaza_only');
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

    String address = '${t.translate('map_selected_location')} (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

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

        address = addressParts.isNotEmpty ? addressParts.join(', ') : t.translate('map_selected_location');
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

  Widget _buildGoogleMap() {
    final t = AppLocalizations.of(context)!;
    try {
      return GoogleMap(
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
                    title: t.translate('map_selected_location'),
                    snippet: _selectedAddress,
                  ),
                ),
              }
            : {},
        cameraTargetBounds: widget.restrictToGaza
            ? CameraTargetBounds(_gazaBounds)
            : CameraTargetBounds.unbounded,
        minMaxZoomPreference: const MinMaxZoomPreference(3, 18),
        mapType: MapType.normal,
        myLocationEnabled: _hasLocationPermission,
        myLocationButtonEnabled: _hasLocationPermission,
        zoomControlsEnabled: true,
      );
    } catch (e) {
      debugPrint('Error building Google Map: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _mapLoadError = true;
          });
        }
      });
      return _buildMapErrorWidget();
    }
  }

  Widget _buildMapErrorWidget() {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: context.iconDefault,
            ),
            const SizedBox(height: 16),
            Text(
              t.translate('map_load_error'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.translate('map_check_internet'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: t.translate('contacts_retry'),
              onPressed: () {
                setState(() {
                  _mapLoadError = false;
                });
              },
              width: 200,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.translate('map_go_back')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // Show loading while checking permission
    if (_isCheckingPermission) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.translate('map_select_location')),
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
        title: Text(t.translate('map_select_location')),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Google Map with error handling
          if (_mapLoadError)
            _buildMapErrorWidget()
          else
            _buildGoogleMap(),

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
                          color: Colors.black.withValues(alpha: 0.1),
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
                            Text(
                              t.translate('map_selected_location'),
                              style: const TextStyle(
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
                              color: context.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),

                // Confirm button
                if (_selectedPosition != null && !_isLoading)
                  AppButton(
                    text: t.translate('map_confirm_location'),
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
                          color: Colors.black.withValues(alpha: 0.1),
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
                        Expanded(
                          child: Text(
                            t.translate('map_tap_instruction'),
                            style: const TextStyle(
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
