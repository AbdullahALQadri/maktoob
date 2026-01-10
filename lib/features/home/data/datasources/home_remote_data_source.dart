import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../models/recent_event_model.dart';
import '../models/stat_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<StatModel>> getStats();
  Future<List<RecentEventModel>> getRecentEvents();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl();

  @override
  Future<List<StatModel>> getStats() async {
    // Simulate API call delay (reduced for better performance)
    await Future.delayed(const Duration(milliseconds: 150));

    // TODO: Replace with actual API call
    return [
      StatModel(
        label: 'Total Events',
        value: '24',
        icon: Icons.calendar_today,
        gradientColors: [AppColors.purple500, AppColors.purple600],
        bgColor: AppColors.purple500,
      ),
      StatModel(
        label: 'Total Guests',
        value: '1,234',
        icon: Icons.people,
        gradientColors: [AppColors.blue500, AppColors.blue600],
        bgColor: AppColors.blue500,
      ),
      StatModel(
        label: 'Attending',
        value: '892',
        icon: Icons.check_circle,
        gradientColors: [AppColors.green600, AppColors.emerald600],
        bgColor: AppColors.green600,
      ),
      StatModel(
        label: 'Not Attending',
        value: '156',
        icon: Icons.cancel,
        gradientColors: [AppColors.red500, AppColors.rose600],
        bgColor: AppColors.red500,
      ),
    ];
  }

  @override
  Future<List<RecentEventModel>> getRecentEvents() async {
    // Simulate API call delay (reduced for better performance)
    await Future.delayed(const Duration(milliseconds: 150));

    // TODO: Replace with actual API call
    return [
      RecentEventModel(
        id: 1,
        name: 'Wedding Ceremony',
        date: '2026-01-15',
        venue: 'Grand Hotel Ballroom',
        invitations: 150,
        responses: 120,
        attending: 95,
        gradientColors: [AppColors.pink500, AppColors.rose500],
      ),
      RecentEventModel(
        id: 2,
        name: 'Corporate Gala',
        date: '2026-01-20',
        venue: 'Convention Center',
        invitations: 300,
        responses: 180,
        attending: 165,
        gradientColors: [AppColors.blue500, AppColors.cyan500],
      ),
      RecentEventModel(
        id: 3,
        name: 'Birthday Party',
        date: '2026-01-25',
        venue: 'Beach Resort',
        invitations: 80,
        responses: 65,
        attending: 58,
        gradientColors: [AppColors.amber500, AppColors.orange500],
      ),
    ];
  }
}
