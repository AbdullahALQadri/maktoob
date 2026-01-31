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
    await Future.delayed(const Duration(milliseconds: 150));

    // TODO: Replace with actual API call
    return [
      StatModel(
        label: 'Total Events',
        value: '0',
        icon: Icons.calendar_today,
        gradientColors: [AppColors.primaryColor, AppColors.primaryColor],
        bgColor: AppColors.primaryColor,
      ),
      StatModel(
        label: 'Total Guests',
        value: '0',
        icon: Icons.people,
        gradientColors: [AppColors.blue500, AppColors.blue600],
        bgColor: AppColors.blue500,
      ),
      StatModel(
        label: 'Attending',
        value: '0',
        icon: Icons.check_circle,
        gradientColors: [AppColors.green600, AppColors.emerald600],
        bgColor: AppColors.green600,
      ),
      StatModel(
        label: 'Not Attending',
        value: '0',
        icon: Icons.cancel,
        gradientColors: [AppColors.red500, AppColors.rose600],
        bgColor: AppColors.red500,
      ),
    ];
  }

  @override
  Future<List<RecentEventModel>> getRecentEvents() async {
    await Future.delayed(const Duration(milliseconds: 150));

    // TODO: Replace with actual API call
    return [];
  }
}
