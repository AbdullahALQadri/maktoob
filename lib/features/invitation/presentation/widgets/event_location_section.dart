import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import 'google_maps_picker_widget.dart';
import 'venue_selector_content.dart';

/// Location section for event details with venue selection and map picker.
class EventLocationSection extends StatelessWidget {
  final InvitationState state;

  const EventLocationSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      children: [
        if (state.selectedVenue != null || state.customLocation != null)
          _SelectedLocationCard(state: state),
        if (state.selectedVenue == null && state.customLocation == null) ...[
          _LocationOption(
            icon: Icons.location_city,
            title: l?.translate('invitation_select_from_venues') ??
                'Select from Venues',
            subtitle: l?.translate('invitation_choose_available_venues') ??
                'Choose from available venues',
            onTap: () => _showVenueSelector(context),
          ),
          SizedBox(height: context.dynamicHeight(0.015)),
          _LocationOption(
            icon: Icons.map_outlined,
            title: l?.translate('invitation_choose_on_map') ?? 'Choose on Map',
            subtitle:
                l?.translate('invitation_gaza_area_only') ?? 'Gaza area only',
            onTap: () => _showGoogleMapsPicker(context),
          ),
        ],
      ],
    );
  }

  void _showVenueSelector(BuildContext context) {
    final l = AppLocalizations.of(context);
    AppBottomSheet.show(
      context,
      title: l?.translate('invitation_select_venue') ?? 'Select Venue',
      child: VenueSelectorContent(venues: state.availableVenues),
    );
  }

  void _showGoogleMapsPicker(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: cubit,
          child: GoogleMapsPickerWidget(
            initialLocation: cubit.state.customLocation,
            onLocationSelected: (location) {
              cubit.setCustomLocation(location);
              Navigator.pop(routeContext);
            },
          ),
        ),
      ),
    );
  }
}

class _SelectedLocationCard extends StatelessWidget {
  final InvitationState state;

  const _SelectedLocationCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isVenue = state.selectedVenue != null;
    final title = isVenue
        ? state.selectedVenue!.name
        : (state.customLocation?.placeName ??
            l?.translate('invitation_custom_location') ??
            'Custom Location');
    final subtitle =
        isVenue ? state.selectedVenue!.address : state.customLocation?.address;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border:
            Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.024)),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
            ),
            child: Icon(
              isVenue ? Icons.location_city : Icons.location_on,
              color: AppColors.primaryColor,
              size: context.dynamicWidth(0.061),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.029)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.037),
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.032),
                      color: context.iconSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (isVenue) {
                context.read<InvitationCubit>().clearVenue();
              } else {
                context.read<InvitationCubit>().clearLocation();
              }
            },
            icon: Icon(Icons.close, color: context.iconDefault),
          ),
        ],
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LocationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.04)),
        decoration: BoxDecoration(
          color: context.themeSurface,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.024)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
              ),
              child: Icon(icon,
                  color: AppColors.primaryColor,
                  size: context.dynamicWidth(0.061)),
            ),
            SizedBox(width: context.dynamicWidth(0.029)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.037),
                      fontWeight: FontWeight.w500,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.032),
                      color: context.iconSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: context.iconDefault, size: context.dynamicWidth(0.04)),
          ],
        ),
      ),
    );
  }
}
