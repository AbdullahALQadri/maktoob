import 'package:equatable/equatable.dart';

/// Model for extra paid services related to event types
class ExtraServiceModel extends Equatable {
  final int id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final double price;
  final String? iconUrl;
  final int? eventTypeId;

  const ExtraServiceModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    required this.price,
    this.iconUrl,
    this.eventTypeId,
  });

  /// Create from JSON response
  factory ExtraServiceModel.fromJson(Map<String, dynamic> json) {
    return ExtraServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String? ?? json['name'] as String,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      price: (json['price'] as num).toDouble(),
      iconUrl: json['icon_url'] as String?,
      eventTypeId: json['event_type_id'] as int?,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      if (description != null) 'description': description,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      'price': price,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (eventTypeId != null) 'event_type_id': eventTypeId,
    };
  }

  ExtraServiceModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    String? iconUrl,
    int? eventTypeId,
  }) {
    return ExtraServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      iconUrl: iconUrl ?? this.iconUrl,
      eventTypeId: eventTypeId ?? this.eventTypeId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        description,
        descriptionAr,
        price,
        iconUrl,
        eventTypeId,
      ];
}
