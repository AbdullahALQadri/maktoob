import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../staff/presentation/screens/staff_gate.dart';

/// The two ways in for people who are not clients: door staff with a door
/// code, and the Maktoob team with its own account.
class LoginStaffLinks extends StatelessWidget {
  const LoginStaffLinks({super.key, this.onDoorStaffTap});

  /// Null hides the door entry.
  final VoidCallback? onDoorStaffTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDoorStaffTap != null)
          TextButton.icon(
            key: const Key('login_door_staff'),
            onPressed: onDoorStaffTap,
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
            label: Text(context.tr('login_door_staff'), style: AppTextStyles.labelLarge.white),
          ),
        TextButton(
          key: const Key('login_staff'),
          onPressed: () => Navigator.of(context, rootNavigator: true).push(StaffGate.route()),
          child: Text(context.tr('staff_entry'), style: AppTextStyles.labelLarge.white),
        ),
      ],
    );
  }
}
