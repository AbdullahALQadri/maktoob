import 'package:flutter/material.dart';
import '../../domain/entities/venue_entity.dart';

/// Data model for Venue that extends the domain entity
/// Handles JSON serialization/deserialization
class VenueModel extends VenueEntity {
  const VenueModel({
    required super.id,
    required super.name,
    required super.address,
    required super.phone,
    required super.email,
    required super.capacity,
    required super.events,
    required super.gradient,
    required super.icon,
  });

  /// Creates a VenueModel from JSON map
  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      capacity: json['capacity'] as int,
      events: json['events'] as int? ?? 0,
      gradient: _parseGradient(json['gradient']),
      icon: _parseIcon(json['icon']),
    );
  }

  /// Creates a VenueModel from a VenueEntity
  factory VenueModel.fromEntity(VenueEntity entity) {
    return VenueModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      capacity: entity.capacity,
      events: entity.events,
      gradient: entity.gradient,
      icon: entity.icon,
    );
  }

  /// Converts the model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'capacity': capacity,
      'events': events,
      'gradient': gradient.map((c) => c.value).toList(),
      'icon': icon.codePoint,
    };
  }

  /// Helper method to parse gradient colors from JSON
  static List<Color> _parseGradient(dynamic gradientData) {
    if (gradientData == null) {
      return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
    if (gradientData is List) {
      return gradientData.map((colorValue) {
        if (colorValue is int) {
          return Color(colorValue);
        }
        return const Color(0xFF667eea);
      }).toList();
    }
    return [const Color(0xFF667eea), const Color(0xFF764ba2)];
  }

  /// Helper method to parse icon from JSON
  static IconData _parseIcon(dynamic iconData) {
    if (iconData == null) {
      return Icons.business;
    }
    if (iconData is int) {
      return IconData(iconData, fontFamily: 'MaterialIcons');
    }
    return Icons.business;
  }

  /// Converts to VenueEntity
  VenueEntity toEntity() {
    return VenueEntity(
      id: id,
      name: name,
      address: address,
      phone: phone,
      email: email,
      capacity: capacity,
      events: events,
      gradient: gradient,
      icon: icon,
    );
  }
}
