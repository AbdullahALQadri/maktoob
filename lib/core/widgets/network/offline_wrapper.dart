import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
  late StreamSubscription<InternetStatus> _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen(
      (status) {
        if (mounted) {
          setState(() {
            _isConnected = status == InternetStatus.connected;
          });
        }
      },
    );
    InternetConnection().hasInternetAccess.then((connected) {
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
