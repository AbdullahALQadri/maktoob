import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/event_model.dart';

abstract class EventsLocalDataSource {
  /// Gets the cached list of events
  Future<List<EventModel>> getCachedEvents();

  /// Caches the list of events
  Future<void> cacheEvents(List<EventModel> events);

  /// Gets a single cached event by id
  Future<EventModel?> getCachedEvent(String eventId);

  /// Clears all cached events
  Future<void> clearCache();
}

const String cachedEventsKey = 'CACHED_EVENTS';

class EventsLocalDataSourceImpl implements EventsLocalDataSource {
  final SharedPreferences sharedPreferences;

  EventsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<EventModel>> getCachedEvents() async {
    final jsonString = sharedPreferences.getString(cachedEventsKey);

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((jsonMap) => EventModel.fromJson(jsonMap as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw const CacheException(message: 'Failed to parse cached events');
      }
    } else {
      throw const CacheException(message: 'No cached events found');
    }
  }

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    try {
      final jsonList = events.map((event) => event.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(cachedEventsKey, jsonString);
    } catch (e) {
      throw const CacheException(message: 'Failed to cache events');
    }
  }

  @override
  Future<EventModel?> getCachedEvent(String eventId) async {
    try {
      final events = await getCachedEvents();
      return events.firstWhere(
        (event) => event.id == eventId,
        orElse: () => throw const CacheException(message: 'Event not found in cache'),
      );
    } catch (e) {
      if (e is CacheException) rethrow;
      throw const CacheException(message: 'Failed to get cached event');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(cachedEventsKey);
    } catch (e) {
      throw const CacheException(message: 'Failed to clear cache');
    }
  }
}
