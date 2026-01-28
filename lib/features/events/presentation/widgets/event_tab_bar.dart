import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Custom tab bar for event details screen.
class EventTabBar extends StatelessWidget {
  final TabController controller;

  const EventTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, AppColors.tertiaryColor],
          ),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(context.dynamicWidth(0.011)),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.gray600,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: context.dynamicWidth(0.035),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: context.dynamicWidth(0.035),
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: t.translate('event_details_overview')),
          Tab(text: t.translate('event_details_guests')),
          Tab(text: t.translate('event_details_details')),
        ],
      ),
    );
  }
}
