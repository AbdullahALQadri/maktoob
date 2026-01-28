import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Header with gradient background for all events screen.
class AllEventsHeader extends StatelessWidget {
  final String title;
  final TabController tabController;
  final List<EventTabData> tabs;

  const AllEventsHeader({
    super.key,
    required this.title,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderTitle(title: title),
            _EventTabBar(controller: tabController, tabs: tabs),
          ],
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  final String title;

  const _HeaderTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.015),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.dynamicWidth(0.056),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for event tab configuration.
class EventTabData {
  final String label;
  final int count;
  final Color badgeColor;

  const EventTabData({
    required this.label,
    required this.count,
    required this.badgeColor,
  });
}

class _EventTabBar extends StatelessWidget {
  final TabController controller;
  final List<EventTabData> tabs;

  const _EventTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.9),
        labelStyle: TextStyle(
          fontSize: context.dynamicWidth(0.032),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: context.dynamicWidth(0.032),
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs.map((tab) => _EventTab(data: tab)).toList(),
      ),
    );
  }
}

class _EventTab extends StatelessWidget {
  final EventTabData data;

  const _EventTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(data.label, overflow: TextOverflow.ellipsis),
          ),
          if (data.count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: data.badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                data.count.toString(),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.024),
                  fontWeight: FontWeight.bold,
                  color: data.badgeColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
