import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_state.dart';
import 'guest_list_rows.dart';

/// Guest list section showing all added guests or empty state.
class GuestListSection extends StatelessWidget {
  final InvitationState state;

  const GuestListSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final allGuests = state.guests;

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
        color: context.cardBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_add_disabled,
            size: context.dynamicWidth(0.16),
            color: context.iconDefault,
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            l?.translate('invitation_no_guests_yet') ?? 'No guests added yet',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              color: context.textSecondary,
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
        color: context.cardBg,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.024),
            offset: Offset(0, context.dynamicHeight(0.005)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GuestListHeader(guestCount: guests.length, l: l),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guests.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                GuestListItem(guest: guests[index], l: l),
          ),
        ],
      ),
    );
  }
}
