import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../core/widgets/page/page_kit.dart';
import '../../../../injection_container.dart' as di;
import '../../../guest_groups/presentation/screens/guest_groups_screen.dart';
import '../../../institution/presentation/screens/institution_screen.dart';
import '../../../payment/presentation/screens/my_payments_screen.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/widgets.dart';
import 'pending_actions_screen.dart';
import 'profile_screen.dart';

/// "My account": who is signed in, then everything about the account in
/// flat cards. One column on a phone; account beside help on wide windows.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/r/profile'),
        builder: (page) => BlocProvider(
          create: (_) => di.sl<ProfileCubit>(),
          child: ProfileScreen(onBack: () => Navigator.of(page).pop()),
        ),
      ),
    );
  }

  void _contact(BuildContext context) {
    AppBottomSheet.show(
      context,
      title: context.tr('settings_contact'),
      subtitle: context.tr('settings_contact_subtitle'),
      icon: Icons.contact_support_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: context.primaryWash,
      child: SettingsContactOptions(t: AppLocalizations.of(context)!),
    );
  }

  void _info(BuildContext context, String titleKey, String messageKey) {
    AppDialog.showInfo(
      context,
      title: context.tr(titleKey),
      message: context.tr(messageKey),
      buttonText: context.tr('common_ok'),
    );
  }

  @override
  Widget build(BuildContext context) {
    void push(Route<void> route) => Navigator.of(context).push(route);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: PageBody(
          bottom: 96,
          side: [
            const LanguageCard(),
            PageCard.rows(
              title: context.tr('settings_support'),
              rows: [
                PageRow(
                  icon: Icons.email_outlined,
                  title: context.tr('settings_contact'),
                  subtitle: context.tr('settings_contact_desc'),
                  onTap: () => _contact(context),
                ),
                PageRow(
                  icon: Icons.help_outline,
                  title: context.tr('settings_help'),
                  subtitle: context.tr('settings_help_desc'),
                  onTap: () => _info(context, 'settings_help', 'settings_help_contact'),
                ),
              ],
            ),
            PageCard.rows(
              title: context.tr('settings_about'),
              rows: [
                PageRow(
                  icon: Icons.privacy_tip_outlined,
                  title: context.tr('legal_privacy'),
                  subtitle: context.tr('settings_privacy_desc'),
                  onTap: () => LegalLinks.open(LegalLinks.privacyPolicy),
                ),
                PageRow(
                  icon: Icons.description_outlined,
                  title: context.tr('legal_terms'),
                  subtitle: context.tr('settings_terms_desc'),
                  onTap: () => LegalLinks.open(LegalLinks.termsOfService),
                ),
                PageRow(
                  icon: Icons.info_outline,
                  title: context.tr('settings_about_maktoob'),
                  subtitle: context.tr('settings_version'),
                  onTap: () => _info(context, 'settings_about_maktoob', 'settings_about_text'),
                ),
              ],
            ),
          ],
          children: [
            PageHeading(title: context.tr('nav_account'), subtitle: context.tr('account_subtitle')),
            AccountSummaryCard(onTap: () => _openProfile(context)),
            PageCard.rows(
              title: context.tr('settings_account'),
              rows: [
                PageRow(
                  icon: Icons.person_outline,
                  title: context.tr('settings_profile'),
                  subtitle: context.tr('settings_profile_desc'),
                  onTap: () => _openProfile(context),
                ),
                PageRow(
                  key: const Key('settings_my_payments_tile'),
                  icon: Icons.receipt_long_outlined,
                  title: context.tr('my_payments_title'),
                  subtitle: context.tr('my_payments_desc'),
                  onTap: () => push(MyPaymentsScreen.route()),
                ),
                PageRow(
                  key: const Key('settings_guest_groups_tile'),
                  icon: Icons.groups_outlined,
                  title: context.tr('groups_title'),
                  subtitle: context.tr('groups_desc'),
                  onTap: () => push(GuestGroupsScreen.route()),
                ),
                PageRow(
                  key: const Key('settings_institution_tile'),
                  icon: Icons.business_outlined,
                  title: context.tr('institution_title'),
                  subtitle: context.tr('institution_settings_desc'),
                  onTap: () => push(InstitutionScreen.route()),
                ),
                PageRow(
                  key: const Key('settings_offline_queue_tile'),
                  icon: Icons.cloud_upload_outlined,
                  title: context.tr('offline_queue_title'),
                  subtitle: context.tr('settings_offline_queue_desc'),
                  onTap: () => push(PendingActionsScreen.route()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
