import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
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
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11.w,
            mainAxisSpacing: 11.w,
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
        SizedBox(height: 12.h),
        _CustomVenueButton(
          isActive: showCustomVenue,
          onTap: onToggleCustomVenue,
        ),
        if (showCustomVenue) ...[
          SizedBox(height: 12.h),
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
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
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
              style: TextStyle(fontSize: 26.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              venue.name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.gray900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              'Capacity: ${venue.capacity}',
              style: TextStyle(
                fontSize: 11.sp,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
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
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple50 : Colors.white,
          borderRadius: BorderRadius.circular(15.w),
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
              size: 23.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'Add Custom Venue',
              style: TextStyle(
                fontSize: 13.sp,
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
      padding: EdgeInsets.all(15.w),
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
          SizedBox(height: 12.h),
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
          SizedBox(height: 12.h),
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
      style: TextStyle(fontSize: 13.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp),
        filled: true,
        fillColor: AppColors.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.w),
          borderSide: BorderSide(color: AppColors.gray100, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.w),
          borderSide: BorderSide(color: AppColors.gray100, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11.w),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 15.h,
        ),
      ),
    );
  }
}
