import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../../../../injection_container.dart' as di;
import '../../../events/domain/entities/event_entity.dart';
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../events/presentation/cubit/events_list/events_list_state.dart';

/// Screen that displays ongoing events for scanner selection
class ScannerEventsScreen extends StatelessWidget {
  final Function(EventEntity)? onEventSelected;

  const ScannerEventsScreen({
    super.key,
    this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<EventsListCubit>()..loadEvents(),
      child: _ScannerEventsContent(onEventSelected: onEventSelected),
    );
  }
}

class _ScannerEventsContent extends StatefulWidget {
  final Function(EventEntity)? onEventSelected;

  const _ScannerEventsContent({this.onEventSelected});

  @override
  State<_ScannerEventsContent> createState() => _ScannerEventsContentState();
}

class _ScannerEventsContentState extends State<_ScannerEventsContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // Header
          _buildHeader(context, t),
          // Content
          Expanded(
            child: BlocBuilder<EventsListCubit, EventsListState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return _buildLoadingState(context);
                }

                if (state.isFailure) {
                  return _buildErrorState(context, state.errorMessage ?? '', t);
                }

                final ongoingEvents = state.events
                    .where((e) => e.status == EventStatus.active)
                    .toList();

                if (ongoingEvents.isEmpty) {
                  return _buildEmptyState(context, t);
                }

                return _buildEventsList(context, ongoingEvents, t);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations t) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeController,
          child: Padding(
            padding: EdgeInsets.only(
              left: 15.w,
              right: 15.w,
              top: 16.h,
              bottom: 24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 11.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(19.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: 15.w,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              t.translate('scanner_guest_scanner'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                // Title
                TweenAnimationBuilder<Offset>(
                  tween: Tween(begin: const Offset(0, 20), end: Offset.zero),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, offset, child) {
                    return Transform.translate(offset: offset, child: child);
                  },
                  child: Text(
                    t.translate('scanner_select_event'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  t.translate('scanner_select_event_desc'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(15.w),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const RecentEventCardSkeleton();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message, AppLocalizations t) {
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
                color: AppColors.red500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 38.w,
                color: AppColors.red500,
              ),
            ),
            SizedBox(height: 20.h),
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

  Widget _buildEmptyState(BuildContext context, AppLocalizations t) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 94.w,
              height: 94.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 45.w,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              t.translate('scanner_no_ongoing_events'),
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              t.translate('scanner_no_ongoing_events_desc'),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.gray500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(
      BuildContext context, List<EventEntity> events, AppLocalizations t) {
    return RefreshIndicator(
      onRefresh: () => context.read<EventsListCubit>().refreshEvents(),
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: 15.w,
          right: 15.w,
          top: 15.w,
          bottom: 97.h,
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return _ScannerEventCard(
            event: event,
            index: index,
            onTap: widget.onEventSelected != null
                ? () => widget.onEventSelected!(event)
                : null,
          );
        },
      ),
    );
  }
}

class _ScannerEventCard extends StatelessWidget {
  final EventEntity event;
  final int index;
  final VoidCallback? onTap;

  const _ScannerEventCard({
    required this.event,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15.w),
            child: Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.w),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 19.w,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with icon and event name
                  Row(
                    children: [
                      // Event type icon
                      Container(
                        width: 45.w,
                        height: 45.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor,
                              AppColors.tertiaryColor,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(11.w),
                        ),
                        child: Icon(
                          _getEventIcon(event.type),
                          color: Colors.white,
                          size: 23.w,
                        ),
                      ),
                      SizedBox(width: 13.w),
                      // Event name and type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green600.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.w),
                              ),
                              child: Text(
                                event.type,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.green600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Divider
                  Container(
                    height: 1.h,
                    color: AppColors.gray200,
                  ),
                  SizedBox(height: 12.h),
                  // Event details row
                  Row(
                    children: [
                      // Date & Time
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          Icons.calendar_today,
                          '${event.date}\n${event.time}',
                        ),
                      ),
                      // Venue
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          Icons.location_on,
                          event.venue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Stats row
                  Container(
                    padding: EdgeInsets.all(11.w),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(9.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          t.translate('scanner_expected'),
                          event.attending.toString(),
                          AppColors.blue500,
                        ),
                        _buildStatDivider(context),
                        _buildStatItem(
                          context,
                          t.translate('scanner_checked_in'),
                          event.checkedIn.toString(),
                          AppColors.green600,
                        ),
                        _buildStatDivider(context),
                        _buildStatItem(
                          context,
                          t.translate('scanner_pending'),
                          (event.attending - event.checkedIn).toString(),
                          AppColors.amber500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15.w,
          color: AppColors.gray500,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.gray600,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      width: 1.w,
      height: 32.h,
      color: AppColors.gray300,
    );
  }

  IconData _getEventIcon(String type) {
    switch (type.toLowerCase()) {
      case 'wedding':
        return Icons.favorite;
      case 'birthday':
        return Icons.cake;
      case 'conference':
        return Icons.business;
      case 'meeting':
        return Icons.groups;
      case 'party':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }
}
