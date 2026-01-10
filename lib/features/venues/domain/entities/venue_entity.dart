import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing a Venue
class VenueEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int capacity;
  final int events;
  final List<Color> gradient;
  final IconData icon;

  const VenueEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.capacity,
    required this.events,
    required this.gradient,
    required this.icon,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        phone,
        email,
        capacity,
        events,
        gradient,
        icon,
      ];

  /// Creates a copy of this entity with the given fields replaced
  VenueEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    int? capacity,
    int? events,
    List<Color>? gradient,
    IconData? icon,
  }) {
    return VenueEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      capacity: capacity ?? this.capacity,
      events: events ?? this.events,
      gradient: gradient ?? this.gradient,
      icon: icon ?? this.icon,
    );
  }
}
