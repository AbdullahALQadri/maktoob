import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/widgets.dart';

/// Home screen displaying dashboard with stats and recent events.
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
    _initAnimation();
    _loadData();
  }

  void _initAnimation() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  void _loadData() => context.read<HomeCubit>().loadHomeData();

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
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
      return const HomeScreenSkeleton();
    }
    if (state is HomeError) {
      return HomeErrorState(
        message: state.message,
        onRetry: () => context.read<HomeCubit>().refresh(),
      );
    }
    if (state is HomeLoaded) {
      return _HomeContent(
        state: state,
        fadeAnimation: _fadeController,
        onViewEvent: widget.onViewEvent,
      );
    }
    return const SizedBox.shrink();
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
      child: Column(
        children: [
          HomeHeader(fadeAnimation: fadeAnimation),
          HomeStatsGrid(stats: state.stats),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
            ),
            child: ResponseRateCardWidget(
              responseRate: state.responseRate,
              totalResponded: state.totalResponded,
              totalGuests: state.totalGuests,
            ),
          ),
          HomeRecentEvents(
            events: state.recentEvents,
            onViewEvent: onViewEvent,
          ),
          SizedBox(height: context.dynamicHeight(0.08)),
        ],
      ),
    );
  }
}
