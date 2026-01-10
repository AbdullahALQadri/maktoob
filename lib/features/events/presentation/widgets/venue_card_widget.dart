import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/models/event_models.dart' hide CustomVenue;
import '../screens/create_event_screen.dart';

class VenueSelectionWidget extends StatelessWidget {
  final List<VenueModel> venues;
  final String? selectedVenue;
  final bool showCustomVenue;
  final MutableCustomVenue customVenue;
  final Function(String) onVenueSelected;
  final VoidCallback onToggleCustomVenue;
  final Function(MutableCustomVenue) onCustomVenueChanged;

  const VenueSelectionWidget({
    super.key,
    required this.venues,
    required this.selectedVenue,
    required this.showCustomVenue,
    required this.customVenue,
    required this.onVenueSelected,
    required this.onToggleCustomVenue,
    required this.onCustomVenueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Venue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: venues.length,
          itemBuilder: (context, index) {
            final venue = venues[index];
            final isSelected = selectedVenue == venue.id;
            return _VenueCard(
              venue: venue,
              isSelected: isSelected,
              onTap: () => onVenueSelected(venue.id),
            );
          },
        ),
        const SizedBox(height: 12),
        _CustomVenueButton(
          isActive: showCustomVenue,
          onTap: onToggleCustomVenue,
        ),
        if (showCustomVenue) ...[
          const SizedBox(height: 12),
          _CustomVenueForm(
            customVenue: customVenue,
            onChanged: onCustomVenueChanged,
          ),
        ],
      ],
    );
  }
}

class _VenueCard extends StatelessWidget {
  final VenueModel venue;
  final bool isSelected;
  final VoidCallback onTap;

  const _VenueCard({
    required this.venue,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.purple600, AppColors.pink600],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.purple600.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              venue.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.gray900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Capacity: ${venue.capacity}',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomVenueButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CustomVenueButton({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.purple600 : AppColors.gray300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add,
              color: AppColors.purple600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Custom Venue',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomVenueForm extends StatelessWidget {
  final MutableCustomVenue customVenue;
  final Function(MutableCustomVenue) onChanged;

  const _CustomVenueForm({
    required this.customVenue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            hint: 'Venue Name',
            value: customVenue.name,
            onChanged: (v) => onChanged(MutableCustomVenue(
              name: v,
              address: customVenue.address,
              capacity: customVenue.capacity,
            )),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            hint: 'Address',
            value: customVenue.address,
            onChanged: (v) => onChanged(MutableCustomVenue(
              name: customVenue.name,
              address: v,
              capacity: customVenue.capacity,
            )),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            hint: 'Capacity',
            value: customVenue.capacity,
            keyboardType: TextInputType.number,
            onChanged: (v) => onChanged(MutableCustomVenue(
              name: customVenue.name,
              address: customVenue.address,
              capacity: v,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required String value,
    required Function(String) onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: value,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray100, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.gray100, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.purple600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
