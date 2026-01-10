import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/venue_model.dart';

/// Key for storing venues in local storage
const String cachedVenuesKey = 'CACHED_VENUES';

/// Abstract interface for local data source
abstract class VenuesLocalDataSource {
  /// Gets cached venues from local storage
  Future<List<VenueModel>> getCachedVenues();

  /// Caches venues to local storage
  Future<void> cacheVenues(List<VenueModel> venues);

  /// Adds a venue to local cache
  Future<VenueModel> addVenueToCache(VenueModel venue);

  /// Clears all cached venues
  Future<void> clearCache();
}

/// Implementation of VenuesLocalDataSource using SharedPreferences
class VenuesLocalDataSourceImpl implements VenuesLocalDataSource {
  final SharedPreferences sharedPreferences;

  VenuesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<VenueModel>> getCachedVenues() async {
    try {
      final jsonString = sharedPreferences.getString(cachedVenuesKey);
      if (jsonString == null) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => VenueModel.fromJson(json)).toList();
    } catch (e) {
      throw const CacheException('Failed to get cached venues');
    }
  }

  @override
  Future<void> cacheVenues(List<VenueModel> venues) async {
    try {
      final jsonList = venues.map((venue) => venue.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(cachedVenuesKey, jsonString);
    } catch (e) {
      throw const CacheException('Failed to cache venues');
    }
  }

  @override
  Future<VenueModel> addVenueToCache(VenueModel venue) async {
    try {
      final currentVenues = await getCachedVenues();
      currentVenues.add(venue);
      await cacheVenues(currentVenues);
      return venue;
    } catch (e) {
      throw const CacheException('Failed to add venue to cache');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedVenuesKey);
    } catch (e) {
      throw const CacheException('Failed to clear cache');
    }
  }
}
