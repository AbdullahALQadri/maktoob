import 'package:flutter/material.dart';

import '../../../config/locale/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/responsive.dart';

/// Screen shown when the device fails security checks (rooted/jailbroken).
///
/// This is displayed as a standalone screen within its own [MaterialApp]
/// since it runs before the main app's DI and routing are initialized.
class CompromisedDeviceScreen extends StatelessWidget {
  const CompromisedDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.08),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shield icon with error background
                Container(
                  width: context.dynamicWidth(0.2),
                  height: context.dynamicWidth(0.2),
                  decoration: BoxDecoration(
                    color: AppColors.red100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: context.dynamicWidth(0.1),
                    color: AppColors.red500,
                  ),
                ),
                AppSpacing.verticalSpace32,

                // Title
                Text(
                  t?.translate('security_warning_title') ?? 'Security Warning',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpace16,

                // Main message
                Text(
                  t?.translate('security_warning_message') ??
                      'This app cannot run on rooted or jailbroken devices for security reasons.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpace12,

                // Subtitle / instruction
                Text(
                  t?.translate('security_warning_subtitle') ??
                      'Please use an unmodified device to access Maktoob.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
