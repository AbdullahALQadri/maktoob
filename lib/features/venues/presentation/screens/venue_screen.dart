import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
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
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.02),
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
                  fontSize: context.dynamicWidth(0.07),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.03)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.03),
                  vertical: context.dynamicHeight(0.008),
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
                    fontSize: context.dynamicWidth(0.035),
                  ),
                ),
              ),
            ],
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
            child: InkWell(
              onTap: state is VenuesLoaded ? _toggleAddVenue : null,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
              child: Container(
                padding: EdgeInsets.all(context.dynamicWidth(0.03)),
                child: AnimatedRotation(
                  turns: showAddForm ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: context.dynamicWidth(0.06),
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
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
          style: TextStyle(fontSize: context.dynamicWidth(0.04)),
          decoration: InputDecoration(
            hintText: 'Search venues...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: context.dynamicWidth(0.04),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: context.dynamicWidth(0.055),
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                      size: context.dynamicWidth(0.05),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<VenuesCubit>().searchVenues('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.05),
              vertical: context.dynamicHeight(0.02),
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
    final isTabletOrDesktop = context.width >= 600;
    final isDesktop = context.width >= 1024;

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
              size: context.dynamicWidth(0.16),
              color: Colors.grey[300],
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              'Failed to load venues',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            ElevatedButton(
              onPressed: () {
                context.read<VenuesCubit>().loadVenues();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.06),
                  vertical: context.dynamicHeight(0.015),
                ),
              ),
              child: Text('Retry', style: TextStyle(fontSize: context.dynamicWidth(0.035))),
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
              size: context.dynamicWidth(0.16),
              color: Colors.grey[300],
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              'No venues found',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
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
        padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: context.dynamicWidth(0.04),
          mainAxisSpacing: context.dynamicHeight(0.02),
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
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
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
