import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import 'template_selector_widget.dart';

/// Template selection section for invitation creation.
class InvitationTemplateSection extends StatelessWidget {
  final String? selectedTemplateId;
  final ValueChanged<String> onTemplateSelected;

  const InvitationTemplateSection({
    super.key,
    this.selectedTemplateId,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Template',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        TemplateSelectorWidget(
          selectedTemplateId: selectedTemplateId,
          onTemplateSelected: onTemplateSelected,
        ),
      ],
    );
  }
}
