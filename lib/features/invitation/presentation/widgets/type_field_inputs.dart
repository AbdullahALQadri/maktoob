import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

class TypeFieldLabel extends StatelessWidget {
  final EventTypeFormField field;
  final bool isEnglish;
  const TypeFieldLabel({super.key, required this.field, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
      child: Text.rich(
        TextSpan(
          text: field.localizedLabel(isEnglish),
          children: [
            if (field.isRequired)
              const TextSpan(text: ' *', style: TextStyle(color: AppColors.red500)),
          ],
        ),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray500),
      ),
    );
  }
}

InputDecoration _decoration(String hint) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 13),
    filled: true,
    fillColor: AppColors.surfaceBg,
    isDense: true,
    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 14),
    border: border(AppColors.gray200),
    enabledBorder: border(AppColors.gray200),
    focusedBorder: border(AppColors.primaryColor, 1.5),
  );
}


class TypeFieldText extends StatelessWidget {
  final String initialValue;
  final String hint;
  final bool isMultiline;
  final bool isNumber;
  final ValueChanged<String> onChanged;

  const TypeFieldText({
    super.key,
    required this.initialValue,
    required this.hint,
    required this.isMultiline,
    required this.isNumber,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      minLines: isMultiline ? 3 : 1,
      maxLines: isMultiline ? 5 : 1,
      keyboardType: isNumber
          ? TextInputType.number
          : (isMultiline ? TextInputType.multiline : TextInputType.text),
      style: const TextStyle(fontSize: 14),
      decoration: _decoration(hint),
    );
  }
}


class TypeFieldSelect extends StatelessWidget {
  final EventTypeFormField field;
  final String? value;
  final String hint;
  final bool isEnglish;
  final ValueChanged<String?> onChanged;

  const TypeFieldSelect({
    super.key,
    required this.field,
    required this.value,
    required this.hint,
    required this.isEnglish,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasValue = field.options.any((o) => o.value == value);
    return DropdownButtonFormField<String>(
      initialValue: hasValue ? value : null,
      isExpanded: true,
      dropdownColor: AppColors.white,
      borderRadius: AppSpacing.borderRadiusLg,
      decoration: _decoration(hint.isNotEmpty ? hint : (l?.translate('wizard_select_option') ?? 'اختر')),
      items: [
        for (final o in field.options)
          DropdownMenuItem(
            value: o.value,
            child: Text(isEnglish ? o.labelEn : o.labelAr, style: const TextStyle(fontSize: 14)),
          ),
      ],
      onChanged: onChanged,
    );
  }
}


class TypeFieldOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isCheckbox;
  final VoidCallback onTap;

  const TypeFieldOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isCheckbox
        ? (selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
        : (selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded);
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.primaryColor : AppColors.gray400),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: context.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}
