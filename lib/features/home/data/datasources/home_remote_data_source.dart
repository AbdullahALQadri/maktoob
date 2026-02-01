import 'package:flutter/material.dart';

import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/utils/app_colors.dart';
import '../models/recent_event_model.dart';
import '../models/stat_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<StatModel>> getStats();
  Future<List<RecentEventModel>> getRecentEvents();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiConsumer apiConsumer;

  HomeRemoteDataSourceImpl({required this.apiConsumer});

  /// Icon/color mapping for dashboard stat cards.
  /// The API returns raw data; UI styling is assigned here.
  static const _statStyles = [
    {
      'icon': Icons.calendar_today,
      'gradient': [AppColors.primaryColor, AppColors.primaryColor],
      'bg': AppColors.primaryColor,
    },
    {
      'icon': Icons.people,
      'gradient': [AppColors.blue500, AppColors.blue600],
      'bg': AppColors.blue500,
    },
    {
      'icon': Icons.check_circle,
      'gradient': [AppColors.green600, AppColors.emerald600],
      'bg': AppColors.green600,
    },
    {
      'icon': Icons.cancel,
      'gradient': [AppColors.red500, AppColors.rose600],
      'bg': AppColors.red500,
    },
  ];

  /// Gradient color palettes for event cards (cycled).
  static const _eventGradients = [
    [AppColors.primaryColor, AppColors.tertiaryColor],
    [AppColors.blue500, AppColors.blue600],
    [AppColors.green600, AppColors.emerald600],
    [AppColors.red500, AppColors.rose600],
  ];

  @override
  Future<List<StatModel>> getStats() async {
    final response = await apiConsumer.get(Endpoints.clientDashboardStats);
    final List<dynamic> data = response['data'] ?? response ?? [];

    final stats = <StatModel>[];
    for (var i = 0; i < data.length; i++) {
      final item = data[i] as Map<String, dynamic>;
      final style = _statStyles[i % _statStyles.length];
      stats.add(StatModel(
        label: item['title'] ?? item['title_ar'] ?? '',
        value: '${item['value'] ?? 0}',
        icon: style['icon'] as IconData,
        gradientColors: style['gradient'] as List<Color>,
        bgColor: style['bg'] as Color,
      ));
    }
    return stats;
  }

  @override
  Future<List<RecentEventModel>> getRecentEvents() async {
    final response =
        await apiConsumer.get(Endpoints.clientDashboardRecentEvents);
    final List<dynamic> data = response['data'] ?? response ?? [];

    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final json = entry.value as Map<String, dynamic>;
      return RecentEventModel(
        id: json['id'] as int,
        name: json['name'] ?? json['name_ar'] ?? '',
        date: json['date'] ?? '',
        venue: json['venue'] ?? json['venue_ar'] ?? '',
        invitations: json['guest_count'] ?? 0,
        responses: json['response_count'] ?? 0,
        attending: json['attending_count'] ?? 0,
        gradientColors: _eventGradients[i % _eventGradients.length],
      );
    }).toList();
  }
}
