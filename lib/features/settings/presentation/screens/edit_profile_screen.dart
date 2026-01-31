import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _companyNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _companyNameController =
        TextEditingController(text: widget.user.companyName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    return _nameController.text.trim() != widget.user.name ||
        _emailController.text.trim() != widget.user.email ||
        _companyNameController.text.trim() != (widget.user.companyName ?? '');
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) return;

    context.read<ProfileCubit>().updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          companyName: _companyNameController.text.trim().isEmpty
              ? null
              : _companyNameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          AppSnackBar.showSuccess(context,
              message: t.translate('edit_profile_saved'));
          Navigator.pop(context, true);
        } else if (state is ProfileError) {
          AppSnackBar.showError(context, message: state.message);
        }
      },
      builder: (context, state) {
        final isUpdating = state is ProfileUpdating;

        return Scaffold(
          backgroundColor: context.overlayBg,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context, t, isUpdating),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.051),
                        vertical: context.dynamicHeight(0.025),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNameField(context, t),
                            SizedBox(height: context.dynamicHeight(0.02)),
                            _buildEmailField(context, t),
                            SizedBox(height: context.dynamicHeight(0.02)),
                            _buildPhoneField(context, t),
                            SizedBox(height: context.dynamicHeight(0.02)),
                            if (widget.user.isInstitution)
                              _buildCompanyField(context, t),
                            SizedBox(height: context.dynamicHeight(0.04)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isUpdating) _buildLoadingOverlay(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations t, bool isUpdating) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.dynamicWidth(0.04),
                context.dynamicHeight(0.015),
                context.dynamicWidth(0.04),
                context.dynamicHeight(0.03),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 22),
                        ),
                      ),
                      const Spacer(),
                      _buildSaveButton(context, t, isUpdating),
                    ],
                  ),
                  SizedBox(height: context.dynamicHeight(0.025)),
                  Row(
                    children: [
                      Container(
                        width: context.dynamicWidth(0.125),
                        height: context.dynamicWidth(0.125),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                              context.dynamicWidth(0.04)),
                        ),
                        child: Icon(Icons.person_outline_rounded,
                            color: Colors.white,
                            size: context.dynamicWidth(0.065)),
                      ),
                      SizedBox(width: context.dynamicWidth(0.035)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.translate('edit_profile_title'),
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: context.dynamicHeight(0.005)),
                            Text(
                              widget.user.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: IgnorePointer(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      BuildContext context, AppLocalizations t, bool isUpdating) {
    if (isUpdating) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _hasChanges ? _saveProfile : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.012),
        ),
        decoration: BoxDecoration(
          color: _hasChanges
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          t.translate('common_save'),
          style: TextStyle(
            color: _hasChanges
                ? AppColors.primaryColor
                : Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
            fontSize: context.dynamicWidth(0.035),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(BuildContext context, AppLocalizations t) {
    return AppTextField(
      controller: _nameController,
      labelText: t.translate('profile_name'),
      hintText: t.translate('edit_profile_name_hint'),
      prefixIcon: Icons.person_outline_rounded,
      textInputAction: TextInputAction.next,
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return t.translate('auth_field_required');
        }
        if (value.trim().length < 2) {
          return t.translate('auth_min_2_chars');
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(BuildContext context, AppLocalizations t) {
    return AppTextField(
      controller: _emailController,
      labelText: t.translate('profile_email'),
      hintText: t.translate('edit_profile_email_hint'),
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return t.translate('auth_field_required');
        }
        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
        if (!emailRegex.hasMatch(value.trim())) {
          return t.translate('auth_email_invalid');
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          t.translate('profile_phone'),
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            fontWeight: FontWeight.w500,
            color: context.textTertiary,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.04),
            vertical: context.dynamicHeight(0.02),
          ),
          decoration: BoxDecoration(
            color: context.inputFill.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: context.dynamicWidth(0.056),
                color: context.iconDefault.withValues(alpha: 0.5),
              ),
              SizedBox(width: context.dynamicWidth(0.025)),
              Expanded(
                child: Text(
                  widget.user.phone ?? t.translate('common_not_set'),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    color: context.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: context.dynamicWidth(0.045),
                color: context.iconDefault.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        Text(
          t.translate('edit_profile_phone_locked'),
          style: TextStyle(
            fontSize: context.dynamicWidth(0.03),
            color: context.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyField(BuildContext context, AppLocalizations t) {
    return AppTextField(
      controller: _companyNameController,
      labelText: t.translate('profile_organization'),
      hintText: t.translate('edit_profile_company_hint'),
      prefixIcon: Icons.business_outlined,
      textInputAction: TextInputAction.done,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.061)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}
