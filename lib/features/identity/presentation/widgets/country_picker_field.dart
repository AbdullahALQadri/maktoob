import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/identity_entities.dart';

/// A form field that opens a searchable country list (ISO 3166 codes, names
/// from the backend in the app language). Shows the code when no list is
/// loaded yet.
class CountryPickerField extends StatelessWidget {
  final String label;
  final String? value;
  final List<CountryOption> countries;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String? helperText;
  final bool enabled;

  const CountryPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.countries,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.enabled = true,
  });

  String _name(String? code) {
    if (code == null || code.isEmpty) return '';
    for (final c in countries) {
      if (c.code == code) return c.name;
    }
    return code;
  }

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (_) => _CountrySheet(countries: countries, selected: value),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled && countries.isNotEmpty ? () => _open(context) : null,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InputDecorator(
        isEmpty: (value ?? '').isEmpty,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperMaxLines: 3,
          errorText: errorText,
          errorMaxLines: 3,
          enabled: enabled,
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
          border: const OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
        ),
        child: Text(
          _name(value),
          style: AppTextStyles.bodyLarge.copyWith(color: context.textPrimary),
        ),
      ),
    );
  }
}

class _CountrySheet extends StatefulWidget {
  final List<CountryOption> countries;
  final String? selected;

  const _CountrySheet({required this.countries, this.selected});

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? widget.countries
        : widget.countries
            .where((c) => c.name.toLowerCase().contains(q) || c.code.toLowerCase() == q)
            .toList();

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: TextField(
                key: const Key('country_search'),
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: t.translate('identity_country_search'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: const OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final c = list[i];
                  final selected = c.code == widget.selected;
                  return ListTile(
                    key: Key('country_${c.code}'),
                    title: Text(c.name),
                    trailing: selected
                        ? const Icon(Icons.check_rounded, color: AppColors.primaryColor)
                        : Text(c.code, style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
                    onTap: () => Navigator.of(context).pop(c.code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
