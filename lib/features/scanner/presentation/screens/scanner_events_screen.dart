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
              left: context.dynamicWidth(0.04),
              right: context.dynamicWidth(0.04),
              top: context.dynamicHeight(0.02),
              bottom: context.dynamicHeight(0.03),
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
                          horizontal: context.dynamicWidth(0.029),
                          vertical: context.dynamicHeight(0.007),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: context.dynamicWidth(0.04),
                            ),
                            SizedBox(width: context.dynamicWidth(0.016)),
                            Text(
                              t.translate('scanner_guest_scanner'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.dynamicWidth(0.029),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
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
                      fontSize: context.dynamicWidth(0.064),
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.007)),
                Text(
                  t.translate('scanner_select_event_desc'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: context.dynamicWidth(0.035),
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
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const RecentEventCardSkeleton();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message, AppLocalizations t) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.08)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.dynamicWidth(0.2),
              height: context.dynamicWidth(0.2),
              decoration: BoxDecoration(
                color: AppColors.red500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: context.dynamicWidth(0.101),
                color: AppColors.red500,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),
            Text(
              t.translate('home_something_wrong'),
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            ElevatedButton(
              onPressed: () => context.read<EventsListCubit>().refreshEvents(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.08),
                  vertical: context.dynamicHeight(0.015),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
                ),
              ),
              child: Text(
                t.translate('home_try_again'),
                style: TextStyle(fontSize: context.dynamicWidth(0.035)),
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
        padding: EdgeInsets.all(context.dynamicWidth(0.08)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.dynamicWidth(0.251),
              height: context.dynamicWidth(0.251),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: context.dynamicWidth(0.12),
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            Text(
              t.translate('scanner_no_ongoing_events'),
              style: TextStyle(
                fontSize: context.dynamicWidth(0.051),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.dynamicHeight(0.015)),
            Text(
              t.translate('scanner_no_ongoing_events_desc'),
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
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
          left: context.dynamicWidth(0.04),
          right: context.dynamicWidth(0.04),
          top: context.dynamicWidth(0.04),
          bottom: context.dynamicHeight(0.119),
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
        margin: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
            child: Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.04)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    blurRadius: context.dynamicWidth(0.051),
                    offset: Offset(0, context.dynamicHeight(0.01)),
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
                        width: context.dynamicWidth(0.12),
                        height: context.dynamicWidth(0.12),
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
                              BorderRadius.circular(context.dynamicWidth(0.029)),
                        ),
                        child: Icon(
                          _getEventIcon(event.type),
                          color: Colors.white,
                          size: context.dynamicWidth(0.061),
                        ),
                      ),
                      SizedBox(width: context.dynamicWidth(0.035)),
                      // Event name and type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: TextStyle(
                                fontSize: context.dynamicWidth(0.043),
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: context.dynamicHeight(0.005)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.dynamicWidth(0.021),
                                vertical: context.dynamicHeight(0.002),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green600.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(context.dynamicWidth(0.016)),
                              ),
                              child: Text(
                                event.type,
                                style: TextStyle(
                                  fontSize: context.dynamicWidth(0.029),
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
                  SizedBox(height: context.dynamicHeight(0.02)),
                  // Divider
                  Container(
                    height: context.dynamicHeight(0.001),
                    color: AppColors.gray200,
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
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
                  SizedBox(height: context.dynamicHeight(0.015)),
                  // Stats row
                  Container(
                    padding: EdgeInsets.all(context.dynamicWidth(0.029)),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
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
          size: context.dynamicWidth(0.04),
          color: AppColors.gray500,
        ),
        SizedBox(width: context.dynamicWidth(0.021)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
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
            fontSize: context.dynamicWidth(0.045),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.002)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.024),
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.003),
      height: context.dynamicHeight(0.039),
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
