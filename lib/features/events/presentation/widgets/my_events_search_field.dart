import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';

/// Search the host's events by name, as they type. The screen owns the
/// text, so clearing the filters clears the field too.
class MyEventsSearchField extends StatelessWidget {
  const MyEventsSearchField({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: context.borderColor),
    );
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.tr('my_events_search_hint'),
          prefixIcon: Icon(Icons.search, color: context.iconSecondary),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.tr('common_clear'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: context.cardBg,
          contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 12),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5)),
        ),
      ),
    );
  }
}
