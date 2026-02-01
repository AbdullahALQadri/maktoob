import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../utils/app_colors.dart';
import '../../utils/responsive.dart';

/// A wrapper widget that monitors connectivity and shows an offline banner.
class OfflineWrapper extends StatefulWidget {
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
  State<OfflineWrapper> createState() => _OfflineWrapperState();
}

class _OfflineWrapperState extends State<OfflineWrapper> {
  late StreamSubscription<InternetConnectionStatus> _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnectionChecker.instance.onStatusChange.listen(
      (status) {
        if (mounted) {
          setState(() {
            _isConnected = status == InternetConnectionStatus.connected;
          });
        }
      },
    );
    InternetConnectionChecker.instance.hasConnection.then((connected) {
      if (mounted && _isConnected != connected) {
        setState(() => _isConnected = connected);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected && widget.offlineChild != null) {
      return widget.offlineChild!;
    }

    return Column(
      children: [
        if (!_isConnected && widget.showOfflineBanner)
          _OfflineBanner(),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.red500,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'No internet connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicWidth(0.035),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full screen offline widget for screens that can't work without internet.
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

/// Widget that only shows content when online.
class OnlineOnly extends StatefulWidget {
  final Widget child;
  final Widget? offlineWidget;

  const OnlineOnly({
    super.key,
    required this.child,
    this.offlineWidget,
  });

  @override
  State<OnlineOnly> createState() => _OnlineOnlyState();
}

class _OnlineOnlyState extends State<OnlineOnly> {
  late StreamSubscription<InternetConnectionStatus> _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnectionChecker.instance.onStatusChange.listen(
      (status) {
        if (mounted) {
          setState(() {
            _isConnected = status == InternetConnectionStatus.connected;
          });
        }
      },
    );
    InternetConnectionChecker.instance.hasConnection.then((connected) {
      if (mounted && _isConnected != connected) {
        setState(() => _isConnected = connected);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return widget.offlineWidget ?? const OfflineScreen();
    }
    return widget.child;
  }
}
