import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
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
            fontSize: context.dynamicWidth(0.05),
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: context.dynamicWidth(0.03),
            mainAxisSpacing: context.dynamicWidth(0.03),
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
        SizedBox(height: context.dynamicHeight(0.015)),
        _CustomVenueButton(
          isActive: showCustomVenue,
          onTap: onToggleCustomVenue,
        ),
        if (showCustomVenue) ...[
          SizedBox(height: context.dynamicHeight(0.015)),
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
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.3)
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
              style: TextStyle(fontSize: context.dynamicWidth(0.07)),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              venue.name,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.033),
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.gray900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            Text(
              'Capacity: ${venue.capacity}',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.028),
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
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple50 : Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          border: Border.all(
            color: isActive ? AppColors.primaryColor : AppColors.gray300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add,
              color: AppColors.primaryColor,
              size: context.dynamicWidth(0.06),
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            Text(
              'Add Custom Venue',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
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
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
            context: context,
            hint: 'Venue Name',
            value: customVenue.name,
            onChanged: (v) => onChanged(MutableCustomVenue(
              name: v,
              address: customVenue.address,
              capacity: customVenue.capacity,
            )),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          _buildTextField(
            context: context,
            hint: 'Address',
            value: customVenue.address,
            onChanged: (v) => onChanged(MutableCustomVenue(
              name: customVenue.name,
              address: v,
              capacity: customVenue.capacity,
            )),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          _buildTextField(
            context: context,
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
    required BuildContext context,
    required String hint,
    required String value,
    required Function(String) onChanged,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      initialValue: value,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: context.dynamicWidth(0.035)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: context.dynamicWidth(0.035)),
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          borderSide: BorderSide(color: AppColors.gray100, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          borderSide: BorderSide(color: AppColors.gray100, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.018),
        ),
      ),
    );
  }
}
