import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../core/offline/pending_actions_queue.dart';
import '../../../../injection_container.dart' as di;
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../scanner/data/door_session_manager.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
import '../screens/change_password_screen.dart';
import '../screens/edit_profile_screen.dart';

/// Profile dialog utilities.
class ProfileDialogs {
  ProfileDialogs._();

  /// Navigates to edit profile screen.
  static void showEditProfile(BuildContext context, {required UserEntity user}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileCubit>(),
          child: EditProfileScreen(user: user),
        ),
      ),
    );
  }

  /// Navigates to change password screen with OTP verification.
  static void showChangePassword(BuildContext context, {required String phone}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(phone: phone),
      ),
    );
  }

  /// Shows logout confirmation dialog.
  static Future<void> showLogout(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    // Door check-ins or queued writes not sent yet need this account's
    // sign-in to upload: say so before the logout.
    var waiting = 0;
    try {
      waiting = await di.sl<DoorSessionManager>().pendingEverywhere() + await di.sl<PendingActionsQueue>().count();
    } catch (_) {}
    if (!context.mounted) return;
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: t.translate('profile_logout'),
      message: waiting > 0
          ? t.translate('logout_pending_desc').replaceAll('{count}', '$waiting')
          : t.translate('profile_logout_confirm'),
      confirmText: t.translate('profile_logout'),
      cancelText: t.translate('common_cancel'),
      type: DialogType.warning,
      icon: Icons.logout_rounded,
    );

    if (confirmed && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  /// Shows delete account confirmation dialog.
  static Future<void> showDeleteAccount(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: t.translate('profile_delete'),
      message: t.translate('profile_delete_confirm'),
      confirmText: t.translate('common_delete'),
      cancelText: t.translate('common_cancel'),
      type: DialogType.error,
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed && context.mounted) {
      context.read<AuthCubit>().deleteAccount();
    }
  }
}
