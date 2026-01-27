import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../../data/models/event_model.dart';
import '../../data/models/guest_model.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/guest_entity.dart';
import '../cubit/event_details/event_details_cubit.dart';
import '../cubit/event_details/event_details_state.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final VoidCallback onBack;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.onBack,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<EventDetailsCubit>().changeTabByIndex(_tabController.index);
      }
    });
    context.read<EventDetailsCubit>().loadEventDetails(widget.eventId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return BlocConsumer<EventDetailsCubit, EventDetailsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppSnackBar.showError(
            context,
            message: state.errorMessage!,
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.gray100,
            body: const EventDetailsSkeleton(),
          );
        }

        if (state.isFailure || !state.hasEvent) {
          return Scaffold(
            backgroundColor: AppColors.gray100,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.red500),
                  const SizedBox(height: 16),
                  Text(
                    t.translate('event_details_error'),
                    style: TextStyle(fontSize: 18, color: AppColors.gray700),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<EventDetailsCubit>().loadEventDetails(widget.eventId);
                    },
                    child: Text(t.translate('common_retry')),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.gray100,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(child: _buildHeader(state, t)),
                SliverToBoxAdapter(child: _buildQuickStats(state, t)),
                SliverToBoxAdapter(child: _buildTabBar(t)),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state, t),
                _buildGuestsTab(state, t),
                _buildDetailsTab(state, t),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Color> _getGradient(EventEntity? event) {
    if (event is EventModel) {
      return event.gradient;
    }
    return [AppColors.primaryColor, AppColors.tertiaryColor];
  }

  IconData _getIcon(EventEntity? event) {
    if (event is EventModel) {
      return event.icon;
    }
    return Icons.event;
  }

  Color _getAvatarColor(GuestEntity guest) {
    if (guest is GuestModel) {
      return guest.avatarColor;
    }
    return AppColors.purple500;
  }

  Widget _buildHeader(EventDetailsState state, AppLocalizations t) {
    final event = state.event!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradient(event),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
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
                      const Spacer(),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            AppSnackBar.showInfo(
                              context,
                              message: t.translate('event_details_edit'),
                            );
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(state, t);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        offset: const Offset(0, 50),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, color: AppColors.primaryColor, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  t.translate('event_details_edit'),
                                  style: TextStyle(
                                    color: AppColors.gray900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: AppColors.red500, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  t.translate('event_details_delete'),
                                  style: TextStyle(
                                    color: AppColors.red500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                            Icons.more_vert,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _getIcon(event),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildBadge(
                                  event.type,
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white,
                                ),
                                const SizedBox(width: 8),
                                _buildBadge(
                                  _getStatusLabel(event.status, t),
                                  event.status == EventStatus.active
                                      ? AppColors.green600
                                      : AppColors.amber500,
                                  Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(EventStatus status, AppLocalizations t) {
    switch (status) {
      case EventStatus.active:
        return t.translate('events_active');
      case EventStatus.draft:
        return t.translate('events_draft');
      case EventStatus.completed:
        return t.translate('events_completed');
    }
  }

  Widget _buildBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildQuickStats(EventDetailsState state, AppLocalizations t) {
    final event = state.event!;
    return Container(
      margin: EdgeInsets.all(context.dynamicWidth(0.04)),
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.061)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              t.translate('event_details_invited'),
              event.invitations.toString(),
              AppColors.blue500,
              Icons.mail_outline,
            ),
          ),
          Container(width: 1, height: context.dynamicWidth(0.12), color: AppColors.gray200),
          Expanded(
            child: _buildStatItem(
              t.translate('event_details_attending'),
              event.attending.toString(),
              AppColors.green600,
              Icons.check_circle_outline,
            ),
          ),
          Container(width: 1, height: context.dynamicWidth(0.12), color: AppColors.gray200),
          Expanded(
            child: _buildStatItem(
              t.translate('event_details_declined'),
              event.declined.toString(),
              AppColors.red500,
              Icons.cancel_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: context.dynamicWidth(0.101),
          height: context.dynamicWidth(0.101),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: context.dynamicWidth(0.051)),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.061),
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.002)),
        Text(
          label,
          style: TextStyle(fontSize: context.dynamicWidth(0.029), color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _buildTabBar(AppLocalizations t) {
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
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.tertiaryColor],
          ),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(context.dynamicWidth(0.011)),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.gray600,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: context.dynamicWidth(0.035)),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: context.dynamicWidth(0.035)),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: t.translate('event_details_overview')),
          Tab(text: t.translate('event_details_guests')),
          Tab(text: t.translate('event_details_details')),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(EventDetailsState state, AppLocalizations t) {
    final event = state.event!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildEventInfoCard(event, t),
          const SizedBox(height: 16),
          _buildResponseAnalyticsCard(state, t),
        ],
      ),
    );
  }

  Widget _buildEventInfoCard(EventEntity event, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t.translate('event_details_info'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.calendar_today,
            t.translate('event_details_date_time'),
            event.eventDate != null
                ? _formatDateTime(event.eventDate!)
                : '${event.date} at ${event.time}',
            AppColors.blue500,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_on,
            t.translate('event_details_venue'),
            event.venueAddress != null
                ? '${event.venue}\n${event.venueAddress}'
                : event.venue,
            AppColors.emerald500,
          ),
          if (event.rsvpDeadline != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.access_time,
              t.translate('event_details_rsvp_deadline'),
              _formatDate(event.rsvpDeadline!),
              AppColors.amber500,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.gray500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponseAnalyticsCard(EventDetailsState state, AppLocalizations t) {
    final event = state.event!;
    final total = event.invitations;
    final attendingPercent = total > 0 ? (event.attending / total * 100).round() : 0;
    final pendingPercent = total > 0 ? (event.pending / total * 100).round() : 0;
    final declinedPercent = total > 0 ? (event.declined / total * 100).round() : 0;
    final checkedInPercent = event.attending > 0
        ? (event.checkedIn / event.attending * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue500, AppColors.cyan500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t.translate('event_details_analytics'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar(t.translate('event_details_attending'), event.attending, total, attendingPercent, AppColors.green600),
          const SizedBox(height: 16),
          _buildProgressBar(t.translate('event_details_pending'), event.pending, total, pendingPercent, AppColors.amber500),
          const SizedBox(height: 16),
          _buildProgressBar(t.translate('event_details_declined'), event.declined, total, declinedPercent, AppColors.red500),
          const SizedBox(height: 16),
          _buildProgressBar(t.translate('event_details_checked_in'), event.checkedIn, event.attending, checkedInPercent, AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, int percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.gray700),
            ),
            Text(
              '$value / $total ($percent%)',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: percent / 100),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGuestsTab(EventDetailsState state, AppLocalizations t) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSearchBar(state, t),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: state.filteredGuests.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _buildGuestCard(state.filteredGuests[index], t),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(EventDetailsState state, AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<EventDetailsCubit>().searchGuests(value);
        },
        decoration: InputDecoration(
          hintText: t.translate('event_details_search_guests'),
          hintStyle: TextStyle(color: AppColors.gray400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.gray400),
          suffixIcon: state.guestSearchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.gray400),
                  onPressed: () {
                    _searchController.clear();
                    context.read<EventDetailsCubit>().clearGuestSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildGuestCard(GuestEntity guest, AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getAvatarColor(guest),
                      _getAvatarColor(guest).withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getAvatarColor(guest).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    guest.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildGuestStatusBadge(guest.status, t),
                  ],
                ),
              ),
              if (guest.status == GuestStatus.attending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: guest.isCheckedIn ? AppColors.green100 : AppColors.gray100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        guest.isCheckedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 14,
                        color: guest.isCheckedIn ? AppColors.green600 : AppColors.gray400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        guest.isCheckedIn
                            ? t.translate('event_details_checked_in')
                            : t.translate('event_details_not_checked_in'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: guest.isCheckedIn ? AppColors.green600 : AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildGuestInfoRow(Icons.email_outlined, guest.email),
                const SizedBox(height: 8),
                _buildGuestInfoRow(Icons.phone_outlined, guest.phone),
                if (guest.companions > 0) ...[
                  const SizedBox(height: 8),
                  _buildGuestInfoRow(
                    Icons.people_outline,
                    '${guest.companions} ${guest.companions > 1 ? t.translate('event_details_companions') : t.translate('event_details_companion')}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestStatusBadge(GuestStatus status, AppLocalizations t) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case GuestStatus.attending:
        backgroundColor = AppColors.green100;
        textColor = AppColors.green600;
        label = t.translate('event_details_attending');
        break;
      case GuestStatus.declined:
        backgroundColor = AppColors.red100;
        textColor = AppColors.red500;
        label = t.translate('event_details_declined');
        break;
      case GuestStatus.pending:
        backgroundColor = AppColors.amber100;
        textColor = AppColors.amber600;
        label = t.translate('event_details_pending');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  Widget _buildGuestInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: AppColors.gray700),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab(EventDetailsState state, AppLocalizations t) {
    final event = state.event!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPackageDetailsCard(event, t),
          const SizedBox(height: 16),
          _buildTemplateInfoCard(event, t),
          const SizedBox(height: 16),
          _buildEventSettingsCard(event, t),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDescriptionCard(event, t),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPackageDetailsCard(EventEntity event, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.yellow400, AppColors.amber500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t.translate('event_details_package'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.yellow400.withValues(alpha: 0.2),
                  AppColors.amber500.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.amber500.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.amber600, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.packageName ?? t.translate('event_details_standard_package'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${t.translate('event_details_up_to')} ${event.invitations} ${t.translate('event_details_invitations')}',
                        style: TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
                Text(
                  event.packagePrice ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateInfoCard(EventEntity event, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.purple500, AppColors.pink500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.palette_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t.translate('event_details_template'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.amber600, AppColors.amber600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('\u2728', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.templateName ?? t.translate('event_details_standard_template'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.translate('event_details_premium_template'),
                        style: TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t.translate('common_preview'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSettingsCard(EventEntity event, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.emerald500, AppColors.cyan500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t.translate('event_details_settings'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingRow(t.translate('event_details_allow_companions'), event.allowCompanions ? t.translate('event_details_yes') : t.translate('event_details_no'), Icons.people_outline),
          const SizedBox(height: 12),
          _buildSettingRow(t.translate('event_details_max_companions'), event.maxCompanions.toString(), Icons.person_add_outlined),
          const SizedBox(height: 12),
          _buildSettingRow(t.translate('event_details_qr_checkin'), t.translate('event_details_enabled'), Icons.qr_code),
          const SizedBox(height: 12),
          _buildSettingRow(t.translate('event_details_rsvp_required'), t.translate('event_details_yes'), Icons.event_available),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gray600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.gray700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(EventEntity event, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue500, AppColors.indigo500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                t.translate('event_details_description'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            event.description ?? '',
            style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.gray700),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(EventDetailsState state, AppLocalizations t) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: AppColors.red500, size: 24),
            ),
            const SizedBox(width: 12),
            Text(t.translate('event_details_delete')),
          ],
        ),
        content: Text(
          '${t.translate('event_details_delete_confirm')} "${state.event?.name}"? ${t.translate('event_details_delete_warning')}',
          style: TextStyle(color: AppColors.gray700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.translate('common_cancel'), style: TextStyle(color: AppColors.gray600)),
          ),
          BlocBuilder<EventDetailsCubit, EventDetailsState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isDeleting
                    ? null
                    : () async {
                        final success = await context.read<EventDetailsCubit>().deleteEvent();
                        if (success && mounted) {
                          Navigator.pop(dialogContext);
                          widget.onBack();
                          AppSnackBar.showSuccess(
                            context,
                            message: t.translate('event_details_deleted'),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red500,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(t.translate('common_delete'), style: const TextStyle(color: Colors.white)),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
