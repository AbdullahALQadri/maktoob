import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

/// Renders the detail fields of the chosen event type (e.g. groom / bride
/// names for a wedding) from the backend definition.
///
/// Values are reported via [onChanged] (field_key → value); the cubit keeps
/// them in `eventTypeFormData`, which is sent as `event_type_form_values`.
class EventTypeFieldsSection extends StatelessWidget {
  final List<EventTypeFormField> fields;
  final Map<String, dynamic> values;
  final bool isLoading;
  final bool showErrors;
  final void Function(String key, dynamic value) onChanged;

  /// Distinguishes field sets of different types so text fields reset.
  final Object? typeKey;

  const EventTypeFieldsSection({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
    this.isLoading = false,
    this.showErrors = false,
    this.typeKey,
  });

  static bool isEmptyValue(EventTypeFormField f, dynamic v) {
    if (v == null) return true;
    if (v is String) return v.trim().isEmpty;
    if (v is bool) return f.type == 'checkbox' && !v;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (isLoading && fields.isEmpty) {
      return const Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: MkSpinner(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        ),
      );
    }
    if (fields.isEmpty) return const SizedBox.shrink();

    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final missing = fields.where((f) => f.isRequired && isEmptyValue(f, values[f.key]));

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l?.translate('wizard_type_details_title') ?? 'تفاصيل المناسبة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          for (final f in fields) ...[
            const SizedBox(height: AppSpacing.smd),
            _FieldLabel(field: f, isEnglish: isEnglish),
            const SizedBox(height: AppSpacing.xs + 2),
            _buildInput(context, f, isEnglish),
            if (showErrors && f.isRequired && isEmptyValue(f, values[f.key]))
              Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs, top: AppSpacing.xs),
                child: Text(
                  l?.translate('wizard_field_required') ?? 'هذا الحقل مطلوب',
                  style: const TextStyle(fontSize: 12, color: AppColors.red500),
                ),
              ),
          ],
          if (showErrors && missing.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.smd),
            Text(
              l?.translate('wizard_required_fields_error') ??
                  'أكمل الحقول المطلوبة المعلّمة بـ * للمتابعة',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.red500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context, EventTypeFormField f, bool isEnglish) {
    final hint = f.localizedHint(isEnglish) ?? '';
    final value = values[f.key];
    final key = ValueKey('${typeKey ?? ''}_${f.key}');

    switch (f.type) {
      case 'select':
        if (f.options.isNotEmpty) {
          return _SelectInput(key: key, field: f, value: value?.toString(), hint: hint, isEnglish: isEnglish, onChanged: (v) => onChanged(f.key, v));
        }
        break;
      case 'radio':
        if (f.options.isNotEmpty) {
          return Column(
            key: key,
            children: [
              for (final o in f.options)
                _OptionRow(
                  label: isEnglish ? o.labelEn : o.labelAr,
                  selected: value?.toString() == o.value,
                  onTap: () => onChanged(f.key, o.value),
                ),
            ],
          );
        }
        break;
      case 'checkbox':
        return _OptionRow(
          key: key,
          label: hint.isNotEmpty ? hint : f.localizedLabel(isEnglish),
          selected: value == true,
          isCheckbox: true,
          onTap: () => onChanged(f.key, !(value == true)),
        );
      case 'date':
      case 'time':
        return _PickerInput(key: key, field: f, value: value?.toString(), hint: hint, onChanged: (v) => onChanged(f.key, v));
    }
    return _TextInput(
      key: key,
      initialValue: value?.toString() ?? '',
      hint: hint,
      isMultiline: f.type == 'textarea',
      isNumber: f.type == 'number',
      onChanged: (v) => onChanged(f.key, v),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final EventTypeFormField field;
  final bool isEnglish;
  const _FieldLabel({required this.field, required this.isEnglish});

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

class _TextInput extends StatelessWidget {
  final String initialValue;
  final String hint;
  final bool isMultiline;
  final bool isNumber;
  final ValueChanged<String> onChanged;

  const _TextInput({
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

class _SelectInput extends StatelessWidget {
  final EventTypeFormField field;
  final String? value;
  final String hint;
  final bool isEnglish;
  final ValueChanged<String?> onChanged;

  const _SelectInput({
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

class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isCheckbox;
  final VoidCallback onTap;

  const _OptionRow({
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

class _PickerInput extends StatelessWidget {
  final EventTypeFormField field;
  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;

  const _PickerInput({
    super.key,
    required this.field,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  bool get _isDate => field.type == 'date';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final filled = value != null && value!.isNotEmpty;
    final placeholder = hint.isNotEmpty
        ? hint
        : (_isDate
            ? (l?.translate('wizard_pick_date') ?? 'اختر التاريخ')
            : (l?.translate('wizard_pick_time') ?? 'اختر الوقت'));
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: AppSpacing.borderRadiusLg,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(_isDate ? Icons.calendar_today_rounded : Icons.schedule_rounded,
                size: 18, color: filled ? AppColors.primaryColor : AppColors.gray500),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                filled ? value! : placeholder,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
                  color: filled ? context.textPrimary : AppColors.gray400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    String two(int n) => n.toString().padLeft(2, '0');
    if (_isDate) {
      final now = DateTime.now();
      final initial = DateTime.tryParse(value ?? '') ?? now;
      final d = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(now.year - 100),
        lastDate: DateTime(now.year + 5),
      );
      if (d != null) onChanged('${d.year}-${two(d.month)}-${two(d.day)}');
    } else {
      final parts = (value ?? '').split(':');
      final initial = parts.length >= 2
          ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 20, minute: int.tryParse(parts[1]) ?? 0)
          : const TimeOfDay(hour: 20, minute: 0);
      final t = await showTimePicker(context: context, initialTime: initial);
      if (t != null) onChanged('${two(t.hour)}:${two(t.minute)}');
    }
  }
}
