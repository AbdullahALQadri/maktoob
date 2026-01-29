import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/guest_model.dart';
import '../../domain/entities/guest_entity.dart';

/// Guest card with avatar, status and details.
class GuestCard extends StatelessWidget {
  final GuestEntity guest;

  const GuestCard({super.key, required this.guest});

  Color get _avatarColor {
    if (guest is GuestModel) return (guest as GuestModel).avatarColor;
    return AppColors.purple500;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(name: guest.name, color: _avatarColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guest.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    _StatusBadge(status: guest.status),
                  ],
                ),
              ),
              if (guest.status == GuestStatus.attending)
                _CheckInBadge(isCheckedIn: guest.isCheckedIn, t: t),
            ],
          ),
          const SizedBox(height: 12),
          _GuestInfoSection(guest: guest, t: t),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;

  const _Avatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name.substring(0, 1).toUpperCase(),
          style: AppTextStyles.titleLarge.white,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final GuestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (bgColor, textColor, label) = switch (status) {
      GuestStatus.attending => (
          AppColors.green100,
          AppColors.green600,
          t.translate('event_details_attending')
        ),
      GuestStatus.declined => (
          AppColors.red100,
          AppColors.red500,
          t.translate('event_details_declined')
        ),
      GuestStatus.pending => (
          AppColors.amber100,
          AppColors.amber600,
          t.translate('event_details_pending')
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _CheckInBadge extends StatelessWidget {
  final bool isCheckedIn;
  final AppLocalizations t;

  const _CheckInBadge({required this.isCheckedIn, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCheckedIn ? AppColors.green100 : context.overlayBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCheckedIn ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isCheckedIn ? AppColors.green600 : context.iconDefault,
          ),
          const SizedBox(width: 4),
          Text(
            isCheckedIn
                ? t.translate('event_details_checked_in')
                : t.translate('event_details_not_checked_in'),
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: isCheckedIn ? AppColors.green600 : context.iconSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestInfoSection extends StatelessWidget {
  final GuestEntity guest;
  final AppLocalizations t;

  const _GuestInfoSection({required this.guest, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.overlayBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.email_outlined, text: guest.email),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.phone_outlined, text: guest.phone),
          if (guest.companions > 0) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.people_outline,
              text: '${guest.companions} ${guest.companions > 1 ? t.translate('event_details_companions') : t.translate('event_details_companion')}',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.iconSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
      ],
    );
  }
}
