import 'dart:async';

import 'package:flutter/material.dart';

import '../../../config/locale/l10n_context.dart';
import '../../utils/app_colors.dart';

/// "Resend in 42 s" counting down, then a "Resend code" button. Sending
/// again restarts the count, so codes cannot be requested in a burst.
class ResendCountdown extends StatefulWidget {
  const ResendCountdown({super.key, required this.onResend, this.seconds = 60});

  final VoidCallback onResend;
  final int seconds;

  @override
  State<ResendCountdown> createState() => _ResendCountdownState();
}

class _ResendCountdownState extends State<ResendCountdown> {
  Timer? _timer;
  late int _left;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _left = widget.seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _left--);
      if (_left <= 0) timer.cancel();
    });
  }

  void _resend() {
    widget.onResend();
    setState(_start);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_left <= 0) {
      return TextButton(onPressed: _resend, child: Text(context.tr('auth_resend_code')));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 16, color: context.iconDefault),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            context.tr('auth_resend_in', {'seconds': _left}),
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
        ),
      ],
    );
  }
}
