import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../cubit/venues_cubit.dart';
import '../cubit/venues_state.dart';

/// Widget for the add venue form
class AddVenueFormWidget extends StatefulWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const AddVenueFormWidget({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<AddVenueFormWidget> createState() => _AddVenueFormWidgetState();
}

class _AddVenueFormWidgetState extends State<AddVenueFormWidget> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _capacityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _capacityController.dispose();

    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _capacityController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.slideAnimation,
      child: FadeTransition(
        opacity: widget.fadeAnimation,
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
                _buildFormHeader(),
                const SizedBox(height: 20),
                _buildFormFields(context),
                const SizedBox(height: 24),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.7)],
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
        Text(
          'Add New Venue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.tertiaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context) {
    return Column(
      children: [
        _FormField(
          controller: _nameController,
          label: 'Venue Name',
          icon: Icons.business,
          onChanged: (value) {
            context.read<VenuesCubit>().updateFormField(name: value);
          },
        ),
        const SizedBox(height: 16),
        _FormField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.location_on,
          onChanged: (value) {
            context.read<VenuesCubit>().updateFormField(address: value);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _FormField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone,
                onChanged: (value) {
                  context.read<VenuesCubit>().updateFormField(phone: value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _FormField(
                controller: _capacityController,
                label: 'Capacity',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  context.read<VenuesCubit>().updateFormField(capacity: value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _FormField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<VenuesCubit>().updateFormField(email: value);
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<VenuesCubit, VenuesState>(
      builder: (context, state) {
        final isLoading = state is VenueAdding;

        return SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading
                    ? null
                    : () {
                        widget.onSubmit();
                        // Reset form with new controllers
                        setState(() {
                          _resetForm();
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
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
        );
      },
    );
  }
}

/// Widget for a single form field
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray200,
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
            color: AppColors.primaryColor,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
