import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Error state widget for home screen.
class HomeErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.dynamicWidth(0.16),
              color: AppColors.red500,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              t.translate('home_something_wrong'),
              style: AppTextStyles.headlineSmall,
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: context.iconSecondary),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            PrimaryButton(
              text: t.translate('home_try_again'),
              onPressed: onRetry,
              width: context.dynamicWidth(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
