import 'package:equatable/equatable.dart';


/// Template model from API
class TemplateModel extends Equatable {
  final int? id; // null for custom template
  final String name;
  final String nameAr;
  final String? previewUrl;
  final String? imageUrl; // Alias for previewUrl
  final bool isCustom;
  final bool hasExtraFee;
  final double? extraFeeAmount;

  const TemplateModel({
    this.id,
    required this.name,
    required this.nameAr,
    this.previewUrl,
    String? imageUrl,
    this.isCustom = false,
    this.hasExtraFee = false,
    this.extraFeeAmount,
  }) : imageUrl = imageUrl ?? previewUrl;

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    // Gallery designs carry `title` instead of `name`.
    final name = json['name'] as String? ?? json['title'] as String? ?? '';
    // The API may return the image URL under different field names
    final previewUrl = json['preview_url'] as String? ??
        json['image_url'] as String? ??
        json['image'] as String? ??
        json['thumbnail'] as String? ??
        json['thumbnail_url'] as String? ??
        json['photo'] as String?;
    return TemplateModel(
      id: json['id'] as int?,
      name: name,
      nameAr: json['name_ar'] as String? ?? name,
      previewUrl: previewUrl,
      isCustom: json['is_custom'] as bool? ?? false,
      hasExtraFee: json['has_extra_fee'] as bool? ?? false,
      extraFeeAmount: (json['extra_fee_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'name_ar': nameAr,
      if (previewUrl != null) 'preview_url': previewUrl,
      'is_custom': isCustom,
      'has_extra_fee': hasExtraFee,
      if (extraFeeAmount != null) 'extra_fee_amount': extraFeeAmount,
    };
  }

  /// Create custom template placeholder
  factory TemplateModel.customPlaceholder() {
    return const TemplateModel(
      id: null,
      name: 'Custom Template',
      nameAr: 'قالب مخصص',
      isCustom: true,
      hasExtraFee: true,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, nameAr, previewUrl, isCustom, hasExtraFee, extraFeeAmount];
}

/// Venue model from API
class VenueModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final String? address;
  final double? latitude;
  final double? longitude;

  const VenueModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return VenueModel(
      id: json['id'] as int? ?? 0,
      name: name,
      nameAr: json['name_ar'] as String? ?? name,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [id, name, nameAr, address, latitude, longitude];
}
