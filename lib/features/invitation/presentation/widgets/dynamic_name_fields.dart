import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';

/// Dynamic name fields builder based on event type.
class DynamicNameFields extends StatelessWidget {
  final GoldenEventType? eventType;
  final List<TextEditingController> controllers;
  final List<FocusNode>? focusNodes;
  final FocusNode? nextFocusNode;
  final void Function(int index, String value) onNameChanged;
  final String? Function(String?)? validator;

  const DynamicNameFields({
    super.key,
    required this.eventType,
    required this.controllers,
    this.focusNodes,
    this.nextFocusNode,
    required this.onNameChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    if (eventType == null) return const SizedBox.shrink();

    final labels = eventType!.nameFieldLabels;
    final widgets = <Widget>[];

    for (int i = 0; i < labels.length; i++) {
      final isLast = i == labels.length - 1;
      widgets.add(_NameFieldItem(
        label: labels[i],
        controller: i < controllers.length ? controllers[i] : null,
        focusNode: focusNodes != null && i < focusNodes!.length
            ? focusNodes![i]
            : null,
        textInputAction: isLast && nextFocusNode == null
            ? TextInputAction.done
            : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (!isLast && focusNodes != null && i + 1 < focusNodes!.length) {
            focusNodes![i + 1].requestFocus();
          } else if (isLast && nextFocusNode != null) {
            nextFocusNode!.requestFocus();
          } else {
            FocusScope.of(context).unfocus();
          }
        },
        onChanged: (value) => onNameChanged(i, value),
        validator: validator,
      ));
    }

    return Column(children: widgets);
  }
}

class _NameFieldItem extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const _NameFieldItem({
    required this.label,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    required this.onChanged,
    this.validator,
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
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: context.dynamicWidth(0.021)),
        AppTextField(
          controller: controller,
          focusNode: focusNode,
          hintText: 'Enter ${label.toLowerCase()}',
          prefixIcon: Icons.person_outline,
          textInputAction: textInputAction,
          onSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          validator: validator,
        ),
        SizedBox(height: context.dynamicWidth(0.04)),
      ],
    );
  }
}
