import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_event_model.dart';
import '../models/stat_model.dart';

abstract class HomeLocalDataSource {
  Future<List<StatModel>> getCachedStats();
  Future<void> cacheStats(List<StatModel> stats);
  Future<List<RecentEventModel>> getCachedRecentEvents();
  Future<void> cacheRecentEvents(List<RecentEventModel> events);
}

const String cachedStatsKey = 'CACHED_STATS';
const String cachedRecentEventsKey = 'CACHED_RECENT_EVENTS';

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences sharedPreferences;

  HomeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<StatModel>> getCachedStats() async {
    final jsonString = sharedPreferences.getString(cachedStatsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => StatModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheStats(List<StatModel> stats) async {
    final jsonList = stats.map((stat) => stat.toJson()).toList();
    await sharedPreferences.setString(cachedStatsKey, json.encode(jsonList));
  }

  @override
  Future<List<RecentEventModel>> getCachedRecentEvents() async {
    final jsonString = sharedPreferences.getString(cachedRecentEventsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => RecentEventModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheRecentEvents(List<RecentEventModel> events) async {
    final jsonList = events.map((event) => event.toJson()).toList();
    await sharedPreferences.setString(
        cachedRecentEventsKey, json.encode(jsonList));
  }
}
