import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';

/// Custom event type constant used for dropdown matching.
const _customEventType = EventTypeModel(
  id: null,
  name: 'Custom',
  nameAr: 'مخصص',
  emoji: '➕',
);

/// Dropdown widget for selecting event type.
class EventTypeDropdown extends StatelessWidget {
  final InvitationState state;

  const EventTypeDropdown({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = _buildDropdownItems(context, l);
    final dropdownValue = _getDropdownValue();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.005),
      ),
      constraints: BoxConstraints(
        minHeight: context.dynamicHeight(0.065),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border: Border.all(color: AppColors.gray300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EventTypeModel>(
          value: dropdownValue,
          hint: Text(
            l?.translate('invitation_select_event_type') ?? 'Select event type',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: context.dynamicWidth(0.04),
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: AppColors.gray500, size: context.dynamicWidth(0.061)),
          iconSize: context.dynamicWidth(0.061),
          itemHeight: math.max(56.0, context.dynamicHeight(0.08)),
          menuMaxHeight: math.max(300.0, context.dynamicHeight(0.5)),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          dropdownColor: Colors.white,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            color: AppColors.gray700,
          ),
          items: items,
          onChanged: (eventType) => _onEventTypeChanged(context, eventType),
        ),
      ),
    );
  }

  List<DropdownMenuItem<EventTypeModel>> _buildDropdownItems(
    BuildContext context,
    AppLocalizations? l,
  ) {
    final List<DropdownMenuItem<EventTypeModel>> items = [];
    final isEnglish = l?.isEnLocale ?? false;

    // Add custom option first
    items.add(_buildDropdownItem(
      context,
      eventType: _customEventType,
      displayName: l?.translate('invitation_custom') ?? 'Custom',
      emoji: '➕',
    ));

    // Add other event types
    for (final eventType in state.availableEventTypes) {
      items.add(_buildDropdownItem(
        context,
        eventType: eventType,
        displayName: isEnglish ? eventType.name : eventType.nameAr,
        emoji: eventType.emoji ?? '📅',
      ));
    }

    return items;
  }

  DropdownMenuItem<EventTypeModel> _buildDropdownItem(
    BuildContext context, {
    required EventTypeModel eventType,
    required String displayName,
    required String emoji,
  }) {
    return DropdownMenuItem<EventTypeModel>(
      value: eventType,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: context.dynamicWidth(0.061)),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.045),
                color: AppColors.gray700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  EventTypeModel? _getDropdownValue() {
    if (state.selectedEventType == null) return null;

    if (state.selectedEventType!.isCustom) {
      return _customEventType;
    }

    return state.availableEventTypes.firstWhere(
      (e) => e.id == state.selectedEventType!.id,
      orElse: () => state.selectedEventType!,
    );
  }

  void _onEventTypeChanged(BuildContext context, EventTypeModel? eventType) {
    if (eventType == null) return;

    context.read<InvitationCubit>().selectEventType(eventType);

    if (!eventType.isCustom) {
      context.read<InvitationCubit>().loadTemplatesForEventType(eventType.id!);
    }
  }
}
