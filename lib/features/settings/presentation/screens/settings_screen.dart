import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/dialogs/app_dialog.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/profile_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final t = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: AppColors.gray100,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(context, t),
              ),
              // Content
              SliverPadding(
                padding: EdgeInsets.all(19.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Language Section
                    _buildSectionTitle(context, t.translate('settings_language')),
                    SizedBox(height: 12.h),
                    _buildLanguageCard(context, state),

                    SizedBox(height: 24.h),

                    // Profile Section
                    _buildSectionTitle(context, t.translate('settings_account')),
                    SizedBox(height: 12.h),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.person_outline,
                      title: t.translate('settings_profile'),
                      subtitle: t.translate('settings_profile_desc'),
                      onTap: () => _showProfileDialog(context),
                    ),

                    SizedBox(height: 24.h),

                    // Support Section
                    _buildSectionTitle(context, t.translate('settings_support')),
                    SizedBox(height: 12.h),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.email_outlined,
                      title: t.translate('settings_contact'),
                      subtitle: t.translate('settings_contact_desc'),
                      onTap: () => _showContactDialog(context),
                    ),
                    SizedBox(height: 12.h),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.help_outline,
                      title: t.translate('settings_help'),
                      subtitle: t.translate('settings_help_desc'),
                      onTap: () => _showHelpDialog(context),
                    ),

                    SizedBox(height: 24.h),

                    // About Section
                    _buildSectionTitle(context, t.translate('settings_about')),
                    SizedBox(height: 12.h),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.info_outline,
                      title: t.translate('settings_about_maktoob'),
                      subtitle: t.translate('settings_version'),
                      onTap: () => _showAboutDialog(context),
                    ),

                    SizedBox(height: 97.h),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations t) {
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
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            23.w,
            24.h,
            23.w,
            32.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.translate('settings_title'),
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                t.translate('settings_subtitle'),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, SettingsState state) {
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
          _buildLanguageOption(
            context: context,
            title: 'العربية',
            subtitle: 'Arabic',
            isSelected: state.language == AppLanguage.ar,
            onTap: () => context.read<SettingsCubit>().setLanguage(AppLanguage.ar),
          ),
          Divider(color: AppColors.gray100, height: 16.h),
          _buildLanguageOption(
            context: context,
            title: 'English',
            subtitle: 'الإنجليزية',
            isSelected: state.language == AppLanguage.en,
            onTap: () => context.read<SettingsCubit>().setLanguage(AppLanguage.en),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 8.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple50 : Colors.transparent,
          borderRadius: BorderRadius.circular(11.w),
        ),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                      )
                    : null,
                color: isSelected ? null : AppColors.gray100,
                borderRadius: BorderRadius.circular(11.w),
              ),
              child: Icon(
                Icons.language,
                color: isSelected ? Colors.white : AppColors.gray400,
                size: 23.w,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryColor : AppColors.gray900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 23.w,
                height: 23.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 13.w,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: AppColors.purple50,
                borderRadius: BorderRadius.circular(11.w),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 23.w,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.gray400,
              size: 15.w,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<ProfileCubit>(),
          child: ProfileScreen(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    AppBottomSheet.show(
      context,
      title: t.translate('settings_contact'),
      subtitle: t.translate('settings_contact_subtitle'),
      icon: Icons.contact_support_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContactOption(
            context: context,
            icon: Icons.email_rounded,
            title: t.translate('settings_email'),
            value: 'support@maktoob.app',
            onTap: () => _copyToClipboard(context, 'support@maktoob.app'),
          ),
          SizedBox(height: 12.h),
          _buildContactOption(
            context: context,
            icon: Icons.phone_rounded,
            title: t.translate('settings_phone'),
            value: '+966 XX XXX XXXX',
            onTap: () => _copyToClipboard(context, '+966XXXXXXXX'),
          ),
          SizedBox(height: 12.h),
          _buildContactOption(
            context: context,
            icon: Icons.chat_rounded,
            title: t.translate('settings_whatsapp'),
            value: '+966 XX XXX XXXX',
            onTap: () => _copyToClipboard(context, '+966XXXXXXXX'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(13.w),
          border: Border.all(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 41.w,
              height: 41.w,
              decoration: BoxDecoration(
                color: AppColors.purple50,
                borderRadius: BorderRadius.circular(9.w),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 21.w,
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Icon(
                Icons.copy_rounded,
                color: AppColors.gray500,
                size: 17.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    final t = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.showSuccess(
      context,
      message: t.translate('common_copied'),
      duration: const Duration(seconds: 2),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    AppDialog.showInfo(
      context,
      title: t.translate('settings_help'),
      message: t.translate('settings_help_contact'),
      buttonText: t.translate('common_ok'),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    AppDialog.show(
      context,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 23.w,
          vertical: 24.h,
        ),
        child: Container(
          padding: EdgeInsets.all(23.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30.w,
                offset: Offset(0, 16.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Container(
                width: 75.w,
                height: 75.w,
                decoration: BoxDecoration(
                  color: AppColors.purple50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 19.w,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_rounded,
                  size: 38.w,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              // Title
              Text(
                t.translate('settings_about_maktoob'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: 12.h),
              // Description
              Text(
                t.translate('settings_about_text'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.gray600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              // Version badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(19.w),
                ),
                child: Text(
                  t.translate('settings_version'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // OK Button
              SizedBox(
                width: double.infinity,
                height: 49.h,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                    ),
                    borderRadius: BorderRadius.circular(13.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 11.w,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(13.w),
                      child: Center(
                        child: Text(
                          t.translate('common_ok'),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
