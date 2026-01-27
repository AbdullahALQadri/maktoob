import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../../data/models/event_model.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/events_list/events_list_cubit.dart';
import '../cubit/events_list/events_list_state.dart';

class EventsScreen extends StatefulWidget {
  final Function(String eventId)? onUploadPayment;
  final Function(String eventId)? onViewEvent;

  const EventsScreen({
    super.key,
    this.onUploadPayment,
    this.onViewEvent,
  });

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EventsListCubit>().loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: BlocBuilder<EventsListCubit, EventsListState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.filteredEvents != current.filteredEvents ||
              previous.filterStatus != current.filterStatus ||
              previous.searchQuery != current.searchQuery;
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(state, t),
              _buildFilterTabs(state, t),
              Expanded(
                child: _buildEventsList(state, t),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(EventsListState state, AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue600, AppColors.primaryColor],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.w),
          bottomRight: Radius.circular(30.w),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            15.w,
            16.h,
            15.w,
            15.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.translate('events_title'),
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 11.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.totalEvents} ${t.translate('events_title')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildSearchBar(state, t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(EventsListState state, AppLocalizations t) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            context.read<EventsListCubit>().searchEvents(value);
          },
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: t.translate('events_search'),
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: 15.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.gray400,
              size: 23.w,
            ),
            suffixIcon: state.searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.gray400,
                      size: 19.w,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<EventsListCubit>().searchEvents('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 19.w,
              vertical: 16.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(EventsListState state, AppLocalizations t) {
    final filters = [
      {'status': null, 'label': t.translate('events_all')},
      {'status': EventStatus.active, 'label': t.translate('events_active')},
      {'status': EventStatus.draft, 'label': t.translate('events_draft')},
      {'status': EventStatus.completed, 'label': t.translate('events_completed')},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Row(
          children: filters.map((filter) {
            final isSelected = state.filterStatus == filter['status'];
            return Padding(
              padding: EdgeInsets.only(right: 11.w),
              child: _FilterTab(
                label: filter['label'] as String,
                isSelected: isSelected,
                onTap: () {
                  context
                      .read<EventsListCubit>()
                      .filterByStatus(filter['status'] as EventStatus?);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEventsList(EventsListState state, AppLocalizations t) {
    if (state.isLoading) {
      return const EventsScreenSkeleton(itemCount: 3);
    }

    if (state.isFailure) {
      return Center(
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
              t.translate('events_error_loading'),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              state.errorMessage ?? t.translate('events_try_again'),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<EventsListCubit>().loadEvents();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 23.w,
                  vertical: 12.h,
                ),
              ),
              child: Text(t.translate('common_retry'), style: TextStyle(fontSize: 13.sp)),
            ),
          ],
        ),
      );
    }

    final events = state.filteredEvents;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 60.w,
              color: AppColors.gray400,
            ),
            SizedBox(height: 16.h),
            Text(
              t.translate('events_not_found'),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              t.translate('events_adjust_search'),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EventsListCubit>().refreshEvents(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          15.w,
          0,
          15.w,
          15.w,
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _EventCard(
                event: events[index],
                onUploadPayment: () {
                  widget.onUploadPayment?.call(events[index].id);
                },
                onViewEvent: () {
                  widget.onViewEvent?.call(events[index].id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 19.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final EventEntity event;
  final VoidCallback onUploadPayment;
  final VoidCallback onViewEvent;

  const _EventCard({
    required this.event,
    required this.onUploadPayment,
    required this.onViewEvent,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _isHovered = false;

  List<Color> get _gradient {
    if (widget.event is EventModel) {
      return (widget.event as EventModel).gradient;
    }
    return [AppColors.purple500, AppColors.pink500];
  }

  IconData get _icon {
    if (widget.event is EventModel) {
      return (widget.event as EventModel).icon;
    }
    return Icons.event;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onViewEvent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23.w),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _gradient.first.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCardHeader(context, t),
              _buildCardBody(context, t),
              _buildCardFooter(context, t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, AppLocalizations t) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(23.w),
          topRight: Radius.circular(23.w),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(11.w),
            ),
            child: Icon(
              _icon,
              color: Colors.white,
              size: 23.w,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.event.type,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(context, t),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, AppLocalizations t) {
    Color bgColor;
    Color textColor;
    String label;

    switch (widget.event.status) {
      case EventStatus.active:
        bgColor = AppColors.green100;
        textColor = AppColors.green600;
        label = t.translate('events_active');
        break;
      case EventStatus.draft:
        bgColor = AppColors.gray200;
        textColor = AppColors.gray600;
        label = t.translate('events_draft');
        break;
      case EventStatus.completed:
        bgColor = AppColors.blue50;
        textColor = AppColors.blue600;
        label = t.translate('events_completed');
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context, AppLocalizations t) {
    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(context, Icons.calendar_today, '${widget.event.date} at ${widget.event.time}'),
          SizedBox(height: 8.h),
          _buildInfoRow(context, Icons.location_on, widget.event.venue),
          SizedBox(height: 8.h),
          _buildInfoRow(context, Icons.mail_outline, '${widget.event.invitations} ${t.translate('events_invitations_sent')}'),
          SizedBox(height: 16.h),
          _buildProgressSection(context, t),
          SizedBox(height: 16.h),
          _buildStatsRow(context, t),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17.w,
          color: AppColors.gray400,
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.gray600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.translate('events_response_rate'),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            Text(
              '${widget.event.responseRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.event.responseRate / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradient,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, AppLocalizations t) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(context, t.translate('event_details_attending'), widget.event.attending, AppColors.green600),
        ),
        Container(
          width: 1,
          height: 41.h,
          color: AppColors.gray200,
        ),
        Expanded(
          child: _buildStatItem(context, t.translate('events_other'), widget.event.other, AppColors.amber500),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int value, Color dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardFooter(BuildContext context, AppLocalizations t) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(23.w),
          bottomRight: Radius.circular(23.w),
        ),
      ),
      child: widget.event.isInactive
          ? _buildUploadButton(context, t)
          : _buildViewButton(context, t),
    );
  }

  Widget _buildUploadButton(BuildContext context, AppLocalizations t) {
    return GestureDetector(
      onTap: widget.onUploadPayment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11.w),
          border: Border.all(
            color: AppColors.primaryColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              color: AppColors.primaryColor,
              size: 19.w,
            ),
            SizedBox(width: 8.w),
            Text(
              t.translate('events_upload_invoice'),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton(BuildContext context, AppLocalizations t) {
    return GestureDetector(
      onTap: widget.onViewEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.tertiaryColor],
          ),
          borderRadius: BorderRadius.circular(11.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility,
              color: Colors.white,
              size: 19.w,
            ),
            SizedBox(width: 8.w),
            Text(
              t.translate('events_view_event'),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
