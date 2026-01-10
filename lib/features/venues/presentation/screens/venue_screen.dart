import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/responsive_extensions.dart';
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
          gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
          icon: Icons.business,
        );
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
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
                    backgroundColor: const Color(0xFF10B981),
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
              return Column(
                children: [
                  _buildHeader(state),
                  _buildSearchBar(state),
                  _buildAddVenueForm(state),
                  Expanded(
                    child: _buildContent(state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VenuesState state) {
    final responsive = context.responsive;
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
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF14B8A6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x4010B981),
            blurRadius: 20,
            offset: Offset(0, 10),
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
                  fontSize: responsive.sp(responsive.value(
                    mobile: 28.0,
                    tablet: 32.0,
                    desktop: 36.0,
                  )),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: responsive.spacing(base: 12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.scale(12),
                  vertical: responsive.scale(6),
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
                    fontSize: responsive.sp(14),
                  ),
                ),
              ),
            ],
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(responsive.borderRadius),
            child: InkWell(
              onTap: state is VenuesLoaded ? _toggleAddVenue : null,
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              child: Container(
                padding: EdgeInsets.all(responsive.scale(12)),
                child: AnimatedRotation(
                  turns: showAddForm ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: responsive.iconSize(base: 24),
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
    final responsive = context.responsive;
    String searchQuery = '';
    if (state is VenuesLoaded) {
      searchQuery = state.searchQuery;
    }

    return Padding(
      padding: EdgeInsets.all(responsive.horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsive.borderRadius),
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
          style: TextStyle(fontSize: responsive.sp(16)),
          decoration: InputDecoration(
            hintText: 'Search venues...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: responsive.sp(16),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: responsive.iconSize(base: 22),
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                      size: responsive.iconSize(base: 20),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<VenuesCubit>().searchVenues('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.scale(20),
              vertical: responsive.scale(16),
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
    final responsive = context.responsive;

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
              size: responsive.iconSize(base: 64),
              color: Colors.grey[300],
            ),
            SizedBox(height: responsive.spacing(base: 16)),
            Text(
              'Failed to load venues',
              style: TextStyle(
                fontSize: responsive.sp(18),
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: responsive.spacing(base: 16)),
            ElevatedButton(
              onPressed: () {
                context.read<VenuesCubit>().loadVenues();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.scale(24),
                  vertical: responsive.scale(12),
                ),
              ),
              child: Text('Retry', style: TextStyle(fontSize: responsive.sp(14))),
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
              size: responsive.iconSize(base: 64),
              color: Colors.grey[300],
            ),
            SizedBox(height: responsive.spacing(base: 16)),
            Text(
              'No venues found',
              style: TextStyle(
                fontSize: responsive.sp(18),
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: responsive.spacing(base: 8)),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: responsive.sp(14),
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    // Use grid layout for tablet and desktop
    if (responsive.isTablet || responsive.isDesktop) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.isDesktop ? 3 : 2,
          crossAxisSpacing: responsive.spacing(base: 16),
          mainAxisSpacing: responsive.spacing(base: 16),
          childAspectRatio: responsive.value(
            mobile: 2.5,
            tablet: 2.2,
            desktop: 2.0,
          ),
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
      padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
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
