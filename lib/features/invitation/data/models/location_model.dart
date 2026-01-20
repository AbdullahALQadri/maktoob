import 'package:equatable/equatable.dart';

/// Model for custom location selected from Google Maps
class LocationModel extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeName;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeName,
  });

  /// Gaza bounding box for validation
  static const double gazaMinLat = 31.2169;
  static const double gazaMaxLat = 31.5965;
  static const double gazaMinLng = 34.2192;
  static const double gazaMaxLng = 34.5584;

  /// Check if location is within Gaza bounds
  bool get isInGaza {
    return latitude >= gazaMinLat &&
        latitude <= gazaMaxLat &&
        longitude >= gazaMinLng &&
        longitude <= gazaMaxLng;
  }

  /// Create from JSON response
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      placeName: json['place_name'] as String?,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      if (placeName != null) 'place_name': placeName,
    };
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeName,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeName: placeName ?? this.placeName,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, address, placeName];
}
