import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue600, AppColors.purple600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Events',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.totalEvents} Events',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
          borderRadius: BorderRadius.circular(16),
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
          decoration: InputDecoration(
            hintText: 'Search events...',
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.gray400,
            ),
            suffixIcon: state.searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.gray400,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<EventsListCubit>().searchEvents('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: filters.map((filter) {
            final isSelected = state.filterStatus == filter['status'];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
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
              size: 64,
              color: AppColors.red500,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Please try again',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<EventsListCubit>().loadEvents();
              },
              child: const Text('Retry'),
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
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
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
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
              padding: const EdgeInsets.only(bottom: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            fontSize: 14,
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
            borderRadius: BorderRadius.circular(20),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.event.type,
                    style: const TextStyle(
                      fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            '${widget.event.date} at ${widget.event.time}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.location_on,
            widget.event.venue,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.mail_outline,
            '${widget.event.invitations} invitations sent',
          ),
          const SizedBox(height: 16),
          _buildProgressSection(),
          const SizedBox(height: 16),
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
          size: 18,
          color: AppColors.gray400,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            Text(
              '${widget.event.responseRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.purple600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: widget.event.responseRate / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 8,
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
          height: 40,
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Upload Invoice',
              style: TextStyle(
                fontSize: 14,
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.purple600, AppColors.pink600],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple600.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'View Event',
              style: TextStyle(
                fontSize: 14,
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
