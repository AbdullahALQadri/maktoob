import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';

/// Profile header with gradient background and user info.
class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final bool isArabic;
  final VoidCallback? onBack;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isArabic,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppBar(title: t.translate('profile_title'), onBack: onBack),
            _UserInfo(user: user, isArabic: isArabic, t: t),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const _AppBar({required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.051),
        vertical: context.dynamicHeight(0.015),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.051),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final UserEntity user;
  final bool isArabic;
  final AppLocalizations t;

  const _UserInfo({
    required this.user,
    required this.isArabic,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.dynamicWidth(0.061),
        context.dynamicHeight(0.02),
        context.dynamicWidth(0.061),
        context.dynamicHeight(0.039),
      ),
      child: Column(
        children: [
          Text(
            user.name,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.061),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.dynamicHeight(0.005)),
          Text(
            user.email,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.035),
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          _UserTypeBadge(user: user, isArabic: isArabic),
          if (user.isVerified) ...[
            SizedBox(height: context.dynamicHeight(0.01)),
            _VerifiedBadge(label: t.translate('profile_verified')),
          ],
        ],
      ),
    );
  }
}

class _UserTypeBadge extends StatelessWidget {
  final UserEntity user;
  final bool isArabic;

  const _UserTypeBadge({required this.user, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.007),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            user.isInstitution ? Icons.business : Icons.person,
            color: Colors.white,
            size: context.dynamicWidth(0.04),
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Text(
            isArabic ? user.userType.displayNameAr : user.userType.displayName,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.032),
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final String label;

  const _VerifiedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified,
          color: Colors.white,
          size: context.dynamicWidth(0.04),
        ),
        SizedBox(width: context.dynamicWidth(0.011)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.029),
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
