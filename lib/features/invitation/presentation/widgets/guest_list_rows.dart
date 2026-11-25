import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';

class GuestListHeader extends StatelessWidget {
  final int guestCount;
  final AppLocalizations? l;

  const GuestListHeader({super.key, required this.guestCount, this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${l?.translate('invitation_guest_list') ?? 'Guest List'} ($guestCount)',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          if (guestCount > 1)
            TextButton.icon(
              onPressed: () => _showClearAllDialog(context),
              icon: Icon(Icons.delete_sweep, size: context.dynamicWidth(0.045)),
              label: Text(l?.translate('invitation_clear_all') ?? 'Clear All'),
              style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
            l?.translate('invitation_clear_all_guests') ?? 'Clear All Guests'),
        content: Text(l?.translate('invitation_confirm_clear_all') ??
            'Are you sure you want to remove all guests from the list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l?.translate('common_cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              cubit.clearAllGuests();
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red500),
            child: Text(l?.translate('invitation_clear_all') ?? 'Clear All'),
          ),
        ],
      ),
    );
  }
}


class GuestListItem extends StatelessWidget {
  final GuestInfoModel guest;
  final AppLocalizations? l;

  const GuestListItem({super.key, required this.guest, this.l});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = _getSourceInfo();

    return ListTile(
      leading: CircleAvatar(
        radius: context.dynamicWidth(0.051),
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color, size: context.dynamicWidth(0.051)),
      ),
      title: Text(
        guest.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: context.dynamicWidth(0.037),
          color: context.textPrimary,
        ),
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              guest.phone,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                color: context.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.016),
              vertical: context.dynamicHeight(0.002),
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
            ),
            child: Text(
              label,
              style:
                  TextStyle(fontSize: context.dynamicWidth(0.024), color: color),
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle_outline,
            size: context.dynamicWidth(0.061)),
        color: AppColors.red500,
        onPressed: () {
          context.read<InvitationCubit>().removeGuestByModel(guest);
        },
      ),
    );
  }

  (IconData, Color, String) _getSourceInfo() {
    switch (guest.source) {
      case GuestSource.contacts:
        return (
          Icons.contacts,
          AppColors.blue500,
          l?.translate('invitation_contacts') ?? 'Contacts'
        );
      case GuestSource.excel:
        return (
          Icons.table_chart,
          AppColors.green600,
          l?.translate('invitation_excel') ?? 'Excel'
        );
      case GuestSource.manual:
        return (
          Icons.edit,
          AppColors.orange500,
          l?.translate('invitation_manual') ?? 'Manual'
        );
    }
  }
}
