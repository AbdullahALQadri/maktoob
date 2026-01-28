import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../widgets/widgets.dart';

/// Admin approval waiting screen for institutions.
class AdminApprovalWaitingScreen extends StatelessWidget {
  const AdminApprovalWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.dynamicWidth(0.08)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthScreenIcon(icon: Icons.hourglass_top_rounded),
                SizedBox(height: context.dynamicHeight(0.039)),
                Text(
                  t.translate('auth_pending_approval'),
                  style: AppTextStyles.headlineLarge.white,
                ),
                SizedBox(height: context.dynamicHeight(0.02)),
                Text(
                  isArabic
                      ? 'تم التحقق من رقم هاتفك بنجاح!\n\nحسابك الآن قيد المراجعة من قبل الإدارة.\nسيتم إعلامك عند الموافقة على حسابك.'
                      : 'Your phone number has been verified!\n\nYour account is now under review by the admin.\nYou will be notified once your account is approved.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.06)),
                _NotificationInfoCard(t: t),
                const Spacer(),
                _BackToLoginButton(t: t),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationInfoCard extends StatelessWidget {
  final AppLocalizations t;

  const _NotificationInfoCard({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Colors.white, size: 32),
          SizedBox(height: context.dynamicHeight(0.015)),
          Text(
            t.translate('auth_notification_approval'),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.white,
          ),
        ],
      ),
    );
  }
}

class _BackToLoginButton extends StatelessWidget {
  final AppLocalizations t;

  const _BackToLoginButton({required this.t});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.dynamicHeight(0.065),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          t.translate('auth_back_to_login'),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
