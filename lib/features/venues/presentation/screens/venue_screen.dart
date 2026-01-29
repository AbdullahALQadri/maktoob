import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../domain/entities/venue_entity.dart';
import '../cubit/venues_cubit.dart';
import '../cubit/venues_state.dart';
import '../widgets/widgets.dart';

/// Main Venue Screen Widget
class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    context.read<VenuesCubit>().loadVenues();
  }

  void _setupAnimations() {
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
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
        _animationController.reverse().then((_) => cubit.toggleAddVenueForm());
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
        decoration: BoxDecoration(color: context.themeSurface),
        child: SafeArea(
          child: BlocConsumer<VenuesCubit, VenuesState>(
            listenWhen: (previous, current) =>
                current is VenuesError || current is VenueAdded,
            listener: _handleStateChange,
            buildWhen: _shouldRebuild,
            builder: (context, state) {
              return NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(child: _buildHeader(state)),
                  SliverToBoxAdapter(child: _buildSearchBar(state)),
                  SliverToBoxAdapter(child: _buildAddVenueForm(state)),
                ],
                body: _VenueContent(state: state),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleStateChange(BuildContext context, VenuesState state) {
    if (state is VenuesError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
  }

  bool _shouldRebuild(VenuesState previous, VenuesState current) {
    if (previous.runtimeType != current.runtimeType) return true;
    if (previous is VenuesLoaded && current is VenuesLoaded) {
      return previous.filteredVenues != current.filteredVenues ||
          previous.showAddForm != current.showAddForm ||
          previous.searchQuery != current.searchQuery;
    }
    return true;
  }

  Widget _buildHeader(VenuesState state) {
    final (venueCount, showAddForm) = _extractHeaderState(state);
    return VenueHeader(
      venueCount: venueCount,
      showAddForm: showAddForm,
      onAddPressed: state is VenuesLoaded ? _toggleAddVenue : null,
    );
  }

  (int, bool) _extractHeaderState(VenuesState state) {
    return switch (state) {
      VenuesLoaded(:final venues, :final showAddForm) => (venues.length, showAddForm),
      VenueAdding(:final venues) => (venues.length, false),
      VenueAdded(:final venues) => (venues.length, false),
      _ => (0, false),
    };
  }

  Widget _buildSearchBar(VenuesState state) {
    final searchQuery = state is VenuesLoaded ? state.searchQuery : '';
    return VenueSearchBar(
      controller: _searchController,
      searchQuery: searchQuery,
      onChanged: (value) => context.read<VenuesCubit>().searchVenues(value),
      onClear: () {
        _searchController.clear();
        context.read<VenuesCubit>().searchVenues('');
      },
    );
  }

  Widget _buildAddVenueForm(VenuesState state) {
    final showAddForm = state is VenuesLoaded && state.showAddForm;
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
}

class _VenueContent extends StatelessWidget {
  final VenuesState state;

  const _VenueContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is VenuesLoading) {
      return const VenuesScreenSkeleton(itemCount: 5);
    }

    if (state is VenuesError) {
      return VenueErrorState(
        onRetry: () => context.read<VenuesCubit>().loadVenues(),
      );
    }

    final venues = _extractVenues(state);
    if (venues.isEmpty) {
      return const VenueEmptyState();
    }

    return _VenueList(venues: venues);
  }

  List<VenueEntity> _extractVenues(VenuesState state) {
    return switch (state) {
      VenuesLoaded(:final filteredVenues) => filteredVenues,
      VenueAdding(:final filteredVenues) => filteredVenues,
      VenueAdded(:final filteredVenues) => filteredVenues,
      _ => [],
    };
  }
}

class _VenueList extends StatelessWidget {
  final List<VenueEntity> venues;

  const _VenueList({required this.venues});

  @override
  Widget build(BuildContext context) {
    final isTablet = context.width >= 600;
    final isDesktop = context.width >= 1024;

    if (isTablet) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: context.dynamicWidth(0.04),
          mainAxisSpacing: context.dynamicHeight(0.02),
          childAspectRatio: isDesktop ? 2.0 : 2.2,
        ),
        itemCount: venues.length,
        itemBuilder: (context, index) => VenueCardWidget(
          venue: venues[index],
          onTap: () {},
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.04)),
      itemCount: venues.length,
      itemBuilder: (context, index) => VenueCardWidget(
        venue: venues[index],
        onTap: () {},
      ),
    );
  }
}
