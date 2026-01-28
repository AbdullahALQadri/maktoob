import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';

/// Dynamic name fields builder based on event type.
class DynamicNameFields extends StatelessWidget {
  final GoldenEventType? eventType;
  final List<TextEditingController> controllers;
  final void Function(int index, String value) onNameChanged;

  const DynamicNameFields({
    super.key,
    required this.eventType,
    required this.controllers,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (eventType == null) return const SizedBox.shrink();

    final labels = eventType!.nameFieldLabels;
    final widgets = <Widget>[];

    for (int i = 0; i < labels.length; i++) {
      widgets.add(_NameFieldItem(
        label: labels[i],
        controller: i < controllers.length ? controllers[i] : null,
        onChanged: (value) => onNameChanged(i, value),
      ));
    }

    return Column(children: widgets);
  }
}

class _NameFieldItem extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  const _NameFieldItem({
    required this.label,
    this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        SizedBox(height: context.dynamicWidth(0.021)),
        AppTextField(
          controller: controller,
          hintText: 'Enter ${label.toLowerCase()}',
          prefixIcon: Icons.person_outline,
          onChanged: onChanged,
        ),
        SizedBox(height: context.dynamicWidth(0.04)),
      ],
    );
  }
}
