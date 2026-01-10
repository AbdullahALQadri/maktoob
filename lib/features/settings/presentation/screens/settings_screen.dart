import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isArabic = state.language == AppLanguage.ar;

        return Scaffold(
          backgroundColor: AppColors.gray100,
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(context, isArabic),
              ),
              // Content
              SliverPadding(
                padding: EdgeInsets.all(context.dynamicWidth(0.05)),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Language Section
                    _buildSectionTitle(context, isArabic ? 'اللغة' : 'Language'),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildLanguageCard(context, state, isArabic),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // Profile Section
                    _buildSectionTitle(context, isArabic ? 'الحساب' : 'Account'),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.person_outline,
                      title: isArabic ? 'الملف الشخصي' : 'Profile',
                      subtitle: isArabic ? 'إدارة معلوماتك الشخصية' : 'Manage your personal information',
                      onTap: () => _showProfileDialog(context, isArabic),
                    ),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // Support Section
                    _buildSectionTitle(context, isArabic ? 'الدعم' : 'Support'),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.email_outlined,
                      title: isArabic ? 'تواصل معنا' : 'Contact Us',
                      subtitle: isArabic ? 'تواصل مع فريق الدعم' : 'Get in touch with support team',
                      onTap: () => _showContactDialog(context, isArabic),
                    ),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.help_outline,
                      title: isArabic ? 'المساعدة' : 'Help',
                      subtitle: isArabic ? 'الأسئلة الشائعة والدعم' : 'FAQ and support',
                      onTap: () => _showHelpDialog(context, isArabic),
                    ),

                    SizedBox(height: context.dynamicHeight(0.03)),

                    // About Section
                    _buildSectionTitle(context, isArabic ? 'حول التطبيق' : 'About'),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    _buildSettingsCard(
                      context: context,
                      icon: Icons.info_outline,
                      title: isArabic ? 'عن مكتوب' : 'About Maktoob',
                      subtitle: isArabic ? 'الإصدار 1.0.0' : 'Version 1.0.0',
                      onTap: () => _showAboutDialog(context, isArabic),
                    ),

                    SizedBox(height: context.dynamicHeight(0.05)),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple600,
            AppColors.pink600,
            AppColors.rose600,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.dynamicWidth(0.06),
            context.dynamicHeight(0.03),
            context.dynamicWidth(0.06),
            context.dynamicHeight(0.04),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'الإعدادات' : 'Settings',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.07),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              Text(
                isArabic ? 'تخصيص تجربتك' : 'Customize your experience',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.035),
                  color: Colors.white.withOpacity(0.8),
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

  Widget _buildLanguageCard(BuildContext context, SettingsState state, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                        colors: [AppColors.purple600, AppColors.pink600],
                      )
                    : null,
                color: isSelected ? null : AppColors.gray100,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
              ),
              child: Icon(
                Icons.language,
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
                      color: isSelected ? AppColors.purple600 : AppColors.gray900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.03),
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
                    colors: [AppColors.purple600, AppColors.pink600],
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
              color: Colors.black.withOpacity(0.05),
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
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
              ),
              child: Icon(
                icon,
                color: AppColors.purple600,
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
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.03),
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

  void _showProfileDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'الملف الشخصي' : 'Profile'),
        content: Text(isArabic
            ? 'ميزة الملف الشخصي قيد التطوير'
            : 'Profile feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.dynamicWidth(0.06)),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.06)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.dynamicWidth(0.1),
              height: context.dynamicHeight(0.005),
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.01)),
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            Text(
              isArabic ? 'تواصل معنا' : 'Contact Us',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.05),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            _buildContactOption(
              context: context,
              icon: Icons.email,
              title: isArabic ? 'البريد الإلكتروني' : 'Email',
              value: 'support@maktoob.app',
              onTap: () => _copyToClipboard(context, 'support@maktoob.app', isArabic),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            _buildContactOption(
              context: context,
              icon: Icons.phone,
              title: isArabic ? 'الهاتف' : 'Phone',
              value: '+966 XX XXX XXXX',
              onTap: () => _copyToClipboard(context, '+966XXXXXXXX', isArabic),
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            _buildContactOption(
              context: context,
              icon: Icons.chat,
              title: isArabic ? 'واتساب' : 'WhatsApp',
              value: '+966 XX XXX XXXX',
              onTap: () => _copyToClipboard(context, '+966XXXXXXXX', isArabic),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
          ],
        ),
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
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.purple600, size: context.dynamicWidth(0.06)),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.035),
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.03),
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.copy,
              color: AppColors.gray400,
              size: context.dynamicWidth(0.04),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, bool isArabic) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? 'تم النسخ إلى الحافظة' : 'Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'المساعدة' : 'Help'),
        content: Text(isArabic
            ? 'للمساعدة، يرجى التواصل معنا عبر البريد الإلكتروني أو الهاتف'
            : 'For help, please contact us via email or phone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'عن مكتوب' : 'About Maktoob'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'مكتوب - تطبيق إدارة الفعاليات والدعوات'
                  : 'Maktoob - Event & Invitation Management App',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                color: AppColors.gray700,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.015)),
            Text(
              isArabic ? 'الإصدار: 1.0.0' : 'Version: 1.0.0',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.03),
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}
