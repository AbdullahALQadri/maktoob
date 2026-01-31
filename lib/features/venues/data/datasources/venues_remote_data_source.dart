import '../../../../core/error/exceptions.dart';
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
/// TODO: Replace with actual API calls
class VenuesRemoteDataSourceImpl implements VenuesRemoteDataSource {
  // TODO: Replace with actual API data
  final List<VenueModel> _mockVenues = [];

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
