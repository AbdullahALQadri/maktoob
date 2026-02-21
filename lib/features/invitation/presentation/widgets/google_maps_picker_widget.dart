import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../data/models/location_model.dart';

class GoogleMapsPickerWidget extends StatefulWidget {
  final LocationModel? initialLocation;
  final Function(LocationModel) onLocationSelected;
  final bool restrictToGaza;

  const GoogleMapsPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    this.restrictToGaza = true,
  });

  @override
  State<GoogleMapsPickerWidget> createState() => _GoogleMapsPickerWidgetState();
}

class _GoogleMapsPickerWidgetState extends State<GoogleMapsPickerWidget> {
  final MapController _mapController = MapController();
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
  static final LatLng _gazaCenter = LatLng(31.4167, 34.3333);

  // Camera bounds to restrict map view to Gaza
  static final LatLngBounds _gazaBounds = LatLngBounds(
    LatLng(_gazaMinLat, _gazaMinLng),
    LatLng(_gazaMaxLat, _gazaMaxLng),
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
    if (!widget.restrictToGaza) return true;
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

    String address =
        '${t.translate('map_selected_location')} (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';

    try {
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
        if (placemark.subLocality != null &&
            placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressParts.add(placemark.country!);
        }

        address = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : t.translate('map_selected_location');
      }
    } catch (e) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('map_select_location')),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition ?? _gazaCenter,
              initialZoom: 12,
              minZoom: 3,
              maxZoom: 18,
              cameraConstraint: widget.restrictToGaza
                  ? CameraConstraint.contain(bounds: _gazaBounds)
                  : const CameraConstraint.unconstrained(),
              onTap: (tapPosition, point) => _onMapTapped(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.maktoob.maktoob',
              ),
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
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
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
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
                  PrimaryButton(
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
}
