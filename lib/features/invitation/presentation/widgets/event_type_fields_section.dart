import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';
import 'type_field_inputs.dart';
import 'type_field_picker.dart';

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
            TypeFieldLabel(field: f, isEnglish: isEnglish),
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
          return TypeFieldSelect(key: key, field: f, value: value?.toString(), hint: hint, isEnglish: isEnglish, onChanged: (v) => onChanged(f.key, v));
        }
        break;
      case 'radio':
        if (f.options.isNotEmpty) {
          return Column(
            key: key,
            children: [
              for (final o in f.options)
                TypeFieldOption(
                  label: isEnglish ? o.labelEn : o.labelAr,
                  selected: value?.toString() == o.value,
                  onTap: () => onChanged(f.key, o.value),
                ),
            ],
          );
        }
        break;
      case 'checkbox':
        return TypeFieldOption(
          key: key,
          label: hint.isNotEmpty ? hint : f.localizedLabel(isEnglish),
          selected: value == true,
          isCheckbox: true,
          onTap: () => onChanged(f.key, !(value == true)),
        );
      case 'date':
      case 'time':
        return TypeFieldPicker(key: key, field: f, value: value?.toString(), hint: hint, onChanged: (v) => onChanged(f.key, v));
    }
    return TypeFieldText(
      key: key,
      initialValue: value?.toString() ?? '',
      hint: hint,
      isMultiline: f.type == 'textarea',
      isNumber: f.type == 'number',
      onChanged: (v) => onChanged(f.key, v),
    );
  }
}
