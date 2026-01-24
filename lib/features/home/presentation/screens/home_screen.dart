import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/recent_event_card_widget.dart';
import '../widgets/response_rate_card_widget.dart';
import '../widgets/stat_card_widget.dart';

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
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
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
              'Something went wrong',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.05),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.08),
                  vertical: context.dynamicHeight(0.015),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    context.dynamicWidth(0.03),
                  ),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: context.dynamicWidth(0.035)),
              ),
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
            offset: Offset(0, context.dynamicHeight(-0.07)),
            child: _buildStatsGrid(state),
          ),
          // Response Rate Card - adjusted to account for stats grid overlap
          Transform.translate(
            offset: Offset(0, context.dynamicHeight(-0.07)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.04),
              ),
              child: ResponseRateCardWidget(
                responseRate: state.responseRate,
                totalResponded: state.totalResponded,
                totalGuests: state.totalGuests,
              ),
            ),
          ),
          // Recent Events - adjusted to account for stats grid overlap
          Transform.translate(
            offset: Offset(0, context.dynamicHeight(-0.07)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.04),
              ),
              child: _buildRecentEventsSection(state),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.05)),
          // Bottom padding for navigation
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: context.dynamicHeight(0.28),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Padding(
            // padding: EdgeInsets.all(context.dynamicWidth(0.04)),
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.01),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: context.dynamicWidth(0.03),
                              vertical: context.dynamicHeight(0.008),
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
                                  size: context.dynamicWidth(0.04),
                                ),
                                SizedBox(width: context.dynamicWidth(0.015)),
                                Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.dynamicWidth(0.03),
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
                SizedBox(height: context.dynamicHeight(0.02)),
                TweenAnimationBuilder<Offset>(
                  tween: Tween(begin: const Offset(0, 20), end: Offset.zero),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, offset, child) {
                    return Transform.translate(offset: offset, child: child);
                  },
                  child: Text(
                    'Maktoob Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.dynamicWidth(0.07),
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
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: context.dynamicWidth(0.03),
          mainAxisSpacing: context.dynamicWidth(0.03),
          childAspectRatio: 1.1,
        ),
        itemCount: state.stats.length,
        itemBuilder: (context, index) {
          return StatCardWidget(stat: state.stats[index], index: index);
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
          padding: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Events',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.05),
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
                        fontSize: context.dynamicWidth(0.035),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(0.01)),
                    Icon(
                      Icons.arrow_forward,
                      size: context.dynamicWidth(0.04),
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Events list
        _buildEventsList(state),
      ],
    );
  }

  Widget _buildEventsList(HomeLoaded state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.recentEvents.length,
      itemBuilder: (context, index) {
        final event = state.recentEvents[index];
        return RecentEventCardWidget(
          event: event,
          index: index,
          onTap: widget.onViewEvent != null
              ? () => widget.onViewEvent!(event.id.toString())
              : null,
        );
      },
    );
  }
}
