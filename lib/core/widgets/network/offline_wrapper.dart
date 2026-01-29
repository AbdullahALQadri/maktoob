import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';

/// A wrapper widget that handles offline/online states.
/// Simplified version without flutter_offline dependency.
class OfflineWrapper extends StatelessWidget {
  final Widget child;
  final Widget? offlineChild;
  final bool showOfflineBanner;

  const OfflineWrapper({
    super.key,
    required this.child,
    this.offlineChild,
    this.showOfflineBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    // Simply return the child - offline handling can be added later with proper package setup
    return child;
  }
}

/// Full screen offline widget for screens that can't work without internet
class OfflineScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const OfflineScreen({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.overlayBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.dynamicWidth(0.08)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(context.dynamicWidth(0.08)),
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: context.dynamicWidth(0.2),
                    color: context.iconDefault,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.039)),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.061),
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
                Text(
                  message ?? 'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    color: context.iconSecondary,
                    height: 1.5,
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: context.dynamicHeight(0.039)),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onRetry,
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dynamicWidth(0.08),
                          vertical: context.dynamicHeight(0.018),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                          ),
                          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: context.dynamicWidth(0.051),
                            ),
                            SizedBox(width: context.dynamicWidth(0.021)),
                            Text(
                              'Try Again',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.dynamicWidth(0.04),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that only shows content when online
class OnlineOnly extends StatelessWidget {
  final Widget child;
  final Widget? offlineWidget;

  const OnlineOnly({
    super.key,
    required this.child,
    this.offlineWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Simply return the child - offline handling can be added later
    return child;
  }
}
