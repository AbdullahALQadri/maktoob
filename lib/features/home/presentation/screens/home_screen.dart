import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/responsive_extensions.dart';
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
    final responsive = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: responsive.iconSize(base: 64),
              color: AppColors.red500,
            ),
            SizedBox(height: responsive.spacing(base: 16)),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: responsive.sp(20),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: responsive.spacing(base: 8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: responsive.sp(14),
              ),
            ),
            SizedBox(height: responsive.spacing(base: 24)),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.scale(32),
                  vertical: responsive.scale(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: responsive.sp(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(HomeLoaded state) {
    final responsive = context.responsive;

    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            _buildHeader(responsive),
            // Stats Grid - overlapping the header
            Transform.translate(
              offset: Offset(0, responsive.scale(-60)),
              child: _buildStatsGrid(state, responsive),
            ),
            // Response Rate Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: ResponseRateCardWidget(
                responseRate: state.responseRate,
                totalResponded: state.totalResponded,
                totalGuests: state.totalGuests,
              ),
            ),
            SizedBox(height: responsive.spacing(base: 24)),
            // Recent Events
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
              child: _buildRecentEventsSection(state, responsive),
            ),
            SizedBox(height: responsive.spacing(base: 100)), // Bottom padding for navigation
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Responsive responsive) {
    return Container(
      height: responsive.value(
        mobile: 220.0,
        tablet: 260.0,
        desktop: 300.0,
      ),
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
            padding: EdgeInsets.all(responsive.horizontalPadding),
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
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.scale(12),
                              vertical: responsive.scale(6),
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
                                  size: responsive.iconSize(base: 16),
                                ),
                                SizedBox(width: responsive.spacing(base: 6)),
                                Text(
                                  'Welcome back!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.sp(12),
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
                SizedBox(height: responsive.spacing(base: 16)),
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
                  child: Text(
                    'Koroot Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.sp(responsive.value(
                        mobile: 28.0,
                        tablet: 36.0,
                        desktop: 42.0,
                      )),
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

  Widget _buildStatsGrid(HomeLoaded state, Responsive responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.gridColumns,
          crossAxisSpacing: responsive.spacing(base: 12),
          mainAxisSpacing: responsive.spacing(base: 12),
          childAspectRatio: responsive.value(
            mobile: 1.4,
            tablet: 1.5,
            desktop: 1.6,
          ),
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

  Widget _buildRecentEventsSection(HomeLoaded state, Responsive responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.only(bottom: responsive.spacing(base: 16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Events',
                style: TextStyle(
                  fontSize: responsive.sp(20),
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
                        fontSize: responsive.sp(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.purple600,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(base: 4)),
                    Icon(
                      Icons.arrow_forward,
                      size: responsive.iconSize(base: 16),
                      color: AppColors.purple600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Events list - responsive layout
        responsive.isTablet || responsive.isDesktop
            ? _buildEventsGrid(state, responsive)
            : _buildEventsList(state, responsive),
      ],
    );
  }

  Widget _buildEventsList(HomeLoaded state, Responsive responsive) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.recentEvents.length,
      itemBuilder: (context, index) {
        return RecentEventCardWidget(
          event: state.recentEvents[index],
          index: index,
        );
      },
    );
  }

  Widget _buildEventsGrid(HomeLoaded state, Responsive responsive) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isDesktop ? 3 : 2,
        crossAxisSpacing: responsive.spacing(base: 16),
        mainAxisSpacing: responsive.spacing(base: 16),
        childAspectRatio: 2.5,
      ),
      itemCount: state.recentEvents.length,
      itemBuilder: (context, index) {
        return RecentEventCardWidget(
          event: state.recentEvents[index],
          index: index,
        );
      },
    );
  }
}
