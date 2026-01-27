import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/loading/shimmer_loading.dart';
import '../../../../core/widgets/loading/skeleton_widgets.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

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
    final l = AppLocalizations.of(context);
    final isArabic = !(l?.isEnLocale ?? true);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
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
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return _buildLoadingState(context);
          }

          if (state is ProfileError && state.user == null) {
            return _buildErrorState(context, state.message, isArabic);
          }

          UserEntity? user;
          bool isUpdating = false;

          if (state is ProfileLoaded) {
            user = state.user;
          } else if (state is ProfileUpdating) {
            user = state.user;
            isUpdating = true;
          } else if (state is ProfileUpdated) {
            user = state.user;
          } else if (state is UserTypeChanged) {
            user = state.user;
          } else if (state is ProfileError) {
            user = state.user;
          }

          if (user == null) {
            return _buildLoadingState(context);
          }

          return _buildProfileContent(context, user, isArabic, isUpdating);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header skeleton
        SliverToBoxAdapter(
          child: _buildHeaderSkeleton(context),
        ),
        // Content skeleton
        SliverPadding(
          padding: EdgeInsets.all(context.dynamicWidth(0.05)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // User Type Section skeleton
              _buildSectionTitleSkeleton(context),
              SizedBox(height: context.dynamicHeight(0.015)),
              _buildUserTypeCardSkeleton(context),

              SizedBox(height: context.dynamicHeight(0.03)),

              // Personal Info Section skeleton
              _buildSectionTitleSkeleton(context),
              SizedBox(height: context.dynamicHeight(0.015)),
              _buildInfoCardSkeleton(context),

              SizedBox(height: context.dynamicHeight(0.03)),

              // Account Actions Section skeleton
              _buildSectionTitleSkeleton(context),
              SizedBox(height: context.dynamicHeight(0.015)),
              _buildActionsCardSkeleton(context),

              SizedBox(height: context.dynamicHeight(0.12)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar skeleton
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.05),
                vertical: context.dynamicHeight(0.015),
              ),
              child: Row(
                children: [
                  ShimmerLoading(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ShimmerLoading(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                    child: Container(
                      width: 100,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Name and info skeleton
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.dynamicWidth(0.06),
                context.dynamicHeight(0.02),
                context.dynamicWidth(0.06),
                context.dynamicHeight(0.04),
              ),
              child: Column(
                children: [
                  // Name skeleton
                  ShimmerLoading(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                    child: Container(
                      width: context.dynamicWidth(0.4),
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.01)),
                  // Email skeleton
                  ShimmerLoading(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                    child: Container(
                      width: context.dynamicWidth(0.5),
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  // User type badge skeleton
                  ShimmerLoading(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                    child: Container(
                      width: 120,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitleSkeleton(BuildContext context) {
    return ShimmerLoading(
      child: SkeletonBox(
        width: context.dynamicWidth(0.35),
        height: 22,
        borderRadius: 6,
      ),
    );
  }

  Widget _buildUserTypeCardSkeleton(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
            _buildUserTypeOptionSkeleton(context),
            Divider(color: AppColors.gray100, height: context.dynamicHeight(0.02)),
            _buildUserTypeOptionSkeleton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeOptionSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: context.dynamicHeight(0.015),
        horizontal: context.dynamicWidth(0.02),
      ),
      child: Row(
        children: [
          SkeletonBox(
            width: context.dynamicWidth(0.12),
            height: context.dynamicWidth(0.12),
            borderRadius: context.dynamicWidth(0.03),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: context.dynamicWidth(0.3),
                  height: 18,
                  borderRadius: 4,
                ),
                SizedBox(height: context.dynamicHeight(0.005)),
                SkeletonBox(
                  width: context.dynamicWidth(0.5),
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardSkeleton(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
            _buildInfoRowSkeleton(context),
            Divider(color: AppColors.gray100, height: context.dynamicHeight(0.025)),
            _buildInfoRowSkeleton(context),
            Divider(color: AppColors.gray100, height: context.dynamicHeight(0.025)),
            _buildInfoRowSkeleton(context),
            Divider(color: AppColors.gray100, height: context.dynamicHeight(0.025)),
            _buildInfoRowSkeleton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRowSkeleton(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(
          width: context.dynamicWidth(0.1),
          height: context.dynamicWidth(0.1),
          borderRadius: context.dynamicWidth(0.025),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                width: context.dynamicWidth(0.2),
                height: 14,
                borderRadius: 4,
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              SkeletonBox(
                width: context.dynamicWidth(0.45),
                height: 18,
                borderRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCardSkeleton(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
            _buildActionItemSkeleton(context),
            Divider(color: AppColors.gray100, height: 1),
            _buildActionItemSkeleton(context),
            Divider(color: AppColors.gray100, height: 1),
            _buildActionItemSkeleton(context),
            Divider(color: AppColors.gray100, height: 1),
            _buildActionItemSkeleton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItemSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Row(
        children: [
          SkeletonBox(
            width: context.dynamicWidth(0.055),
            height: context.dynamicWidth(0.055),
            borderRadius: 6,
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: SkeletonBox(
              width: context.dynamicWidth(0.35),
              height: 18,
              borderRadius: 4,
            ),
          ),
          SkeletonBox(
            width: context.dynamicWidth(0.04),
            height: context.dynamicWidth(0.04),
            borderRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isArabic) {
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
              child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserEntity user,
    bool isArabic,
    bool isUpdating,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Header with gradient
            SliverToBoxAdapter(
              child: _buildHeader(context, user, isArabic),
            ),
            // Profile Content
            SliverPadding(
              padding: EdgeInsets.all(context.dynamicWidth(0.05)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // User Type Section
                  _buildSectionTitle(
                    context,
                    isArabic ? 'نوع الحساب' : 'Account Type',
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildUserTypeCard(context, user, isArabic),

                  SizedBox(height: context.dynamicHeight(0.03)),

                  // Personal Info Section
                  _buildSectionTitle(
                    context,
                    isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildInfoCard(context, user, isArabic),

                  SizedBox(height: context.dynamicHeight(0.03)),

                  // Account Actions Section
                  _buildSectionTitle(
                    context,
                    isArabic ? 'إجراءات الحساب' : 'Account Actions',
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  _buildActionsCard(context, isArabic),

                  SizedBox(height: context.dynamicHeight(0.12)),
                ]),
              ),
            ),
          ],
        ),
        if (isUpdating)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(context.dynamicWidth(0.06)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, UserEntity user, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.05),
                vertical: context.dynamicHeight(0.015),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ?? () => Navigator.pop(context),
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
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isArabic ? 'الملف الشخصي' : 'Profile',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.05),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Placeholder to balance the back button
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Name and info
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.dynamicWidth(0.06),
                context.dynamicHeight(0.02),
                context.dynamicWidth(0.06),
                context.dynamicHeight(0.04),
              ),
              child: Column(
                children: [
                  // Name
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.06),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.dynamicHeight(0.005)),
                  // Email
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.035),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  // User type badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.04),
                      vertical: context.dynamicHeight(0.008),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.isInstitution
                              ? Icons.business
                              : Icons.person,
                          color: Colors.white,
                          size: context.dynamicWidth(0.04),
                        ),
                        SizedBox(width: context.dynamicWidth(0.02)),
                        Text(
                          isArabic
                              ? user.userType.displayNameAr
                              : user.userType.displayName,
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.032),
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user.isVerified) ...[
                    SizedBox(height: context.dynamicHeight(0.01)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: context.dynamicWidth(0.04),
                        ),
                        SizedBox(width: context.dynamicWidth(0.01)),
                        Text(
                          isArabic ? 'موثّق' : 'Verified',
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.03),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.045),
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context,
    UserEntity user,
    bool isArabic,
  ) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
          _buildUserTypeOption(
            context: context,
            title: isArabic ? 'فرد' : 'Individual',
            subtitle: isArabic
                ? 'حساب شخصي لإدارة الفعاليات الخاصة'
                : 'Personal account for managing private events',
            icon: Icons.person,
            isSelected: user.userType == UserType.user,
            onTap: () => _showChangeUserTypeDialog(context, UserType.user, isArabic),
          ),
          Divider(color: AppColors.gray100, height: context.dynamicHeight(0.02)),
          _buildUserTypeOption(
            context: context,
            title: isArabic ? 'مؤسسة' : 'Institution',
            subtitle: isArabic
                ? 'حساب أعمال لإدارة الفعاليات التجارية'
                : 'Business account for managing commercial events',
            icon: Icons.business,
            isSelected: user.userType == UserType.institution,
            onTap: () => _showChangeUserTypeDialog(context, UserType.institution, isArabic),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.015),
          horizontal: context.dynamicWidth(0.02),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple50 : Colors.transparent,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        ),
        child: Row(
          children: [
            Container(
              width: context.dynamicWidth(0.12),
              height: context.dynamicWidth(0.12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                      )
                    : null,
                color: isSelected ? null : AppColors.gray100,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.gray400,
                size: context.dynamicWidth(0.06),
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.04),
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryColor : AppColors.gray900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.028),
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: context.dynamicWidth(0.06),
                height: context.dynamicWidth(0.06),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: context.dynamicWidth(0.035),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, UserEntity user, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
          _buildInfoRow(
            context: context,
            icon: Icons.person_outline,
            label: isArabic ? 'الاسم' : 'Name',
            value: user.name,
          ),
          Divider(color: AppColors.gray100, height: context.dynamicHeight(0.025)),
          _buildInfoRow(
            context: context,
            icon: Icons.email_outlined,
            label: isArabic ? 'البريد الإلكتروني' : 'Email',
            value: user.email,
          ),
          if (user.phone != null) ...[
            Divider(color: AppColors.gray100, height: context.dynamicHeight(0.025)),
            _buildInfoRow(
              context: context,
              icon: Icons.phone_outlined,
              label: isArabic ? 'رقم الهاتف' : 'Phone',
              value: user.phone!,
            ),
          ],
          if (user.companyName != null) ...[
            Divider(color: AppColors.gray100, height: context.dynamicHeight(0.025)),
            _buildInfoRow(
              context: context,
              icon: Icons.business_outlined,
              label: isArabic ? 'اسم المنظمة' : 'Organization',
              value: user.companyName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: context.dynamicWidth(0.1),
          height: context.dynamicWidth(0.1),
          decoration: BoxDecoration(
            color: AppColors.purple50,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.025)),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: context.dynamicWidth(0.05),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.03),
                  color: AppColors.gray500,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.003)),
              Text(
                value,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.038),
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(BuildContext context, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
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
          _buildActionItem(
            context: context,
            icon: Icons.edit_outlined,
            title: isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
            onTap: () => _showEditProfileDialog(context, isArabic),
          ),
          Divider(color: AppColors.gray100, height: 1),
          _buildActionItem(
            context: context,
            icon: Icons.lock_outline,
            title: isArabic ? 'تغيير كلمة المرور' : 'Change Password',
            onTap: () => _showChangePasswordDialog(context, isArabic),
          ),
          Divider(color: AppColors.gray100, height: 1),
          _buildActionItem(
            context: context,
            icon: Icons.logout,
            title: isArabic ? 'تسجيل الخروج' : 'Logout',
            isDestructive: false,
            onTap: () => _showLogoutDialog(context, isArabic),
          ),
          Divider(color: AppColors.gray100, height: 1),
          _buildActionItem(
            context: context,
            icon: Icons.delete_outline,
            title: isArabic ? 'حذف الحساب' : 'Delete Account',
            isDestructive: true,
            onTap: () => _showDeleteAccountDialog(context, isArabic),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.red500 : AppColors.gray600,
              size: context.dynamicWidth(0.055),
            ),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.red500 : AppColors.gray900,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.gray400,
              size: context.dynamicWidth(0.04),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeUserTypeDialog(
    BuildContext context,
    UserType newType,
    bool isArabic,
  ) {
    final profileCubit = context.read<ProfileCubit>();
    final currentState = profileCubit.state;
    UserEntity? currentUser;
    if (currentState is ProfileLoaded) {
      currentUser = currentState.user;
    }

    if (currentUser?.userType == newType) return;

    final bool isConvertingToOrg = newType == UserType.institution;
    final reasonController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
            final bool canConfirm = reasonController.text.trim().isNotEmpty;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.06),
                vertical: context.dynamicHeight(0.03),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: context.dynamicWidth(0.9),
                ),
                padding: EdgeInsets.all(context.dynamicWidth(0.06)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: context.dynamicWidth(0.08),
                      offset: Offset(0, context.dynamicHeight(0.02)),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: context.dynamicWidth(0.2),
                        height: context.dynamicWidth(0.2),
                        decoration: BoxDecoration(
                          color: AppColors.purple50,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.2),
                              blurRadius: context.dynamicWidth(0.05),
                              offset: Offset(0, context.dynamicHeight(0.01)),
                            ),
                          ],
                        ),
                        child: Icon(
                          isConvertingToOrg ? Icons.business_rounded : Icons.person_rounded,
                          size: context.dynamicWidth(0.1),
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.02)),
                      // Title
                      Text(
                        isArabic ? 'تغيير نوع الحساب' : 'Change Account Type',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.dynamicWidth(0.055),
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.012)),
                      // Message
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dynamicWidth(0.02),
                        ),
                        child: Text(
                          isArabic
                              ? 'هل أنت متأكد من تغيير نوع حسابك إلى "${newType.displayNameAr}"؟'
                              : 'Are you sure you want to change your account type to "${newType.displayName}"?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.038),
                            color: AppColors.gray600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.025)),
                      // Reason TextField
                      AppTextField(
                        controller: reasonController,
                        labelText: isArabic ? 'سبب التحويل' : 'Reason for conversion',
                        hintText: isArabic ? 'أدخل سبب التحويل...' : 'Enter reason...',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: context.dynamicHeight(0.03)),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(dialogContext),
                              child: Container(
                                height: context.dynamicHeight(0.06),
                                decoration: BoxDecoration(
                                  color: AppColors.gray100,
                                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
                                ),
                                child: Center(
                                  child: Text(
                                    isArabic ? 'إلغاء' : 'Cancel',
                                    style: TextStyle(
                                      fontSize: context.dynamicWidth(0.04),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.dynamicWidth(0.03)),
                          Expanded(
                            child: GestureDetector(
                              onTap: canConfirm
                                  ? () {
                                      Navigator.pop(dialogContext);
                                      profileCubit.changeUserType(
                                        newType,
                                        reason: reasonController.text.trim(),
                                      );
                                    }
                                  : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: context.dynamicHeight(0.06),
                                decoration: BoxDecoration(
                                  gradient: canConfirm
                                      ? LinearGradient(
                                          colors: [
                                            AppColors.primaryColor,
                                            AppColors.tertiaryColor,
                                          ],
                                        )
                                      : null,
                                  color: canConfirm ? null : AppColors.gray300,
                                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
                                  boxShadow: canConfirm
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primaryColor.withValues(alpha: 0.3),
                                            blurRadius: context.dynamicWidth(0.03),
                                            offset: Offset(0, context.dynamicHeight(0.005)),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    isArabic ? 'تأكيد' : 'Confirm',
                                    style: TextStyle(
                                      fontSize: context.dynamicWidth(0.04),
                                      fontWeight: FontWeight.w600,
                                      color: canConfirm ? Colors.white : AppColors.gray500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, bool isArabic) {
    AppDialog.showInfo(
      context,
      title: isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
      message: isArabic
          ? 'ميزة تعديل الملف الشخصي قيد التطوير'
          : 'Edit profile feature coming soon',
      buttonText: isArabic ? 'حسناً' : 'OK',
    );
  }

  void _showChangePasswordDialog(BuildContext context, bool isArabic) {
    AppDialog.showInfo(
      context,
      title: isArabic ? 'تغيير كلمة المرور' : 'Change Password',
      message: isArabic
          ? 'ميزة تغيير كلمة المرور قيد التطوير'
          : 'Change password feature coming soon',
      buttonText: isArabic ? 'حسناً' : 'OK',
    );
  }

  void _showLogoutDialog(BuildContext context, bool isArabic) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: isArabic ? 'تسجيل الخروج' : 'Logout',
      message: isArabic
          ? 'هل أنت متأكد من تسجيل الخروج؟'
          : 'Are you sure you want to logout?',
      confirmText: isArabic ? 'تسجيل الخروج' : 'Logout',
      cancelText: isArabic ? 'إلغاء' : 'Cancel',
      type: DialogType.warning,
      icon: Icons.logout_rounded,
    );

    if (confirmed) {
      // TODO: Implement logout
    }
  }

  void _showDeleteAccountDialog(BuildContext context, bool isArabic) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: isArabic ? 'حذف الحساب' : 'Delete Account',
      message: isArabic
          ? 'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.'
          : 'Are you sure you want to delete your account? This action cannot be undone.',
      confirmText: isArabic ? 'حذف' : 'Delete',
      cancelText: isArabic ? 'إلغاء' : 'Cancel',
      type: DialogType.error,
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed) {
      // TODO: Implement delete account
    }
  }
}
