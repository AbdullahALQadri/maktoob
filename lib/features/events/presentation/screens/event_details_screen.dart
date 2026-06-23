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
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        AppSnackBar.showError(context, message: state.errorMessage!);
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
                    onEdit: () => _navigateToEditEvent(state.event!),
                    onDelete: () => _showDeleteConfirmation(state, t),
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
                        child: CircularProgressIndicator(
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
          _SendInvitationsSection(event: event),
          EventInfoCard(event: event),
          SizedBox(height: context.dynamicHeight(0.02)),
          EventAnalyticsCard(event: event),
        ],
      ),
    );
  }
}

/// "Send invitations" action shown on the Overview tab.
///
/// - Active event, not yet sent → a send button (channel chooser when the
///   package allows more than one channel).
/// - Already sent → a "sent" confirmation chip (one-time rule).
/// - Otherwise (draft/completed) → hidden.
class _SendInvitationsSection extends StatelessWidget {
  final EventEntity event;

  const _SendInvitationsSection({required this.event});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (event.invitationsSent) {
      return Padding(
        padding: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'تم إرسال الدعوات' : 'Invitations sent',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!event.canSendInvitations) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
      child: BlocBuilder<EventDetailsCubit, EventDetailsState>(
        buildWhen: (p, c) => p.isSending != c.isSending,
        builder: (context, state) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isSending ? null : () => _onSend(context, isArabic),
              icon: state.isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(isArabic ? 'إرسال الدعوات' : 'Send Invitations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSend(BuildContext context, bool isArabic) async {
    final cubit = context.read<EventDetailsCubit>();
    final channels = event.allowedChannels;
    String? method;
    if (channels.length > 1) {
      method = await _pickChannel(context, channels, isArabic);
      if (method == null) return; // cancelled
    } else if (channels.isNotEmpty) {
      method = channels.first;
    }

    final ok = await cubit.sendInvitations(deliveryMethod: method);
    if (ok && context.mounted) {
      AppSnackBar.showSuccess(
        context,
        message: isArabic ? 'تم إرسال الدعوات' : 'Invitations sent',
      );
    }
  }

  Future<String?> _pickChannel(
    BuildContext context,
    List<String> channels,
    bool isArabic,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                isArabic ? 'اختر قناة الإرسال' : 'Choose delivery channel',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            ...channels.map(
              (c) => ListTile(
                leading: Icon(_channelIcon(c)),
                title: Text(_channelLabel(c)),
                onTap: () => Navigator.of(sheetContext).pop(c),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _channelIcon(String c) {
    switch (c) {
      case 'whatsapp':
        return Icons.chat_rounded;
      case 'email':
        return Icons.email_outlined;
      case 'sms':
        return Icons.sms_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _channelLabel(String c) {
    switch (c) {
      case 'whatsapp':
        return 'WhatsApp';
      case 'email':
        return 'Email';
      case 'sms':
        return 'SMS';
      case 'app':
        return 'App';
      default:
        return c;
    }
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
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                context.dynamicHeight(0.02),
                horizontalPadding,
                context.dynamicHeight(0.02),
              ),
              child: _SearchBar(
                controller: searchController,
                query: state.guestSearchQuery,
                t: t,
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
                        child: GuestCard(guest: state.filteredGuests[index]),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
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
