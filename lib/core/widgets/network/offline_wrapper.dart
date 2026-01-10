import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

import '../../utils/app_colors.dart';
import '../../utils/media_query_values.dart';

/// A wrapper widget that handles offline/online states.
/// Shows offline banner when device loses connectivity.
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
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        List<ConnectivityResult> connectivity,
        Widget child,
      ) {
        final bool isConnected = !connectivity.contains(ConnectivityResult.none);

        if (isConnected) {
          return child;
        }

        // Show offline UI
        if (offlineChild != null) {
          return offlineChild!;
        }

        // Default: show child with offline banner
        if (showOfflineBanner) {
          return Column(
            children: [
              _OfflineBanner(),
              Expanded(child: child),
            ],
          );
        }

        return child;
      },
      child: child,
    );
  }
}

/// Offline banner shown at the top of the screen
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.012),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.red500, AppColors.orange500],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.red500.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: context.dynamicWidth(0.05),
            ),
            SizedBox(width: context.dynamicWidth(0.02)),
            Text(
              'No Internet Connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.dynamicWidth(0.035),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: AppColors.gray100,
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
                    color: AppColors.gray200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: context.dynamicWidth(0.2),
                    color: AppColors.gray400,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.04)),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.06),
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.015)),
                Text(
                  message ?? 'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    color: AppColors.gray500,
                    height: 1.5,
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: context.dynamicHeight(0.04)),
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
                            colors: [AppColors.purple600, AppColors.pink600],
                          ),
                          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple600.withOpacity(0.3),
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
                              size: context.dynamicWidth(0.05),
                            ),
                            SizedBox(width: context.dynamicWidth(0.02)),
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
    return OfflineBuilder(
      connectivityBuilder: (
        BuildContext context,
        List<ConnectivityResult> connectivity,
        Widget child,
      ) {
        final bool isConnected = !connectivity.contains(ConnectivityResult.none);

        if (isConnected) {
          return child;
        }

        return offlineWidget ?? const SizedBox.shrink();
      },
      child: child,
    );
  }
}
