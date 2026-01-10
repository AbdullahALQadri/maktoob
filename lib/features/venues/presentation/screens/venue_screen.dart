import 'package:flutter/material.dart';

/// Model class representing a Venue
class Venue {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int capacity;
  final int events;
  final List<Color> gradient;
  final IconData icon;

  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.capacity,
    required this.events,
    required this.gradient,
    required this.icon,
  });
}

/// Main Venue Screen Widget
class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  String _searchQuery = '';
  bool _showAddVenue = false;

  // New venue form state
  String _newVenueName = '';
  String _newVenueAddress = '';
  String _newVenuePhone = '';
  String _newVenueEmail = '';
  String _newVenueCapacity = '';

  // Animation controller for slide animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Mock venues data
  final List<Venue> _venues = [
    Venue(
      id: '1',
      name: 'Grand Conference Hall',
      address: '123 Business District, Downtown',
      phone: '+1 (555) 123-4567',
      email: 'booking@grandconference.com',
      capacity: 500,
      events: 24,
      gradient: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      icon: Icons.business,
    ),
    Venue(
      id: '2',
      name: 'Riverside Event Center',
      address: '456 River Road, Waterfront',
      phone: '+1 (555) 234-5678',
      email: 'events@riverside.com',
      capacity: 300,
      events: 18,
      gradient: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      icon: Icons.water,
    ),
    Venue(
      id: '3',
      name: 'Tech Innovation Hub',
      address: '789 Silicon Avenue, Tech Park',
      phone: '+1 (555) 345-6789',
      email: 'hello@techhub.com',
      capacity: 150,
      events: 42,
      gradient: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      icon: Icons.computer,
    ),
    Venue(
      id: '4',
      name: 'Garden Pavilion',
      address: '321 Botanical Gardens, Green District',
      phone: '+1 (555) 456-7890',
      email: 'reserve@gardenpavilion.com',
      capacity: 200,
      events: 15,
      gradient: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      icon: Icons.local_florist,
    ),
    Venue(
      id: '5',
      name: 'Skyline Rooftop Lounge',
      address: '555 High Tower, Uptown',
      phone: '+1 (555) 567-8901',
      email: 'info@skylinelounge.com',
      capacity: 120,
      events: 31,
      gradient: [const Color(0xFFfa709a), const Color(0xFFfee140)],
      icon: Icons.nightlife,
    ),
    Venue(
      id: '6',
      name: 'Historic Arts Theater',
      address: '888 Culture Street, Arts District',
      phone: '+1 (555) 678-9012',
      email: 'tickets@artstheater.com',
      capacity: 450,
      events: 56,
      gradient: [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
      icon: Icons.theater_comedy,
    ),
  ];

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _capacityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Get filtered venues based on search query
  List<Venue> get _filteredVenues {
    if (_searchQuery.isEmpty) {
      return _venues;
    }
    final query = _searchQuery.toLowerCase();
    return _venues.where((venue) {
      return venue.name.toLowerCase().contains(query) ||
          venue.address.toLowerCase().contains(query) ||
          venue.email.toLowerCase().contains(query);
    }).toList();
  }

  /// Toggle the add venue form visibility
  void _toggleAddVenue() {
    setState(() {
      _showAddVenue = !_showAddVenue;
      if (_showAddVenue) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// Handle form submission
  void _handleSubmit() {
    // Here you would typically add the new venue to the list
    // For now, just close the form and reset fields
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _capacityController.clear();
    setState(() {
      _newVenueName = '';
      _newVenueAddress = '';
      _newVenuePhone = '';
      _newVenueEmail = '';
      _newVenueCapacity = '';
    });
    _toggleAddVenue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Gradient Header
              _buildHeader(),
              // Search Bar
              _buildSearchBar(),
              // Animated Add Venue Form
              _buildAddVenueForm(),
              // Venue Cards List
              Expanded(
                child: _buildVenueList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the gradient header with title, badge, and add button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981), // Green
            Color(0xFF14B8A6), // Teal
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
              const Text(
                'Venues',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              // Venue count badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_venues.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          // Add button
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _toggleAddVenue,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: AnimatedRotation(
                  turns: _showAddVenue ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search venues...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  /// Build the animated add venue form
  Widget _buildAddVenueForm() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (!_showAddVenue && _animationController.isDismissed) {
          return const SizedBox.shrink();
        }
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_location,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add New Venue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Form fields
                    _buildFormField(
                      controller: _nameController,
                      label: 'Venue Name',
                      icon: Icons.business,
                      onChanged: (value) =>
                          setState(() => _newVenueName = value),
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      onChanged: (value) =>
                          setState(() => _newVenueAddress = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: _phoneController,
                            label: 'Phone',
                            icon: Icons.phone,
                            onChanged: (value) =>
                                setState(() => _newVenuePhone = value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            controller: _capacityController,
                            label: 'Capacity',
                            icon: Icons.people,
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                setState(() => _newVenueCapacity = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) =>
                          setState(() => _newVenueEmail = value),
                    ),
                    const SizedBox(height: 24),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleSubmit,
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Add Venue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build a form field with icon
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF10B981),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// Build the venue cards list
  Widget _buildVenueList() {
    final venues = _filteredVenues;

    if (venues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No venues found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        return _buildVenueCard(venues[index]);
      },
    );
  }

  /// Build a single venue card
  Widget _buildVenueCard(Venue venue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Gradient icon container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: venue.gradient,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: venue.gradient[0].withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    venue.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              venue.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contact info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 10),
                      Text(
                        venue.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          venue.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.people,
                    label: 'Capacity',
                    value: venue.capacity.toString(),
                    gradient: const [Color(0xFF10B981), Color(0xFF14B8A6)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.event,
                    label: 'Events',
                    value: venue.events.toString(),
                    gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a stat item widget
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient[0].withValues(alpha: 0.1),
            gradient[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient[0].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: gradient[0],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
