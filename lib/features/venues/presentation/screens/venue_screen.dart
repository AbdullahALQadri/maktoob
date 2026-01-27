import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../../domain/entities/venue_entity.dart';
import '../cubit/venues_cubit.dart';
import '../cubit/venues_state.dart';
import '../widgets/add_venue_form_widget.dart';
import '../widgets/venue_card_widget.dart';

/// Main Venue Screen Widget
class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for slide animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Load venues when screen initializes
    context.read<VenuesCubit>().loadVenues();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleAddVenue() {
    final cubit = context.read<VenuesCubit>();
    final state = cubit.state;
    if (state is VenuesLoaded) {
      if (state.showAddForm) {
        _animationController.reverse().then((_) {
          cubit.toggleAddVenueForm();
        });
      } else {
        cubit.toggleAddVenueForm();
        _animationController.forward();
      }
    }
  }

  void _handleSubmit() {
    context.read<VenuesCubit>().addVenue(
          gradient: [AppColors.primaryColor, AppColors.tertiaryColor],
          icon: Icons.business,
        );
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.gray50,
        ),
        child: SafeArea(
          child: BlocConsumer<VenuesCubit, VenuesState>(
            // Only listen for error and success states to show snackbars
            listenWhen: (previous, current) {
              return current is VenuesError || current is VenueAdded;
            },
            listener: (context, state) {
              if (state is VenuesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              if (state is VenueAdded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${state.venue.name} added successfully'),
                    backgroundColor: AppColors.primaryColor,
                  ),
                );
              }
            },
            // Only rebuild when state type changes or venues list changes
            buildWhen: (previous, current) {
              if (previous.runtimeType != current.runtimeType) return true;
              if (previous is VenuesLoaded && current is VenuesLoaded) {
                return previous.filteredVenues != current.filteredVenues ||
                    previous.showAddForm != current.showAddForm ||
                    previous.searchQuery != current.searchQuery;
              }
              return true;
            },
            builder: (context, state) {
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(child: _buildHeader(state)),
                    SliverToBoxAdapter(child: _buildSearchBar(state)),
                    SliverToBoxAdapter(child: _buildAddVenueForm(state)),
                  ];
                },
                body: _buildContent(state),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VenuesState state) {
    int venueCount = 0;
    bool showAddForm = false;

    if (state is VenuesLoaded) {
      venueCount = state.venues.length;
      showAddForm = state.showAddForm;
    } else if (state is VenueAdding) {
      venueCount = state.venues.length;
    } else if (state is VenueAdded) {
      venueCount = state.venues.length;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 16.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'Venues',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 11.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$venueCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15.w),
            child: InkWell(
              onTap: state is VenuesLoaded ? _toggleAddVenue : null,
              borderRadius: BorderRadius.circular(15.w),
              child: Container(
                padding: EdgeInsets.all(11.w),
                child: AnimatedRotation(
                  turns: showAddForm ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 23.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(VenuesState state) {
    String searchQuery = '';
    if (state is VenuesLoaded) {
      searchQuery = state.searchQuery;
    }

    return Padding(
      padding: EdgeInsets.all(15.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            context.read<VenuesCubit>().searchVenues(value);
          },
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: 'Search venues...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 21.w,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                      size: 19.w,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<VenuesCubit>().searchVenues('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 19.w,
              vertical: 16.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddVenueForm(VenuesState state) {
    bool showAddForm = false;
    if (state is VenuesLoaded) {
      showAddForm = state.showAddForm;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (!showAddForm && _animationController.isDismissed) {
          return const SizedBox.shrink();
        }
        return AddVenueFormWidget(
          slideAnimation: _slideAnimation,
          fadeAnimation: _fadeAnimation,
          onSubmit: _handleSubmit,
          onCancel: _toggleAddVenue,
        );
      },
    );
  }

  Widget _buildContent(VenuesState state) {
    // Determine if tablet/desktop based on width
    final isTabletOrDesktop = context.screenWidth >= 600;
    final isDesktop = context.screenWidth >= 1024;

    if (state is VenuesLoading) {
      return const VenuesScreenSkeleton(itemCount: 5);
    }

    if (state is VenuesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60.w,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load venues',
              style: TextStyle(
                fontSize: 17.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<VenuesCubit>().loadVenues();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: 23.w,
                  vertical: 12.h,
                ),
              ),
              child: Text('Retry', style: TextStyle(fontSize: 13.sp)),
            ),
          ],
        ),
      );
    }

    List<VenueEntity> venues = [];
    if (state is VenuesLoaded) {
      venues = state.filteredVenues;
    } else if (state is VenueAdding) {
      venues = state.filteredVenues;
    } else if (state is VenueAdded) {
      venues = state.filteredVenues;
    }

    if (venues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60.w,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16.h),
            Text(
              'No venues found',
              style: TextStyle(
                fontSize: 17.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    // Use grid layout for tablet and desktop
    if (isTabletOrDesktop) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: 15.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: isDesktop ? 2.0 : 2.2,
        ),
        itemCount: venues.length,
        itemBuilder: (context, index) {
          return VenueCardWidget(
            venue: venues[index],
            onTap: () {
              // Handle venue tap
            },
          );
        },
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        return VenueCardWidget(
          venue: venues[index],
          onTap: () {
            // Handle venue tap
          },
        );
      },
    );
  }
}
