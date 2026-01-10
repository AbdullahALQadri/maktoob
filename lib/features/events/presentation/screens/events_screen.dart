import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/responsive_extensions.dart';
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
        // Only rebuild when relevant state properties change
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
    final responsive = context.responsive;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue600, AppColors.purple600],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(responsive.borderRadius * 2),
          bottomRight: Radius.circular(responsive.borderRadius * 2),
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
            responsive.horizontalPadding,
            responsive.spacing(base: 16),
            responsive.horizontalPadding,
            responsive.horizontalPadding,
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
                      fontSize: responsive.sp(responsive.value(
                        mobile: 28.0,
                        tablet: 32.0,
                        desktop: 36.0,
                      )),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.scale(12),
                      vertical: responsive.scale(6),
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
                        fontSize: responsive.sp(14),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(base: 20)),
              _buildSearchBar(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(EventsListState state) {
    final responsive = context.responsive;

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
          borderRadius: BorderRadius.circular(responsive.borderRadius),
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
          style: TextStyle(fontSize: responsive.sp(16)),
          decoration: InputDecoration(
            hintText: 'Search events...',
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: responsive.sp(16),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.gray400,
              size: responsive.iconSize(base: 24),
            ),
            suffixIcon: state.searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.gray400,
                      size: responsive.iconSize(base: 20),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<EventsListCubit>().searchEvents('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.scale(20),
              vertical: responsive.scale(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(EventsListState state) {
    final responsive = context.responsive;
    final filters = [
      {'status': null, 'label': 'All'},
      {'status': EventStatus.active, 'label': 'Active'},
      {'status': EventStatus.draft, 'label': 'Draft'},
      {'status': EventStatus.completed, 'label': 'Completed'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: responsive.spacing(base: 16)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        child: Row(
          children: filters.map((filter) {
            final isSelected = state.filterStatus == filter['status'];
            return Padding(
              padding: EdgeInsets.only(right: responsive.spacing(base: 12)),
              child: _FilterTab(
                label: filter['label'] as String,
                isSelected: isSelected,
                responsive: responsive,
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
    final responsive = context.responsive;

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
              size: responsive.iconSize(base: 64),
              color: AppColors.red500,
            ),
            SizedBox(height: responsive.spacing(base: 16)),
            Text(
              'Error loading events',
              style: TextStyle(
                fontSize: responsive.sp(18),
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            SizedBox(height: responsive.spacing(base: 8)),
            Text(
              state.errorMessage ?? 'Please try again',
              style: TextStyle(
                fontSize: responsive.sp(14),
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: responsive.spacing(base: 16)),
            ElevatedButton(
              onPressed: () {
                context.read<EventsListCubit>().loadEvents();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.scale(24),
                  vertical: responsive.scale(12),
                ),
              ),
              child: Text('Retry', style: TextStyle(fontSize: responsive.sp(14))),
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
              size: responsive.iconSize(base: 64),
              color: AppColors.gray400,
            ),
            SizedBox(height: responsive.spacing(base: 16)),
            Text(
              'No events found',
              style: TextStyle(
                fontSize: responsive.sp(18),
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: responsive.spacing(base: 8)),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: responsive.sp(14),
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      );
    }

    // Use grid layout for tablet and desktop
    if (responsive.isTablet || responsive.isDesktop) {
      return RefreshIndicator(
        onRefresh: () => context.read<EventsListCubit>().refreshEvents(),
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            0,
            responsive.horizontalPadding,
            responsive.horizontalPadding,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsive.isDesktop ? 3 : 2,
            crossAxisSpacing: responsive.spacing(base: 16),
            mainAxisSpacing: responsive.spacing(base: 16),
            childAspectRatio: responsive.value(
              mobile: 0.75,
              tablet: 0.72,
              desktop: 0.7,
            ),
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50)),
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
              child: _EventCard(
                event: events[index],
                responsive: responsive,
                onUploadPayment: () {
                  widget.onUploadPayment?.call(events[index].id);
                },
                onViewEvent: () {
                  widget.onViewEvent?.call(events[index].id);
                },
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EventsListCubit>().refreshEvents(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          0,
          responsive.horizontalPadding,
          responsive.horizontalPadding,
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
              padding: EdgeInsets.only(bottom: responsive.spacing(base: 16)),
              child: _EventCard(
                event: events[index],
                responsive: responsive,
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
  final Responsive responsive;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.scale(20),
          vertical: responsive.scale(10),
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
            fontSize: responsive.sp(14),
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
  final Responsive responsive;

  const _EventCard({
    required this.event,
    required this.onUploadPayment,
    required this.onViewEvent,
    required this.responsive,
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _isHovered = false;

  Responsive get _responsive => widget.responsive;

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
            borderRadius: BorderRadius.circular(_responsive.borderRadius * 1.5),
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
              _buildCardHeader(),
              _buildCardBody(),
              _buildCardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: EdgeInsets.all(_responsive.scale(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_responsive.borderRadius * 1.5),
          topRight: Radius.circular(_responsive.borderRadius * 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _responsive.scale(48),
            height: _responsive.scale(48),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_responsive.borderRadius),
            ),
            child: Icon(
              _icon,
              color: Colors.white,
              size: _responsive.iconSize(base: 24),
            ),
          ),
          SizedBox(width: _responsive.spacing(base: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: TextStyle(
                    fontSize: _responsive.sp(18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _responsive.spacing(base: 4)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _responsive.scale(10),
                    vertical: _responsive.scale(4),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.event.type,
                    style: TextStyle(
                      fontSize: _responsive.sp(12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
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
        horizontal: _responsive.scale(12),
        vertical: _responsive.scale(6),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: _responsive.sp(12),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    return Padding(
      padding: EdgeInsets.all(_responsive.scale(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            '${widget.event.date} at ${widget.event.time}',
          ),
          SizedBox(height: _responsive.spacing(base: 8)),
          _buildInfoRow(
            Icons.location_on,
            widget.event.venue,
          ),
          SizedBox(height: _responsive.spacing(base: 8)),
          _buildInfoRow(
            Icons.mail_outline,
            '${widget.event.invitations} invitations sent',
          ),
          SizedBox(height: _responsive.spacing(base: 16)),
          _buildProgressSection(),
          SizedBox(height: _responsive.spacing(base: 16)),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: _responsive.iconSize(base: 18),
          color: AppColors.gray400,
        ),
        SizedBox(width: _responsive.spacing(base: 10)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: _responsive.sp(14),
              color: AppColors.gray600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Response Rate',
              style: TextStyle(
                fontSize: _responsive.sp(13),
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            Text(
              '${widget.event.responseRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: _responsive.sp(13),
                fontWeight: FontWeight.bold,
                color: AppColors.purple600,
              ),
            ),
          ],
        ),
        SizedBox(height: _responsive.spacing(base: 8)),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.event.responseRate / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: _responsive.scale(8),
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Attending',
            widget.event.attending,
            AppColors.green600,
          ),
        ),
        Container(
          width: 1,
          height: _responsive.scale(40),
          color: AppColors.gray200,
        ),
        Expanded(
          child: _buildStatItem(
            'Other',
            widget.event.other,
            AppColors.amber500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value, Color dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: _responsive.scale(10),
          height: _responsive.scale(10),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: _responsive.spacing(base: 8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: _responsive.sp(18),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: _responsive.sp(12),
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardFooter() {
    return Container(
      padding: EdgeInsets.all(_responsive.scale(16)),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_responsive.borderRadius * 1.5),
          bottomRight: Radius.circular(_responsive.borderRadius * 1.5),
        ),
      ),
      child: widget.event.isInactive
          ? _buildUploadButton()
          : _buildViewButton(),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: widget.onUploadPayment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: _responsive.scale(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_responsive.borderRadius),
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
              size: _responsive.iconSize(base: 20),
            ),
            SizedBox(width: _responsive.spacing(base: 8)),
            Text(
              'Upload Invoice',
              style: TextStyle(
                fontSize: _responsive.sp(14),
                fontWeight: FontWeight.bold,
                color: AppColors.purple600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewButton() {
    return GestureDetector(
      onTap: widget.onViewEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: _responsive.scale(14)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purple600, AppColors.pink600],
          ),
          borderRadius: BorderRadius.circular(_responsive.borderRadius),
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
              size: _responsive.iconSize(base: 20),
            ),
            SizedBox(width: _responsive.spacing(base: 8)),
            Text(
              'View Event',
              style: TextStyle(
                fontSize: _responsive.sp(14),
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
