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
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(30.w),
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wifi_off_rounded,
                    size: 75.w,
                    color: AppColors.gray400,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 23.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  message ?? 'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.gray500,
                    height: 1.5,
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: 32.h),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onRetry,
                      borderRadius: BorderRadius.circular(15.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.w,
                          vertical: 15.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                          ),
                          borderRadius: BorderRadius.circular(15.w),
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
                              size: 19.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Try Again',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
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
