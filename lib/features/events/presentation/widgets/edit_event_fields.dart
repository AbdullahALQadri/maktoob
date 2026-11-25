import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../domain/entities/event_details_info.dart';

/// The fields of the edit-event screen (title, place, date, a switch).

class EditEventTextField extends StatelessWidget {
  const EditEventTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      borderSide: BorderSide(color: color, width: width),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        SizedBox(height: context.dynamicHeight(0.008)),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          focusNode: focusNode,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(fontSize: context.dynamicWidth(0.04)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.035),
              vertical: context.dynamicHeight(0.015),
            ),
            border: border(AppColors.gray200),
            enabledBorder: border(AppColors.gray200),
            focusedBorder: border(AppColors.primaryColor, 1.5),
            errorBorder: border(AppColors.red500),
            focusedErrorBorder: border(AppColors.red500, 1.5),
          ),
        ),
      ],
    );
  }
}

class EditEventDateField extends StatelessWidget {
  const EditEventDateField({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        SizedBox(height: context.dynamicHeight(0.008)),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.035),
              vertical: context.dynamicHeight(0.018),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? '${value.day}/${value.month}/${value.year}' : '—',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: value != null ? context.textPrimary : context.textTertiary,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, size: context.dynamicWidth(0.045), color: context.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EditEventSwitchField extends StatelessWidget {
  const EditEventSwitchField({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.035), vertical: context.dynamicHeight(0.01)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary)),
          ),
          Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primaryColor),
        ],
      ),
    );
  }
}

/// The occasion's own answers (groom, bride, family…). Shown only while the
/// event is unpaid: after that a change goes through the team.
class OccasionAnswersFields extends StatelessWidget {
  const OccasionAnswersFields({super.key, required this.answers, required this.onChanged});

  final List<OccasionAnswer> answers;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final answer in answers) ...[
          EditEventTextField(
            key: ValueKey('answer_${answer.key}'),
            label: answer.label(language),
            initialValue: answer.value,
            textInputAction: TextInputAction.next,
            validator: (v) => (v ?? '').trim().isEmpty ? context.tr('wizard_field_required') : null,
            onChanged: (v) => onChanged(answer.key, v),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, fontWeight: FontWeight.w500),
  );
}
