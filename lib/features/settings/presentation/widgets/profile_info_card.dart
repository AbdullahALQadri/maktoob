import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';

/// Personal information card for profile.
class ProfileInfoCard extends StatelessWidget {
  final UserEntity user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline,
            label: t.translate('profile_name'),
            value: user.name,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.email_outlined,
            label: t.translate('profile_email'),
            value: user.email,
          ),
          if (user.phone != null) ...[
            _Divider(),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: t.translate('profile_phone'),
              value: user.phone!,
            ),
          ],
          if (user.companyName != null) ...[
            _Divider(),
            _InfoRow(
              icon: Icons.business_outlined,
              label: t.translate('profile_organization'),
              value: user.companyName!,
            ),
          ],
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.gray100,
      height: context.dynamicHeight(0.025),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.dynamicWidth(0.101),
          height: context.dynamicWidth(0.101),
          decoration: BoxDecoration(
            color: AppColors.purple50,
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: context.dynamicWidth(0.051),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.029),
                  color: AppColors.gray500,
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.002)),
              Text(
                value,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.037),
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
