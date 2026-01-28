import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = !t.isEnLocale;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: _handleStateChange,
        builder: (context, state) => _buildBody(context, state, isArabic),
      ),
    );
  }

  void _handleStateChange(BuildContext context, ProfileState state) {
    if (state is ProfileUpdated || state is UserTypeChanged) {
      final message = state is ProfileUpdated
          ? state.message
          : (state as UserTypeChanged).message;
      AppSnackBar.showSuccess(context, message: message);
      context.read<ProfileCubit>().resetToLoaded();
    } else if (state is ProfileError && state.user != null) {
      AppSnackBar.showError(context, message: state.message);
      context.read<ProfileCubit>().resetToLoaded();
    }
  }

  Widget _buildBody(BuildContext context, ProfileState state, bool isArabic) {
    if (state is ProfileLoading) {
      return const ProfileSkeleton();
    }

    if (state is ProfileError && state.user == null) {
      return _ErrorView(message: state.message);
    }

    final (user, isUpdating) = _extractUserState(state);
    if (user == null) return const ProfileSkeleton();

    return _ProfileContent(
      user: user,
      isArabic: isArabic,
      isUpdating: isUpdating,
      onBack: widget.onBack,
    );
  }

  (UserEntity?, bool) _extractUserState(ProfileState state) {
    return switch (state) {
      ProfileLoaded(:final user) => (user, false),
      ProfileUpdating(:final user) => (user, true),
      ProfileUpdated(:final user) => (user, false),
      UserTypeChanged(:final user) => (user, false),
      ProfileError(:final user) => (user, false),
      _ => (null, false),
    };
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.08)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.dynamicWidth(0.2),
              color: AppColors.red500,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.04),
                color: AppColors.gray600,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            ElevatedButton(
              onPressed: () => context.read<ProfileCubit>().loadProfile(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.08),
                  vertical: context.dynamicHeight(0.015),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(t.translate('common_retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserEntity user;
  final bool isArabic;
  final bool isUpdating;
  final VoidCallback? onBack;

  const _ProfileContent({
    required this.user,
    required this.isArabic,
    required this.isUpdating,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                user: user,
                isArabic: isArabic,
                onBack: onBack,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(context.dynamicWidth(0.051)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ProfileSections(user: user, isArabic: isArabic),
                ]),
              ),
            ),
          ],
        ),
        if (isUpdating) const _LoadingOverlay(),
      ],
    );
  }
}

class _ProfileSections extends StatelessWidget {
  final UserEntity user;
  final bool isArabic;

  const _ProfileSections({required this.user, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<ProfileCubit>();
    final currentUser = (cubit.state is ProfileLoaded)
        ? (cubit.state as ProfileLoaded).user
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: t.translate('profile_account_type')),
        SizedBox(height: context.dynamicHeight(0.015)),
        ProfileUserTypeCard(
          user: user,
          isArabic: isArabic,
          onTypeSelected: (type) => ProfileDialogs.showChangeUserType(
            context,
            newType: type,
            isArabic: isArabic,
            currentUser: currentUser,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.03)),
        _SectionTitle(title: t.translate('profile_personal_info')),
        SizedBox(height: context.dynamicHeight(0.015)),
        ProfileInfoCard(user: user),
        SizedBox(height: context.dynamicHeight(0.03)),
        _SectionTitle(title: t.translate('profile_account_actions')),
        SizedBox(height: context.dynamicHeight(0.015)),
        ProfileActionsCard(
          onEditProfile: () => ProfileDialogs.showEditProfile(context),
          onChangePassword: () => ProfileDialogs.showChangePassword(context),
          onLogout: () => ProfileDialogs.showLogout(context),
          onDeleteAccount: () => ProfileDialogs.showDeleteAccount(context),
        ),
        SizedBox(height: context.dynamicHeight(0.119)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.045),
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
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
