import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/guest_entity.dart';
import '../cubit/edit_event/edit_event_cubit.dart';
import '../cubit/event_details/event_details_cubit.dart';
import '../cubit/event_details/event_details_state.dart';
import '../widgets/widgets.dart';
import '../../../invitation/presentation/screens/invitation_wizard_screen.dart';
import 'edit_event_screen.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

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
      listenWhen: (previous, current) =>
          (current.errorMessage != null &&
              current.errorMessage != previous.errorMessage) ||
          (current.notice != null && current.notice != previous.notice),
      listener: (context, state) {
        if (state.notice != null) {
          AppSnackBar.showSuccess(
            context,
            message: t.translate(state.notice!).replaceAll('{count}', '${state.noticeCount}'),
          );
          return;
        }
        // Our own messages are translation keys; server ones are already text.
        final msg = state.errorMessage!;
        AppSnackBar.showError(
          context,
          message: msg.startsWith('event_') ? t.translate(msg) : msg,
        );
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
          body: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: EventDetailsHeader(
                    event: state.event!,
                    onBack: widget.onBack,
                    // Role gating: manager edits but never deletes; viewer
                    // and door staff get neither.
                    onEdit: state.event!.role.canManage
                        ? () => _navigateToEditEvent(state.event!)
                        : null,
                    onDelete: state.event!.role.canOwn
                        ? () => _showDeleteConfirmation(state, t)
                        : null,
                    onCancel: state.event!.canCancel
                        ? () => _confirmCancel(t)
                        : null,
                  ),
                ),
                if (state.event!.role != EventRole.owner)
                  SliverToBoxAdapter(child: _RoleBanner(role: state.event!.role, t: t)),
                // A draft resumes in the wizard where the host left off.
                if (state.event!.status == EventStatus.draft && state.event!.role.canManage)
                  SliverToBoxAdapter(
                    child: _ResumeDraftBanner(
                      t: t,
                      onResume: () {
                        final id = int.tryParse(state.event!.id);
                        if (id != null) context.openInvitationWizardWithDraft(id);
                      },
                    ),
                  ),
                // Payments belong to the owner only.
                if (state.event!.isPendingPayment && state.event!.role.canOwn)
                  SliverToBoxAdapter(
                    child: PendingPaymentBanner(
                      event: state.event!,
                      underReview: state.hasPendingPayment,
                      onPaid: () => context
                          .read<EventDetailsCubit>()
                          .loadEventDetails(widget.eventId),
                    ),
                  ),
                SliverToBoxAdapter(child: EventQuickStats(event: state.event!)),
                SliverToBoxAdapter(
                  child: EventTabBar(controller: _tabController),
                ),
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

  Future<void> _confirmCancel(AppLocalizations t) async {
    final cubit = context.read<EventDetailsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(t.translate('event_cancel_action')),
        content: Text(t.translate('event_cancel_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text(t.translate('event_cancel_keep')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            onPressed: () => Navigator.pop(d, true),
            child: Text(t.translate('event_cancel_action')),
          ),
        ],
      ),
    );
    if (confirmed == true) await cubit.cancelEvent();
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
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red500,
                size: 24,
              ),
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
            child: Text(
              t.translate('common_cancel'),
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          BlocBuilder<EventDetailsCubit, EventDetailsState>(
            builder: (context, deleteState) {
              return ElevatedButton(
                onPressed: deleteState.isDeleting
                    ? null
                    : () async {
                        final navigator = Navigator.of(dialogContext);
                        final success = await context
                            .read<EventDetailsCubit>()
                            .deleteEvent();
                        if (success && context.mounted) {
                          navigator.pop();
                          widget.onBack();
                          AppSnackBar.showSuccess(
                            context,
                            message: t.translate('event_details_deleted'),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: deleteState.isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: MkSpinner(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        t.translate('common_delete'),
                        style: const TextStyle(color: Colors.white),
                      ),
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
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.02),
      ),
      child: Column(
        children: [
          EventInfoCard(event: event),
          // Paid event: ask for an extra service, pay only its price.
          if (event.isActive && event.role.canManage) EventAddOnsCard(event: event),
          SizedBox(height: context.dynamicHeight(0.02)),
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
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final horizontalPadding = context.dynamicWidth(0.04);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontalPadding,
                context.dynamicHeight(0.02),
                horizontalPadding,
                context.dynamicHeight(0.02),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.event!.canManageGuests) ...[
                    GuestActionsBar(state: state),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _SearchBar(
                    controller: searchController,
                    query: state.guestSearchQuery,
                    t: t,
                  ),
                ],
              ),
            ),
            state.filteredGuests.isEmpty
                ? _EmptyGuestsState(
                    hasSearchQuery: state.guestSearchQuery.isNotEmpty,
                    t: t,
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: bottomPadding,
                    ),
                    itemCount: state.filteredGuests.length,
                    itemBuilder: (context, index) {
                      return StaggeredSlideFade(
                        index: index,
                        baseDelayMs: 300,
                        staggerMs: 50,
                        child: _guestCard(context, state.filteredGuests[index]),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

Widget _guestCard(BuildContext context, GuestEntity guest) {
  final cubit = context.read<EventDetailsCubit>();
  final canManage = cubit.state.event?.canManageGuests ?? false;
  return GuestCard(
    guest: guest,
    onResend: canManage ? () => cubit.resendInvitation(guest.id) : null,
    onRemove: canManage ? () => cubit.removeInvitation(guest.id) : null,
  );
}

class _DetailsTab extends StatelessWidget {
  final EventEntity event;

  const _DetailsTab({required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.02),
      ),
      child: Column(
        children: [
          EventPackageCard(event: event),
          SizedBox(height: context.dynamicHeight(0.02)),
          EventTemplateCard(event: event),
          SizedBox(height: context.dynamicHeight(0.02)),
          EventSettingsCard(event: event),
          if (event.description != null && event.description!.isNotEmpty) ...[
            SizedBox(height: context.dynamicHeight(0.02)),
            EventDescriptionCard(event: event),
          ],
          SizedBox(height: context.dynamicHeight(0.04)),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.08),
            vertical: context.dynamicHeight(0.04),
          ),
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
                t.translate('event_details_error'),
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.dynamicHeight(0.02)),
              ElevatedButton(
                onPressed: () =>
                    context.read<EventDetailsCubit>().loadEventDetails(eventId),
                child: Text(t.translate('common_retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGuestsState extends StatelessWidget {
  final bool hasSearchQuery;
  final AppLocalizations t;

  const _EmptyGuestsState({
    required this.hasSearchQuery,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.04),
          horizontal: context.dynamicWidth(0.08),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off : Icons.people_outline,
              size: context.dynamicWidth(0.16),
              color: context.iconDefault,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              hasSearchQuery
                  ? t.translate('event_details_no_search_results')
                  : t.translate('event_details_no_guests'),
              style: AppTextStyles.titleMedium.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              hasSearchQuery
                  ? t.translate('event_details_try_different_search')
                  : t.translate('event_details_guests_will_appear_here'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.textTertiary,
              ),
              textAlign: TextAlign.center,
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
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
        scrollPadding: EdgeInsets.zero,
        onChanged: (value) =>
            context.read<EventDetailsCubit>().searchGuests(value),
        decoration: InputDecoration(
          hintText: t.translate('event_details_search_guests'),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: context.iconDefault,
          ),
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.04),
            vertical: context.dynamicHeight(0.018),
          ),
        ),
      ),
    );
  }
}

class _ResumeDraftBanner extends StatelessWidget {
  final AppLocalizations t;
  final VoidCallback onResume;

  const _ResumeDraftBanner({required this.t, required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('resume_draft_banner'),
      margin: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: AppColors.primaryColor, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              t.translate('event_draft_resume_body'),
              style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: onResume,
            child: Text(t.translate('event_draft_resume')),
          ),
        ],
      ),
    );
  }
}

/// "Your role on this event: manager" banner for institution members.
class _RoleBanner extends StatelessWidget {
  final EventRole role;
  final AppLocalizations t;

  const _RoleBanner({required this.role, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('event_role_banner'),
      margin: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, color: AppColors.primaryColor, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${t.translate('event_your_role')}: ${t.translate(role.labelKey)}'
              '${role.isReadOnly ? ' · ${t.translate('event_read_only')}' : ''}',
              style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
