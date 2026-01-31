import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Location input section for invitation creation.
class InvitationLocationInput extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController addressController;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onAddressChanged;
  final FocusNode? locationFocusNode;
  final FocusNode? addressFocusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String?)? locationValidator;
  final String? Function(String?)? addressValidator;

  const InvitationLocationInput({
    super.key,
    required this.locationController,
    required this.addressController,
    required this.onLocationChanged,
    required this.onAddressChanged,
    this.locationFocusNode,
    this.addressFocusNode,
    this.nextFocusNode,
    this.locationValidator,
    this.addressValidator,
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
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        AppTextField(
          controller: locationController,
          focusNode: locationFocusNode,
          hintText: 'Venue name',
          prefixIcon: Icons.location_on_outlined,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => addressFocusNode?.requestFocus(),
          onChanged: onLocationChanged,
          validator: locationValidator,
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        AppTextField(
          controller: addressController,
          focusNode: addressFocusNode,
          hintText: 'Full address',
          prefixIcon: Icons.map_outlined,
          textInputAction: nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
          onSubmitted: (_) {
            if (nextFocusNode != null) {
              nextFocusNode!.requestFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          onChanged: onAddressChanged,
          validator: addressValidator,
        ),
      ],
    );
  }
}
