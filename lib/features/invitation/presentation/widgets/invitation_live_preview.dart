import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import 'invitation_preview_widget.dart';

/// Live preview container for invitation creation.
class InvitationLivePreview extends StatelessWidget {
  final GoldenEventType? eventType;
  final List<String> names;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final String? location;
  final String? templateId;

  const InvitationLivePreview({
    super.key,
    this.eventType,
    this.names = const [],
    this.eventDate,
    this.eventTime,
    this.location,
    this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.dynamicHeight(0.28),
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicWidth(0.021),
      ),
      child: InvitationPreviewWidget(
        eventType: eventType,
        names: names,
        eventDate: eventDate,
        eventTime: eventTime,
        location: location,
        templateId: templateId,
        showMarketingFooter: true,
      ),
    );
  }
}
