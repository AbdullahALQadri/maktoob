import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/utils/person_name.dart';
import '../../../../core/widgets/page/page_kit.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_photo_picker.dart';

/// Editing the personal details: the photo, the name, the email, and for
/// an institution its workplace. The mobile number is the sign-in and is
/// changed with the team.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.name);
  late final _email = TextEditingController(text: widget.user.email);
  late final _company = TextEditingController(text: widget.user.companyName ?? '');

  /// The latest user: the photo changes in place, before Save.
  late UserEntity _user = widget.user;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _company.dispose();
    super.dispose();
  }

  bool get _changed =>
      _name.text.trim() != widget.user.name ||
      _email.text.trim() != widget.user.email ||
      _company.text.trim() != (widget.user.companyName ?? '');

  void _save() {
    if (!_formKey.currentState!.validate() || !_changed) return;
    final company = _company.text.trim();
    context.read<ProfileCubit>().updateProfile(
          name: _name.text.trim(),
          email: _email.text.trim(),
          companyName: company.isEmpty ? null : company,
        );
  }

  String? _nameError(String? value) {
    if (value == null || value.trim().isEmpty) return context.tr('auth_field_required');
    // A name left as it was is not judged again (older accounts).
    if (PersonName.clean(value) == widget.user.name) return null;
    final error = PersonName.fullNameErrorKey(value);
    return error == null ? null : context.tr(error);
  }

  String? _emailError(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value.trim()) ? null : context.tr('auth_email_invalid');
  }

  void _onState(BuildContext context, ProfileState state) {
    if (state is ProfileAvatarChanged) {
      setState(() => _user = state.user);
      context.read<AuthCubit>().syncUser(state.user);
      AppSnackBar.showSuccess(context, message: context.tr('edit_profile_photo_saved'));
    } else if (state is ProfileUpdated) {
      context.read<AuthCubit>().syncUser(state.user);
      AppSnackBar.showSuccess(context, message: context.tr('edit_profile_saved'));
      Navigator.pop(context, true);
    } else if (state is ProfileError) {
      AppSnackBar.showError(context, message: state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: _onState,
      builder: (context, state) {
        final busy = state is ProfileUpdating;
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: AppBar(title: Text(context.tr('edit_profile_title'))),
          body: Form(
            key: _formKey,
            child: PageBody(
              children: [
                PageCard(
                  title: context.tr('edit_profile_photo'),
                  child: ProfilePhotoPicker(user: _user, enabled: !busy),
                ),
                PageCard(
                  title: context.tr('profile_personal_info'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        key: const Key('edit_profile_name'),
                        controller: _name,
                        labelText: context.tr('profile_name'),
                        hintText: context.tr('edit_profile_name_hint'),
                        textInputAction: TextInputAction.next,
                        validator: _nameError,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        key: const Key('edit_profile_email'),
                        controller: _email,
                        labelText: context.tr('profile_email'),
                        hintText: context.tr('edit_profile_email_hint'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _emailError,
                      ),
                      if (widget.user.isInstitution) ...[
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _company,
                          labelText: context.tr('profile_organization'),
                          hintText: context.tr('edit_profile_company_hint'),
                        ),
                      ],
                    ],
                  ),
                ),
                PageCard.rows(
                  rows: [
                    PageRow(
                      icon: Icons.phone_outlined,
                      title: widget.user.phone ?? context.tr('common_not_set'),
                      subtitle: context.tr('edit_profile_phone_locked'),
                      trailing: Icon(Icons.lock_outline, size: 18, color: context.iconDefault),
                    ),
                  ],
                ),
                PrimaryButton(
                  key: const Key('edit_profile_save'),
                  text: context.tr('common_save'),
                  isLoading: busy,
                  onPressed: busy ? null : _save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
