import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/event_entity.dart';
import '../cubit/events_list/events_list_cubit.dart';
import '../cubit/events_list/events_list_state.dart';
import '../widgets/all_events_card_widget.dart';

/// Screen to view all events with tabs for different statuses
class ViewAllEventsScreen extends StatelessWidget {
  final Function(String)? onViewEvent;

  const ViewAllEventsScreen({
    super.key,
    this.onViewEvent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<EventsListCubit>()..loadEvents(),
      child: _ViewAllEventsContent(onViewEvent: onViewEvent),
    );
  }
}

class _ViewAllEventsContent extends StatefulWidget {
  final Function(String)? onViewEvent;

  const _ViewAllEventsContent({this.onViewEvent});

  @override
  State<_ViewAllEventsContent> createState() => _ViewAllEventsContentState();
}

class _ViewAllEventsContentState extends State<_ViewAllEventsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // Header with gradient
          _buildHeader(context, t),
          // Tab content
          Expanded(
            child: BlocBuilder<EventsListCubit, EventsListState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const _LoadingContent();
                }

                if (state.isFailure) {
                  return _buildErrorState(context, state.errorMessage ?? '', t);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventsList(
                      context,
                      state.events
                          .where((e) => e.status == EventStatus.active)
                          .toList(),
                      t,
                      EventStatus.active,
                    ),
                    _buildEventsList(
                      context,
                      state.events
                          .where((e) => e.status == EventStatus.completed)
                          .toList(),
                      t,
                      EventStatus.completed,
                    ),
                    _buildEventsList(
                      context,
                      state.events
                          .where((e) => e.status == EventStatus.draft)
                          .toList(),
                      t,
                      EventStatus.draft,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 12.h,
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
                  SizedBox(width: 15.w),
                  Text(
                    t.translate('events_all_events'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar
            _buildTabBar(context, t),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppLocalizations t) {
    return BlocBuilder<EventsListCubit, EventsListState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 15.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
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
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              _buildTab(
                context,
                t.translate('events_ongoing'),
                state.activeEvents,
                AppColors.green600,
              ),
              _buildTab(
                context,
                t.translate('events_completed'),
                state.completedEvents,
                AppColors.blue500,
              ),
              _buildTab(
                context,
                t.translate('events_draft'),
                state.draftEvents,
                AppColors.amber500,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
      BuildContext context, String label, int count, Color badgeColor) {
    return Tab(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsList(
    BuildContext context,
    List<EventEntity> events,
    AppLocalizations t,
    EventStatus status,
  ) {
    if (events.isEmpty) {
      return _buildEmptyState(context, status, t);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EventsListCubit>().refreshEvents(),
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(15.w),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return AllEventsCardWidget(
            event: event,
            index: index,
            onTap: widget.onViewEvent != null
                ? () => widget.onViewEvent!(event.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, EventStatus status, AppLocalizations t) {
    String title;
    String subtitle;
    IconData icon;
    Color color;

    switch (status) {
      case EventStatus.active:
        title = t.translate('events_no_ongoing');
        subtitle = t.translate('events_start_creating');
        icon = Icons.event_available;
        color = AppColors.green600;
        break;
      case EventStatus.completed:
        title = t.translate('events_no_completed');
        subtitle = t.translate('events_completed_appear');
        icon = Icons.check_circle_outline;
        color = AppColors.blue500;
        break;
      case EventStatus.draft:
        title = t.translate('events_no_drafts');
        subtitle = t.translate('events_drafts_appear');
        icon = Icons.edit_note;
        color = AppColors.amber500;
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75.w,
              height: 75.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38.w,
                color: color,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, AppLocalizations t) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60.w,
              color: AppColors.red500,
            ),
            SizedBox(height: 16.h),
            Text(
              t.translate('home_something_wrong'),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.read<EventsListCubit>().refreshEvents(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 30.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.w),
                ),
              ),
              child: Text(
                t.translate('home_try_again'),
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(15.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const RecentEventCardSkeleton();
      },
    );
  }
}
