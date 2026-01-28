import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Location input section for invitation creation.
class InvitationLocationInput extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController addressController;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onAddressChanged;

  const InvitationLocationInput({
    super.key,
    required this.locationController,
    required this.addressController,
    required this.onLocationChanged,
    required this.onAddressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        AppTextField(
          controller: locationController,
          hintText: 'Venue name',
          prefixIcon: Icons.location_on_outlined,
          onChanged: onLocationChanged,
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        AppTextField(
          controller: addressController,
          hintText: 'Full address',
          prefixIcon: Icons.map_outlined,
          onChanged: onAddressChanged,
        ),
      ],
    );
  }
}
