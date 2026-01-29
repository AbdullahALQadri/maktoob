import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// Guest list section showing all added guests or empty state.
class GuestListSection extends StatelessWidget {
  final InvitationState state;

  const GuestListSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final allGuests = state.allGuests;

    if (allGuests.isEmpty) {
      return _EmptyGuestList(l: l);
    }

    return _PopulatedGuestList(guests: allGuests, l: l);
  }
}

class _EmptyGuestList extends StatelessWidget {
  final AppLocalizations? l;

  const _EmptyGuestList({this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.101)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_disabled,
            size: context.dynamicWidth(0.16),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            l?.translate('invitation_no_guests_yet') ?? 'No guests added yet',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            l?.translate('invitation_use_options_above') ??
                'Use the options above to add guests',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.032),
              color: context.iconSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopulatedGuestList extends StatelessWidget {
  final List<GuestInfoModel> guests;
  final AppLocalizations? l;

  const _PopulatedGuestList({required this.guests, this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuestListHeader(guestCount: guests.length, l: l),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guests.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _GuestListItem(guest: guests[index], l: l),
          ),
        ],
      ),
    );
  }
}

class _GuestListHeader extends StatelessWidget {
  final int guestCount;
  final AppLocalizations? l;

  const _GuestListHeader({required this.guestCount, this.l});

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
              color: Colors.black,
            ),
          ),
          if (guestCount > 1)
            TextButton.icon(
              onPressed: () => _showClearAllDialog(context),
              icon: Icon(Icons.delete_sweep, size: context.dynamicWidth(0.045)),
              label: Text(l?.translate('invitation_clear_all') ?? 'Clear All'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l?.translate('invitation_clear_all') ?? 'Clear All'),
          ),
        ],
      ),
    );
  }
}

class _GuestListItem extends StatelessWidget {
  final GuestInfoModel guest;
  final AppLocalizations? l;

  const _GuestListItem({required this.guest, this.l});

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
          color: Colors.black,
        ),
      ),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              guest.phone,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                color: Colors.grey.shade600,
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
        color: Colors.red.shade400,
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
          Colors.blue,
          l?.translate('invitation_contacts') ?? 'Contacts'
        );
      case GuestSource.excel:
        return (
          Icons.table_chart,
          Colors.green,
          l?.translate('invitation_excel') ?? 'Excel'
        );
      case GuestSource.manual:
        return (
          Icons.edit,
          Colors.orange,
          l?.translate('invitation_manual') ?? 'Manual'
        );
    }
  }
}
