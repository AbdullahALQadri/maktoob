import 'package:flutter/material.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/app_colors.dart';
import '../models/venue_model.dart';

/// Abstract interface for remote data source
abstract class VenuesRemoteDataSource {
  /// Fetches all venues from the remote server
  Future<List<VenueModel>> getVenues();

  /// Adds a new venue to the remote server
  Future<VenueModel> addVenue(VenueModel venue);

  /// Searches venues by query string
  Future<List<VenueModel>> searchVenues(String query);

  /// Gets a single venue by id
  Future<VenueModel> getVenueById(String id);

  /// Updates an existing venue
  Future<VenueModel> updateVenue(VenueModel venue);

  /// Deletes a venue by id
  Future<void> deleteVenue(String id);
}

/// Implementation of VenuesRemoteDataSource
/// Currently uses mock data, replace with actual API calls
class VenuesRemoteDataSourceImpl implements VenuesRemoteDataSource {
  // Mock data for demonstration
  final List<VenueModel> _mockVenues = [
    VenueModel(
      id: '1',
      name: 'Grand Conference Hall',
      address: '123 Business District, Downtown',
      phone: '+1 (555) 123-4567',
      email: 'booking@grandconference.com',
      capacity: 500,
      events: 24,
      gradient: [AppColors.primaryColor, AppColors.tertiaryColor],
      icon: Icons.business,
    ),
    VenueModel(
      id: '2',
      name: 'Riverside Event Center',
      address: '456 River Road, Waterfront',
      phone: '+1 (555) 234-5678',
      email: 'events@riverside.com',
      capacity: 300,
      events: 18,
      gradient: [AppColors.tertiaryColor, AppColors.primaryColor],
      icon: Icons.water,
    ),
    VenueModel(
      id: '3',
      name: 'Tech Innovation Hub',
      address: '789 Silicon Avenue, Tech Park',
      phone: '+1 (555) 345-6789',
      email: 'hello@techhub.com',
      capacity: 150,
      events: 42,
      gradient: [AppColors.primaryColor, AppColors.blue500],
      icon: Icons.computer,
    ),
    VenueModel(
      id: '4',
      name: 'Garden Pavilion',
      address: '321 Botanical Gardens, Green District',
      phone: '+1 (555) 456-7890',
      email: 'reserve@gardenpavilion.com',
      capacity: 200,
      events: 15,
      gradient: [AppColors.emerald500, AppColors.primaryColor],
      icon: Icons.local_florist,
    ),
    VenueModel(
      id: '5',
      name: 'Skyline Rooftop Lounge',
      address: '555 High Tower, Uptown',
      phone: '+1 (555) 567-8901',
      email: 'info@skylinelounge.com',
      capacity: 120,
      events: 31,
      gradient: [AppColors.primaryColor, AppColors.cyan500],
      icon: Icons.nightlife,
    ),
    VenueModel(
      id: '6',
      name: 'Historic Arts Theater',
      address: '888 Culture Street, Arts District',
      phone: '+1 (555) 678-9012',
      email: 'tickets@artstheater.com',
      capacity: 450,
      events: 56,
      gradient: [AppColors.tertiaryColor, AppColors.primaryColor],
      icon: Icons.theater_comedy,
    ),
  ];

  @override
  Future<List<VenueModel>> getVenues() async {
    try {
      // Simulate network delay (reduced for better performance)
      await Future.delayed(const Duration(milliseconds: 150));
      return _mockVenues;
    } catch (e) {
      throw const ServerException(message: 'Failed to fetch venues');
    }
  }

  @override
  Future<VenueModel> addVenue(VenueModel venue) async {
    try {
      // Simulate network delay (reduced for better performance)
      await Future.delayed(const Duration(milliseconds: 150));
      _mockVenues.add(venue);
      return venue;
    } catch (e) {
      throw const ServerException(message: 'Failed to add venue');
    }
  }

  @override
  Future<List<VenueModel>> searchVenues(String query) async {
    try {
      // Simulate network delay (reduced for better performance)
      await Future.delayed(const Duration(milliseconds: 100));
      if (query.isEmpty) {
        return _mockVenues;
      }
      final lowerQuery = query.toLowerCase();
      return _mockVenues.where((venue) {
        return venue.name.toLowerCase().contains(lowerQuery) ||
            venue.address.toLowerCase().contains(lowerQuery) ||
            venue.email.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw const ServerException(message: 'Failed to search venues');
    }
  }

  @override
  Future<VenueModel> getVenueById(String id) async {
    try {
      // Simulate network delay (reduced for better performance)
      await Future.delayed(const Duration(milliseconds: 100));
      return _mockVenues.firstWhere(
        (venue) => venue.id == id,
        orElse: () => throw const NotFoundException(message: 'Venue not found'),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException(message: 'Failed to get venue');
    }
  }

  @override
  Future<VenueModel> updateVenue(VenueModel venue) async {
    try {
      // Simulate network delay (reduced for better performance)
      await Future.delayed(const Duration(milliseconds: 100));
      final index = _mockVenues.indexWhere((v) => v.id == venue.id);
      if (index == -1) {
        throw const NotFoundException(message: 'Venue not found');
      }
      _mockVenues[index] = venue;
      return venue;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException(message: 'Failed to update venue');
    }
  }

  @override
  Future<void> deleteVenue(String id) async {
    try {
      // Simulate network delay (reduced for better performance)
      await Future.delayed(const Duration(milliseconds: 100));
      _mockVenues.removeWhere((venue) => venue.id == id);
    } catch (e) {
      throw const ServerException(message: 'Failed to delete venue');
    }
  }
}
