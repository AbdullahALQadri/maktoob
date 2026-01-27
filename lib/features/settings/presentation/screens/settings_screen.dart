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
                padding: EdgeInsets.all(context.dynamicWidth(0.051)),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Language Section
                    _buildSectionTitle(context, t.translate('settings_language')),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildLanguageCard(context, state),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // Profile Section
                    _buildSectionTitle(context, t.translate('settings_account')),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.person_outline,
                      title: t.translate('settings_profile'),
                      subtitle: t.translate('settings_profile_desc'),
                      onTap: () => _showProfileDialog(context),
                    ),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // Support Section
                    _buildSectionTitle(context, t.translate('settings_support')),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.email_outlined,
                      title: t.translate('settings_contact'),
                      subtitle: t.translate('settings_contact_desc'),
                      onTap: () => _showContactDialog(context),
                    ),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.help_outline,
                      title: t.translate('settings_help'),
                      subtitle: t.translate('settings_help_desc'),
                      onTap: () => _showHelpDialog(context),
                    ),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // About Section
                    _buildSectionTitle(context, t.translate('settings_about')),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.info_outline,
                      title: t.translate('settings_about_maktoob'),
                      subtitle: t.translate('settings_version'),
                      onTap: () => _showAboutDialog(context),
                    ),

                    SizedBox(height: context.dynamicHeight(0.119)),
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
            context.dynamicWidth(0.061),
            context.dynamicHeight(0.03),
            context.dynamicWidth(0.061),
            context.dynamicHeight(0.039),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.translate('settings_title'),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.069),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              Text(
                t.translate('settings_subtitle'),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.035),
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
        fontSize: context.dynamicWidth(0.045),
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, SettingsState state) {
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
          _buildLanguageOption(
            context: context,
            title: 'العربية',
            subtitle: 'Arabic',
            isSelected: state.language == AppLanguage.ar,
            onTap: () => context.read<SettingsCubit>().setLanguage(AppLanguage.ar),
          ),
          Divider(color: AppColors.gray100, height: context.dynamicHeight(0.02)),
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
          vertical: context.dynamicHeight(0.015),
          horizontal: context.dynamicWidth(0.021),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple50 : Colors.transparent,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
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
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              ),
              child: Icon(
                Icons.language,
                color: isSelected ? Colors.white : AppColors.gray400,
                size: context.dynamicWidth(0.061),
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
                      fontSize: context.dynamicWidth(0.029),
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: context.dynamicWidth(0.061),
                height: context.dynamicWidth(0.061),
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
        child: Row(
          children: [
            Container(
              width: context.dynamicWidth(0.12),
              height: context.dynamicWidth(0.12),
              decoration: BoxDecoration(
                color: AppColors.purple50,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: context.dynamicWidth(0.061),
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
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.029),
                      color: AppColors.gray500,
                    ),
                  ),
                ],
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
          SizedBox(height: context.dynamicHeight(0.015)),
          _buildContactOption(
            context: context,
            icon: Icons.phone_rounded,
            title: t.translate('settings_phone'),
            value: '+966 XX XXX XXXX',
            onTap: () => _copyToClipboard(context, '+966XXXXXXXX'),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
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
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
          border: Border.all(
            color: AppColors.gray200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: context.dynamicWidth(0.109),
              height: context.dynamicWidth(0.109),
              decoration: BoxDecoration(
                color: AppColors.purple50,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: context.dynamicWidth(0.056),
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.035)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.037),
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: context.dynamicHeight(0.002)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.032),
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: context.dynamicWidth(0.091),
              height: context.dynamicWidth(0.091),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
              ),
              child: Icon(
                Icons.copy_rounded,
                color: AppColors.gray500,
                size: context.dynamicWidth(0.045),
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
          horizontal: context.dynamicWidth(0.061),
          vertical: context.dynamicHeight(0.03),
        ),
        child: Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.061)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.061)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: context.dynamicWidth(0.08),
                offset: Offset(0, context.dynamicHeight(0.02)),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Container(
                width: context.dynamicWidth(0.2),
                height: context.dynamicWidth(0.2),
                decoration: BoxDecoration(
                  color: AppColors.purple50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                      blurRadius: context.dynamicWidth(0.051),
                      offset: Offset(0, context.dynamicHeight(0.01)),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_rounded,
                  size: context.dynamicWidth(0.101),
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.02)),
              // Title
              Text(
                t.translate('settings_about_maktoob'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.056),
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.015)),
              // Description
              Text(
                t.translate('settings_about_text'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.037),
                  color: AppColors.gray600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.01)),
              // Version badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.04),
                  vertical: context.dynamicHeight(0.007),
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
                ),
                child: Text(
                  t.translate('settings_version'),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.032),
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.03)),
              // OK Button
              SizedBox(
                width: double.infinity,
                height: context.dynamicHeight(0.06),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                    ),
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        blurRadius: context.dynamicWidth(0.029),
                        offset: Offset(0, context.dynamicHeight(0.005)),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
                      child: Center(
                        child: Text(
                          t.translate('common_ok'),
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.04),
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
