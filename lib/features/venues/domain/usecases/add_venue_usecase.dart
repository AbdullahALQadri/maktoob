import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/venue_entity.dart';
import '../repositories/venues_repository.dart';

/// Use case for adding a new venue
class AddVenueUseCase extends UseCase<VenueEntity, AddVenueParams> {
  final VenuesRepository repository;

  AddVenueUseCase(this.repository);

  @override
  Future<Either<Failure, VenueEntity>> call(AddVenueParams params) async {
    final venue = VenueEntity(
      id: params.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: params.name,
      address: params.address,
      phone: params.phone,
      email: params.email,
      capacity: params.capacity,
      events: params.events,
      gradient: params.gradient,
      icon: params.icon,
    );
    return await repository.addVenue(venue);
  }
}

/// Parameters for adding a new venue
class AddVenueParams extends Equatable {
  final String? id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int capacity;
  final int events;
  final List<Color> gradient;
  final IconData icon;

  const AddVenueParams({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.capacity,
    this.events = 0,
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
}
