import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/profile_cubit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/widgets.dart';
import 'profile_screen.dart';

/// Settings screen with language, profile and support options.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.overlayBg,
          body: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SettingsHeader()),
              SliverPadding(
                padding: EdgeInsets.all(context.dynamicWidth(0.051)),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildSettingsList(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSettingsList(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return [
      // Language Section
      SettingsSectionTitle(title: t.translate('settings_language')),
      SizedBox(height: context.dynamicHeight(0.015)),
      const LanguageCard(),
      SizedBox(height: context.dynamicHeight(0.03)),

      // Profile Section
      SettingsSectionTitle(title: t.translate('settings_account')),
      SizedBox(height: context.dynamicHeight(0.015)),
      SettingsTile(
        icon: Icons.person_outline,
        title: t.translate('settings_profile'),
        subtitle: t.translate('settings_profile_desc'),
        onTap: () => _navigateToProfile(context),
      ),
      SizedBox(height: context.dynamicHeight(0.03)),

      // Support Section
      SettingsSectionTitle(title: t.translate('settings_support')),
      SizedBox(height: context.dynamicHeight(0.015)),
      SettingsTile(
        icon: Icons.email_outlined,
        title: t.translate('settings_contact'),
        subtitle: t.translate('settings_contact_desc'),
        onTap: () => _showContactSheet(context),
      ),
      SizedBox(height: context.dynamicHeight(0.015)),
      SettingsTile(
        icon: Icons.help_outline,
        title: t.translate('settings_help'),
        subtitle: t.translate('settings_help_desc'),
        onTap: () => _showHelpDialog(context),
      ),
      SizedBox(height: context.dynamicHeight(0.03)),

      // About Section
      SettingsSectionTitle(title: t.translate('settings_about')),
      SizedBox(height: context.dynamicHeight(0.015)),
      SettingsTile(
        icon: Icons.info_outline,
        title: t.translate('settings_about_maktoob'),
        subtitle: t.translate('settings_version'),
        onTap: () => _showAboutDialog(context),
      ),
      SizedBox(height: context.dynamicHeight(0.119)),
    ];
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<ProfileCubit>(),
          child: ProfileScreen(onBack: () => Navigator.of(context).pop()),
        ),
      ),
    );
  }

  void _showContactSheet(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    AppBottomSheet.show(
      context,
      title: t.translate('settings_contact'),
      subtitle: t.translate('settings_contact_subtitle'),
      icon: Icons.contact_support_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      child: _ContactOptions(t: t),
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
    AppDialog.showInfo(
      context,
      title: t.translate('settings_about_maktoob'),
      message: t.translate('settings_about_text'),
      buttonText: t.translate('common_ok'),
    );
  }
}

class _ContactOptions extends StatelessWidget {
  final AppLocalizations t;

  const _ContactOptions({required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ContactTile(
          icon: Icons.email_rounded,
          title: t.translate('settings_email'),
          value: 'support@maktoob.app',
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        _ContactTile(
          icon: Icons.phone_rounded,
          title: t.translate('settings_phone'),
          value: '+966 XX XXX XXXX',
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        _ContactTile(
          icon: Icons.chat_rounded,
          title: t.translate('settings_whatsapp'),
          value: '+966 XX XXX XXXX',
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppCard.outlined(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
        AppSnackBar.showSuccess(
          context,
          message: t.translate('common_copied'),
          duration: const Duration(seconds: 2),
        );
      },
      child: Row(
        children: [
          AppIconButton.soft(
            icon: icon,
            onPressed: null,
            iconColor: AppColors.primaryColor,
          ),
          SizedBox(width: context.dynamicWidth(0.035)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMedium),
                Text(value, style: AppTextStyles.caption),
              ],
            ),
          ),
          AppIconButton.soft(
            icon: Icons.copy_rounded,
            onPressed: null,
            iconColor: context.iconSecondary,
            backgroundColor: context.overlayBg,
          ),
        ],
      ),
    );
  }
}
