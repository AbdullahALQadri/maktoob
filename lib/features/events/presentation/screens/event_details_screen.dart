import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/edit_event/edit_event_cubit.dart';
import '../cubit/event_details/event_details_cubit.dart';
import '../cubit/event_details/event_details_state.dart';
import '../widgets/widgets.dart';
import 'edit_event_screen.dart';

/// Event details screen with overview, guests and details tabs.
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
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<EventDetailsCubit>().loadEventDetails(widget.eventId);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<EventDetailsCubit>().changeTabByIndex(_tabController.index);
    }
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
          AppSnackBar.showError(context, message: state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            backgroundColor: context.overlayBg,
            body: const EventDetailsSkeleton(),
          );
        }

        if (state.isFailure || !state.hasEvent) {
          return _ErrorView(eventId: widget.eventId, t: t);
        }

        return Scaffold(
          backgroundColor: context.overlayBg,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: EventDetailsHeader(
                  event: state.event!,
                  onBack: widget.onBack,
                  onEdit: () => _navigateToEditEvent(state.event!),
                  onDelete: () => _showDeleteConfirmation(state, t),
                ),
              ),
              SliverToBoxAdapter(child: EventQuickStats(event: state.event!)),
              SliverToBoxAdapter(child: EventTabBar(controller: _tabController)),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(event: state.event!),
                _GuestsTab(state: state, searchController: _searchController),
                _DetailsTab(event: state.event!),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToEditEvent(EventEntity event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<EditEventCubit>()..initializeWithEvent(event),
          child: const EditEventScreen(),
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        context.read<EventDetailsCubit>().refreshEventDetails();
      }
    });
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
          style: TextStyle(color: context.textTertiary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.translate('common_cancel'), style: TextStyle(color: context.textSecondary)),
          ),
          BlocBuilder<EventDetailsCubit, EventDetailsState>(
            builder: (context, deleteState) {
              return ElevatedButton(
                onPressed: deleteState.isDeleting
                    ? null
                    : () async {
                        final success = await context.read<EventDetailsCubit>().deleteEvent();
                        if (success && mounted) {
                          Navigator.pop(dialogContext);
                          widget.onBack();
                          AppSnackBar.showSuccess(context, message: t.translate('event_details_deleted'));
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red500,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: deleteState.isDeleting
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
}

// Tab Views

class _OverviewTab extends StatelessWidget {
  final EventEntity event;

  const _OverviewTab({required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          EventInfoCard(event: event),
          const SizedBox(height: 16),
          EventAnalyticsCard(event: event),
        ],
      ),
    );
  }
}

class _GuestsTab extends StatelessWidget {
  final EventDetailsState state;
  final TextEditingController searchController;

  const _GuestsTab({required this.state, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _SearchBar(
            controller: searchController,
            query: state.guestSearchQuery,
            t: t,
          ),
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
                child: GuestCard(guest: state.filteredGuests[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final EventEntity event;

  const _DetailsTab({required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          EventPackageCard(event: event),
          const SizedBox(height: 16),
          EventTemplateCard(event: event),
          const SizedBox(height: 16),
          EventSettingsCard(event: event),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            EventDescriptionCard(event: event),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Helper Widgets

class _ErrorView extends StatelessWidget {
  final String eventId;
  final AppLocalizations t;

  const _ErrorView({required this.eventId, required this.t});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.overlayBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red500),
            const SizedBox(height: 16),
            Text(
              t.translate('event_details_error'),
              style: AppTextStyles.titleMedium.copyWith(color: context.textTertiary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<EventDetailsCubit>().loadEventDetails(eventId),
              child: Text(t.translate('common_retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final AppLocalizations t;

  const _SearchBar({
    required this.controller,
    required this.query,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
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
        controller: controller,
        onChanged: (value) => context.read<EventDetailsCubit>().searchGuests(value),
        decoration: InputDecoration(
          hintText: t.translate('event_details_search_guests'),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.iconDefault),
          prefixIcon: Icon(Icons.search, color: context.iconDefault),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: context.iconDefault),
                  onPressed: () {
                    controller.clear();
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
}
