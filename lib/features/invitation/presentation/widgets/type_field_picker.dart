import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_state.dart';

class TypeFieldPicker extends StatelessWidget {
  final EventTypeFormField field;
  final String? value;
  final String hint;
  final ValueChanged<String> onChanged;

  const TypeFieldPicker({
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
