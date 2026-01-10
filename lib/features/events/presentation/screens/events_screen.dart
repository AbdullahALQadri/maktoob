import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
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
              _buildHeader(state),
              _buildFilterTabs(state),
              Expanded(
                child: _buildEventsList(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(EventsListState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue600, AppColors.purple600],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.dynamicWidth(0.08)),
          bottomRight: Radius.circular(context.dynamicWidth(0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple600.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.dynamicWidth(0.04),
            context.dynamicHeight(0.02),
            context.dynamicWidth(0.04),
            context.dynamicWidth(0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Events',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.07),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.03),
                      vertical: context.dynamicHeight(0.008),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.totalEvents} Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: context.dynamicWidth(0.035),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.dynamicHeight(0.025)),
              _buildSearchBar(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(EventsListState state) {
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
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
          style: TextStyle(fontSize: context.dynamicWidth(0.04)),
          decoration: InputDecoration(
            hintText: 'Search events...',
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: context.dynamicWidth(0.04),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.gray400,
              size: context.dynamicWidth(0.06),
            ),
            suffixIcon: state.searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.gray400,
                      size: context.dynamicWidth(0.05),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<EventsListCubit>().searchEvents('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.05),
              vertical: context.dynamicHeight(0.02),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(EventsListState state) {
    final filters = [
      {'status': null, 'label': 'All'},
      {'status': EventStatus.active, 'label': 'Active'},
      {'status': EventStatus.draft, 'label': 'Draft'},
      {'status': EventStatus.completed, 'label': 'Completed'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.02)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
        child: Row(
          children: filters.map((filter) {
            final isSelected = state.filterStatus == filter['status'];
            return Padding(
              padding: EdgeInsets.only(right: context.dynamicWidth(0.03)),
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

  Widget _buildEventsList(EventsListState state) {
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
              size: context.dynamicWidth(0.16),
              color: AppColors.red500,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              'Error loading events',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              state.errorMessage ?? 'Please try again',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            ElevatedButton(
              onPressed: () {
                context.read<EventsListCubit>().loadEvents();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.06),
                  vertical: context.dynamicHeight(0.015),
                ),
              ),
              child: Text('Retry', style: TextStyle(fontSize: context.dynamicWidth(0.035))),
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
              size: context.dynamicWidth(0.16),
              color: AppColors.gray400,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              'No events found',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
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
          context.dynamicWidth(0.04),
          0,
          context.dynamicWidth(0.04),
          context.dynamicWidth(0.04),
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
              padding: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
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
          horizontal: context.dynamicWidth(0.05),
          vertical: context.dynamicHeight(0.012),
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.purple600, AppColors.pink600],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.purple600.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
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
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.06)),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? _gradient.first.withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isHovered ? 24 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCardHeader(context),
              _buildCardBody(context),
              _buildCardFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.dynamicWidth(0.06)),
          topRight: Radius.circular(context.dynamicWidth(0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.dynamicWidth(0.12),
            height: context.dynamicWidth(0.12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
            ),
            child: Icon(
              _icon,
              color: Colors.white,
              size: context.dynamicWidth(0.06),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.045),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.dynamicHeight(0.005)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.025),
                    vertical: context.dynamicHeight(0.005),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.event.type,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.03),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(context),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (widget.event.status) {
      case EventStatus.active:
        bgColor = AppColors.green100;
        textColor = AppColors.green600;
        label = 'Active';
        break;
      case EventStatus.draft:
        bgColor = AppColors.gray200;
        textColor = AppColors.gray600;
        label = 'Draft';
        break;
      case EventStatus.completed:
        bgColor = AppColors.blue50;
        textColor = AppColors.blue600;
        label = 'Completed';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.03),
        vertical: context.dynamicHeight(0.008),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: context.dynamicWidth(0.03),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(context, Icons.calendar_today, '${widget.event.date} at ${widget.event.time}'),
          SizedBox(height: context.dynamicHeight(0.01)),
          _buildInfoRow(context, Icons.location_on, widget.event.venue),
          SizedBox(height: context.dynamicHeight(0.01)),
          _buildInfoRow(context, Icons.mail_outline, '${widget.event.invitations} invitations sent'),
          SizedBox(height: context.dynamicHeight(0.02)),
          _buildProgressSection(context),
          SizedBox(height: context.dynamicHeight(0.02)),
          _buildStatsRow(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: context.dynamicWidth(0.045),
          color: AppColors.gray400,
        ),
        SizedBox(width: context.dynamicWidth(0.025)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.035),
              color: AppColors.gray600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Response Rate',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            Text(
              '${widget.event.responseRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                fontWeight: FontWeight.bold,
                color: AppColors.purple600,
              ),
            ),
          ],
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.event.responseRate / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: context.dynamicHeight(0.01),
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

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(context, 'Attending', widget.event.attending, AppColors.green600),
        ),
        Container(
          width: 1,
          height: context.dynamicHeight(0.05),
          color: AppColors.gray200,
        ),
        Expanded(
          child: _buildStatItem(context, 'Other', widget.event.other, AppColors.amber500),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int value, Color dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: context.dynamicWidth(0.025),
          height: context.dynamicWidth(0.025),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.02)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.03),
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.dynamicWidth(0.06)),
          bottomRight: Radius.circular(context.dynamicWidth(0.06)),
        ),
      ),
      child: widget.event.isInactive
          ? _buildUploadButton(context)
          : _buildViewButton(context),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.onUploadPayment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.018)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          border: Border.all(
            color: AppColors.purple600,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple600.withOpacity(0.1),
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
              color: AppColors.purple600,
              size: context.dynamicWidth(0.05),
            ),
            SizedBox(width: context.dynamicWidth(0.02)),
            Text(
              'Upload Invoice',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                fontWeight: FontWeight.bold,
                color: AppColors.purple600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.onViewEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.018)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purple600, AppColors.pink600],
          ),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple600.withOpacity(0.3),
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
              size: context.dynamicWidth(0.05),
            ),
            SizedBox(width: context.dynamicWidth(0.02)),
            Text(
              'View Event',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
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
