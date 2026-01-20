import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/location_model.dart';

class GoogleMapsPickerWidget extends StatefulWidget {
  final LocationModel? initialLocation;
  final Function(LocationModel) onLocationSelected;

  const GoogleMapsPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
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
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedAddress = widget.initialLocation!.address;
    }
  }

  bool _isWithinGaza(LatLng position) {
    return position.latitude >= _gazaMinLat &&
        position.latitude <= _gazaMaxLat &&
        position.longitude >= _gazaMinLng &&
        position.longitude <= _gazaMaxLng;
  }

  Future<void> _onMapTapped(LatLng position) async {
    if (!_isWithinGaza(position)) {
      setState(() {
        _errorMessage = 'يرجى اختيار موقع داخل قطاع غزة فقط';
      });
      return;
    }

    setState(() {
      _selectedPosition = position;
      _errorMessage = null;
      _isLoading = true;
    });

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

        setState(() {
          _selectedAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : 'موقع محدد في غزة';
        });
      } else {
        setState(() {
          _selectedAddress = 'موقع محدد في غزة';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'موقع محدد في غزة';
      });
    } finally {
      setState(() {
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            cameraTargetBounds: CameraTargetBounds(_gazaBounds),
            minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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
