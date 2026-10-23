import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../injection_container.dart' as di;
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/widgets.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../events/presentation/cubit/events_list/events_list_cubit.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../widgets/event_search_delegate.dart';

/// Home screen — editorial dashboard.
///
/// Layout:
///   - Top app bar: "Maktoob" wordmark + search + notifications.
///   - Title block (large heading + soft subtitle).
///   - Hero metric card (Global RSVPs, big saffron percentage).
///   - 2×2 stat grid.
///   - Recent events (first card photo-led, rest text-led).
///   - FAB bottom-right for "create event".
class HomeScreen extends StatefulWidget {
  final Function(String)? onViewEvent;

  const HomeScreen({super.key, this.onViewEvent});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    context.read<HomeCubit>().loadHomeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: _HomeAppBar(onViewEvent: widget.onViewEvent),
      // FAB intentionally removed — the create-event "+" is owned by
      // main_shell's AdaptiveBottomNavigationBar (showAddButton: true,
      // onAddTap: _onAddEventTap) so it's available across all tabs.
      body: BlocBuilder<HomeCubit, HomeState>(
        buildWhen: _shouldRebuild,
        builder: _buildState,
      ),
    );
  }

  bool _shouldRebuild(HomeState previous, HomeState current) {
    return previous.runtimeType != current.runtimeType ||
        (previous is HomeLoaded && current is HomeLoaded);
  }

  Widget _buildState(BuildContext context, HomeState state) {
    if (state is HomeInitial || state is HomeLoading) {
      return const HomeSkeleton();
    }
    if (state is HomeError) {
      return HomeErrorState(
        message: state.message,
        onRetry: () => context.read<HomeCubit>().refresh(),
      );
    }
    if (state is HomeLoaded) {
      return RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: AppColors.white,
        onRefresh: () => context.read<HomeCubit>().loadHomeData(),
        child: _HomeContent(
          state: state,
          fadeAnimation: _fadeController,
          onViewEvent: widget.onViewEvent,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String)? onViewEvent;

  const _HomeAppBar({this.onViewEvent});

  Future<void> _openSearch(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final id = await showSearch<String?>(
      context: context,
      delegate: EventSearchDelegate(
        cubit: context.read<EventsListCubit>(),
        hint: t.translate('home_search_hint'),
      ),
    );
    if (id != null) onViewEvent?.call(id);
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Maktoob',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AppBarIcon(
                    icon: Icons.search,
                    onTap: () => _openSearch(context),
                  ),
                  const SizedBox(width: 16),
                  _NotificationBell(onViewEvent: onViewEvent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The bell with an unread badge. It re-counts on every push, so a
/// "your event is active" notification shows up without a manual refresh.
class _NotificationBell extends StatefulWidget {
  final Function(String)? onViewEvent;

  const _NotificationBell({this.onViewEvent});

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  final NotificationsCubit _cubit = di.sl<NotificationsCubit>();
  StreamSubscription<Map<String, dynamic>>? _pushSub;

  @override
  void initState() {
    super.initState();
    _cubit.load();
    _pushSub = di.sl<FcmService>().messageStream.listen((_) => _cubit.load());
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      bloc: _cubit,
      builder: (context, state) {
        final unread = state is NotificationsLoaded ? state.unreadCount : 0;
        return Badge(
          isLabelVisible: unread > 0,
          label: Text(unread > 99 ? '99+' : '$unread'),
          backgroundColor: AppColors.primaryColor,
          offset: const Offset(-2, 2),
          child: _AppBarIcon(
            icon: unread > 0
                ? Icons.notifications_active_outlined
                : Icons.notifications_outlined,
            onTap: () => NotificationsScreen.open(
              context,
              onOpenEvent: widget.onViewEvent,
              cubit: _cubit,
            ).then((_) {
              if (mounted) _cubit.load();
            }),
          ),
        );
      },
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(6),
        child: Icon(icon, size: 24, color: context.textPrimary),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeLoaded state;
  final Animation<double> fadeAnimation;
  final Function(String)? onViewEvent;

  const _HomeContent({
    required this.state,
    required this.fadeAnimation,
    this.onViewEvent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(fadeAnimation: fadeAnimation),
          const SizedBox(height: 12),
          ResponseRateCardWidget(
            responseRate: state.responseRate,
            totalResponded: state.totalResponded,
            totalGuests: state.totalGuests,
          ),
          const SizedBox(height: 28),
          HomeRecentEvents(
            events: state.recentEvents,
            onViewEvent: onViewEvent,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
