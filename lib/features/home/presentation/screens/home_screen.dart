import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/widgets.dart';

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
      appBar: const _HomeAppBar(),
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
  const _HomeAppBar();

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
                    onTap: () {
                      // TODO: route to search
                    },
                  ),
                  const SizedBox(width: 16),
                  _AppBarIcon(
                    icon: Icons.notifications_outlined,
                    onTap: () {
                      // TODO: route to notifications
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
