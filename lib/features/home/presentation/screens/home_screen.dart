import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/recent_event_card_widget.dart';
import '../widgets/response_rate_card_widget.dart';
import '../widgets/stat_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      duration: const Duration(milliseconds: 800),
    );
    _fadeController.forward();

    // Load home data
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
      backgroundColor: AppColors.gray100,
      body: BlocBuilder<HomeCubit, HomeState>(
        // Only rebuild when the state type changes to prevent unnecessary rebuilds
        buildWhen: (previous, current) {
          return previous.runtimeType != current.runtimeType ||
              (previous is HomeLoaded && current is HomeLoaded);
        },
        builder: (context, state) {
          if (state is HomeInitial || state is HomeLoading) {
            return _buildLoadingState();
          } else if (state is HomeError) {
            return _buildErrorState(state.message);
          } else if (state is HomeLoaded) {
            return _buildLoadedState(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const HomeScreenSkeleton();
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(HomeLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Gradient Header
          _buildHeader(),
          // Stats Grid - overlapping the header
          Transform.translate(
            offset: const Offset(0, -60),
            child: _buildStatsGrid(state),
          ),
          // Response Rate Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ResponseRateCardWidget(
              responseRate: state.responseRate,
              totalResponded: state.totalResponded,
              totalGuests: state.totalGuests,
            ),
          ),
          const SizedBox(height: 24),
          // Recent Events
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildRecentEventsSection(state),
          ),
          const SizedBox(height: 100), // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple600, AppColors.pink600],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Sparkles badge
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.yellow400,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<Offset>(
                  tween: Tween(
                    begin: const Offset(0, 20),
                    end: Offset.zero,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: offset,
                      child: child,
                    );
                  },
                  child: const Text(
                    'Koroot Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(HomeLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemCount: state.stats.length,
        itemBuilder: (context, index) {
          return StatCardWidget(
            stat: state.stats[index],
            index: index,
          );
        },
      ),
    );
  }

  Widget _buildRecentEventsSection(HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purple600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.purple600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Events list - using ListView.builder for better performance
        // (only builds visible items)
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.recentEvents.length,
          itemBuilder: (context, index) {
            return RecentEventCardWidget(
              event: state.recentEvents[index],
              index: index,
            );
          },
        ),
      ],
    );
  }
}
