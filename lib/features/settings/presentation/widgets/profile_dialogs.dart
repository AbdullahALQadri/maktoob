import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../cubit/profile_cubit.dart';

/// Profile dialog utilities.
class ProfileDialogs {
  ProfileDialogs._();

  /// Shows user type change dialog.
  static void showChangeUserType(
    BuildContext context, {
    required UserType newType,
    required bool isArabic,
    required UserEntity? currentUser,
  }) {
    if (currentUser?.userType == newType) return;

    final t = AppLocalizations.of(context)!;
    final profileCubit = context.read<ProfileCubit>();
    final bool isConvertingToOrg = newType == UserType.institution;
    final reasonController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (stateContext, setState) {
            final bool canConfirm = reasonController.text.trim().isNotEmpty;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.061),
                vertical: context.dynamicHeight(0.03),
              ),
              child: _ChangeTypeDialogContent(
                isConvertingToOrg: isConvertingToOrg,
                newType: newType,
                isArabic: isArabic,
                reasonController: reasonController,
                canConfirm: canConfirm,
                t: t,
                onChanged: () => setState(() {}),
                onCancel: () => Navigator.pop(dialogContext),
                onConfirm: () {
                  Navigator.pop(dialogContext);
                  profileCubit.changeUserType(
                    newType,
                    reason: reasonController.text.trim(),
                  );
                },
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Shows edit profile dialog.
  static void showEditProfile(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    AppDialog.showInfo(
      context,
      title: t.translate('profile_edit'),
      message: t.translate('profile_edit_coming'),
      buttonText: t.translate('common_ok'),
    );
  }

  /// Shows change password dialog.
  static void showChangePassword(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    AppDialog.showInfo(
      context,
      title: t.translate('profile_change_password'),
      message: t.translate('profile_change_password_coming'),
      buttonText: t.translate('common_ok'),
    );
  }

  /// Shows logout confirmation dialog.
  static Future<void> showLogout(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: t.translate('profile_logout'),
      message: t.translate('profile_logout_confirm'),
      confirmText: t.translate('profile_logout'),
      cancelText: t.translate('common_cancel'),
      type: DialogType.warning,
      icon: Icons.logout_rounded,
    );

    if (confirmed) {
      // TODO: Implement logout
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

    if (confirmed) {
      // TODO: Implement delete account
    }
  }
}

class _ChangeTypeDialogContent extends StatelessWidget {
  final bool isConvertingToOrg;
  final UserType newType;
  final bool isArabic;
  final TextEditingController reasonController;
  final bool canConfirm;
  final AppLocalizations t;
  final VoidCallback onChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ChangeTypeDialogContent({
    required this.isConvertingToOrg,
    required this.newType,
    required this.isArabic,
    required this.reasonController,
    required this.canConfirm,
    required this.t,
    required this.onChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: context.dynamicWidth(0.901)),
      padding: EdgeInsets.all(context.dynamicWidth(0.061)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.061)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: context.dynamicWidth(0.08),
            offset: Offset(0, context.dynamicHeight(0.02)),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogIcon(isConvertingToOrg: isConvertingToOrg),
            SizedBox(height: context.dynamicHeight(0.02)),
            Text(
              t.translate('profile_change_type'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.056),
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.012)),
            _DialogMessage(newType: newType, isArabic: isArabic, t: t),
            SizedBox(height: context.dynamicHeight(0.025)),
            AppTextField(
              controller: reasonController,
              labelText: t.translate('profile_conversion_reason'),
              hintText: t.translate('profile_conversion_reason_hint'),
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
              onChanged: (_) => onChanged(),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            _DialogButtons(
              canConfirm: canConfirm,
              t: t,
              onCancel: onCancel,
              onConfirm: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  final bool isConvertingToOrg;

  const _DialogIcon({required this.isConvertingToOrg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.2),
      height: context.dynamicWidth(0.2),
      decoration: BoxDecoration(
        color: AppColors.purple50,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            blurRadius: context.dynamicWidth(0.051),
            offset: Offset(0, context.dynamicHeight(0.01)),
          ),
        ],
      ),
      child: Icon(
        isConvertingToOrg ? Icons.business_rounded : Icons.person_rounded,
        size: context.dynamicWidth(0.101),
        color: AppColors.primaryColor,
      ),
    );
  }
}

class _DialogMessage extends StatelessWidget {
  final UserType newType;
  final bool isArabic;
  final AppLocalizations t;

  const _DialogMessage({
    required this.newType,
    required this.isArabic,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final typeName =
        isArabic ? newType.displayNameAr : newType.displayName;
    final suffix = isArabic ? '؟' : '?';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.021)),
      child: Text(
        '${t.translate('profile_change_type_confirm')} "$typeName"$suffix',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: context.dynamicWidth(0.037),
          color: AppColors.gray600,
          height: 1.5,
        ),
      ),
    );
  }
}

class _DialogButtons extends StatelessWidget {
  final bool canConfirm;
  final AppLocalizations t;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _DialogButtons({
    required this.canConfirm,
    required this.t,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              height: context.dynamicHeight(0.06),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius:
                    BorderRadius.circular(context.dynamicWidth(0.035)),
              ),
              child: Center(
                child: Text(
                  t.translate('common_cancel'),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.029)),
        Expanded(
          child: GestureDetector(
            onTap: canConfirm ? onConfirm : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: context.dynamicHeight(0.06),
              decoration: BoxDecoration(
                gradient: canConfirm
                    ? LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.tertiaryColor,
                        ],
                      )
                    : null,
                color: canConfirm ? null : AppColors.gray300,
                borderRadius:
                    BorderRadius.circular(context.dynamicWidth(0.035)),
                boxShadow: canConfirm
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: context.dynamicWidth(0.029),
                          offset: Offset(0, context.dynamicHeight(0.005)),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  t.translate('common_confirm'),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.w600,
                    color: canConfirm ? Colors.white : AppColors.gray500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
