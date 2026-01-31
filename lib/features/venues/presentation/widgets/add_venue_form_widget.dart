import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _capacityController;

  late FocusNode _nameFocus;
  late FocusNode _addressFocus;
  late FocusNode _phoneFocus;
  late FocusNode _capacityFocus;
  late FocusNode _emailFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _capacityController = TextEditingController();

    _nameFocus = FocusNode();
    _addressFocus = FocusNode();
    _phoneFocus = FocusNode();
    _capacityFocus = FocusNode();
    _emailFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _capacityController.dispose();

    _nameFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    _capacityFocus.dispose();
    _emailFocus.dispose();

    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _capacityController.clear();
    _formKey.currentState?.reset();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit();
      setState(() {
        _resetForm();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.slideAnimation,
      child: FadeTransition(
        opacity: widget.fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.051)),
          child: Container(
            margin: EdgeInsets.only(bottom: context.dynamicHeight(0.025)),
            padding: EdgeInsets.all(context.dynamicWidth(0.061)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
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
                _buildFormHeader(context),
                SizedBox(height: context.dynamicHeight(0.025)),
                Form(
                  key: _formKey,
                  child: _buildFormFields(context),
                ),
                SizedBox(height: context.dynamicHeight(0.03)),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.025)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          ),
          child: Icon(
            Icons.add_location,
            color: Colors.white,
            size: context.dynamicWidth(0.051),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.029)),
        Text(
          'Add New Venue',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.045),
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
          focusNode: _nameFocus,
          label: 'Venue Name',
          icon: Icons.business,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _addressFocus.requestFocus(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Venue name is required';
            return null;
          },
          onChanged: (value) {
            context.read<VenuesCubit>().updateFormField(name: value);
          },
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        _FormField(
          controller: _addressController,
          focusNode: _addressFocus,
          label: 'Address',
          icon: Icons.location_on,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Address is required';
            return null;
          },
          onChanged: (value) {
            context.read<VenuesCubit>().updateFormField(address: value);
          },
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        Row(
          children: [
            Expanded(
              child: _FormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                label: 'Phone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                onChanged: (value) {
                  context.read<VenuesCubit>().updateFormField(phone: value);
                },
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: _FormField(
                controller: _capacityController,
                focusNode: _capacityFocus,
                label: 'Capacity',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                onChanged: (value) {
                  context.read<VenuesCubit>().updateFormField(capacity: value);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        _FormField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submitForm(),
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
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
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
                onTap: isLoading ? null : _submitForm,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.02)),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            height: context.dynamicWidth(0.051),
                            width: context.dynamicWidth(0.051),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Add Venue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.dynamicWidth(0.04),
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
  final FocusNode? focusNode;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    this.focusNode,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    required this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(fontSize: context.dynamicWidth(0.04)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.iconSecondary,
          fontSize: context.dynamicWidth(0.035),
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryColor,
          size: context.dynamicWidth(0.051),
        ),
        filled: true,
        fillColor: context.themeSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          borderSide: BorderSide(color: AppColors.red500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          borderSide: BorderSide(color: AppColors.red500, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.018),
        ),
      ),
    );
  }
}
