import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Error state widget for events list.
class EventsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const EventsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

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
              size: context.dynamicWidth(0.16),
              color: AppColors.red500,
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              t.translate('home_something_wrong'),
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.08),
                  vertical: context.dynamicHeight(0.015),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
                ),
              ),
              child: Text(
                t.translate('home_try_again'),
                style: TextStyle(fontSize: context.dynamicWidth(0.035)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
