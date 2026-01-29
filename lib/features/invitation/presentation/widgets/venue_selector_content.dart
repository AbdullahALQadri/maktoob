import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// Venue selector bottom sheet content.
class VenueSelectorContent extends StatelessWidget {
  final List<VenueModel> venues;

  const VenueSelectorContent({super.key, required this.venues});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (venues.isEmpty) {
      return _EmptyVenueState(l: l);
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: venues.length,
      itemBuilder: (context, index) => _VenueListItem(venue: venues[index]),
    );
  }
}

class _EmptyVenueState extends StatelessWidget {
  final AppLocalizations? l;

  const _EmptyVenueState({this.l});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.08)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off,
              size: context.dynamicWidth(0.12), color: context.borderColor),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            l?.translate('invitation_no_venues_available') ??
                'No venues available',
            style: TextStyle(
              color: context.iconSecondary,
              fontSize: context.dynamicWidth(0.04),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueListItem extends StatelessWidget {
  final VenueModel venue;

  const _VenueListItem({required this.venue});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.005),
      ),
      leading: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.021)),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        ),
        child: Icon(
          Icons.location_city,
          color: AppColors.primaryColor,
          size: context.dynamicWidth(0.061),
        ),
      ),
      title: Text(
        venue.name,
        style: TextStyle(fontSize: context.dynamicWidth(0.04)),
      ),
      subtitle: venue.address != null
          ? Text(
              venue.address!,
              style: TextStyle(fontSize: context.dynamicWidth(0.032)),
            )
          : null,
      trailing: Icon(Icons.arrow_forward_ios, size: context.dynamicWidth(0.04)),
      onTap: () {
        context.read<InvitationCubit>().selectVenue(venue);
        Navigator.pop(context);
      },
    );
  }
}
