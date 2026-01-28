import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

/// Invoice event details section.
class InvoiceEventDetails extends StatelessWidget {
  final InvitationState state;
  final bool isEnglish;

  const InvoiceEventDetails({
    super.key,
    required this.state,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l?.translate('invitation_event_details') ?? 'Event Details',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.04),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          _DetailItem(
            label: l?.translate('invitation_event_name_label') ?? 'Event Name',
            value: state.eventName ?? '-',
            icon: Icons.celebration,
          ),
          _DetailItem(
            label: l?.translate('invitation_event_type_label') ?? 'Event Type',
            value: isEnglish
                ? (state.selectedEventType?.name ??
                    state.customEventTypeName ??
                    '-')
                : (state.selectedEventType?.nameAr ??
                    state.customEventTypeName ??
                    '-'),
            icon: Icons.category,
          ),
          _DetailItem(
            label: l?.translate('invitation_template') ?? 'Template',
            value: state.uploadedTemplateFile != null
                ? (l?.translate('invitation_custom_template') ??
                    'Custom Template')
                : (isEnglish
                    ? (state.selectedTemplate?.name ?? '-')
                    : (state.selectedTemplate?.nameAr ?? '-')),
            icon: Icons.photo_library,
          ),
          if (state.eventDate != null)
            _DetailItem(
              label: l?.translate('invitation_event_date') ?? 'Event Date',
              value: _formatDate(state.eventDate!),
              icon: Icons.calendar_today,
            ),
          if (state.selectedVenue != null || state.customLocation != null)
            _DetailItem(
              label: l?.translate('invitation_location_label') ?? 'Location',
              value: isEnglish
                  ? (state.selectedVenue?.name ??
                      state.customLocation?.address ??
                      '-')
                  : (state.selectedVenue?.nameAr ??
                      state.customLocation?.address ??
                      '-'),
              icon: Icons.location_on,
            ),
          _DetailItem(
            label: l?.translate('invitation_guest_count') ?? 'Guest Count',
            value:
                '${state.allGuests.length} ${l?.translate('invitation_guests') ?? 'guests'}',
            icon: Icons.people,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.007)),
      child: Row(
        children: [
          Icon(icon, size: context.dynamicWidth(0.045), color: Colors.grey.shade500),
          SizedBox(width: context.dynamicWidth(0.024)),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.032),
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
