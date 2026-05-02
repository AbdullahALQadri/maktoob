import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../data/models/ai_form_field_model.dart';

/// Renders dynamic AI form fields returned by /ai-form-fields/{eventTypeId}.
class AiFormFieldsWidget extends StatelessWidget {
  final List<AiFormFieldModel> fields;
  final Map<String, String> values;
  final ValueChanged<MapEntry<String, String>> onChanged;

  const AiFormFieldsWidget({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) return const SizedBox.shrink();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildField(context, f, isAr),
              ))
          .toList(),
    );
  }

  Widget _buildField(BuildContext context, AiFormFieldModel field, bool isAr) {
    final label       = isAr ? field.labelAr       : field.labelEn;
    final placeholder = isAr ? field.placeholderAr : field.placeholderEn;
    // Use labelAr as the storage key so the backend receives Arabic keys directly
    final storageKey  = field.labelAr.isNotEmpty ? field.labelAr : field.fieldKey;
    final current     = values[storageKey] ?? '';

    switch (field.fieldType) {
      case 'select':
        return _SelectField(
          label:       label,
          options:     field.options ?? [],
          value:       current.isEmpty ? null : current,
          onChanged:   (v) => onChanged(MapEntry(storageKey, v ?? '')),
        );
      case 'date':
        return _DateField(
          label:   label,
          value:   current,
          onPick:  (v) => onChanged(MapEntry(storageKey, v)),
        );
      case 'textarea':
        return _TextField(
          label:       label,
          placeholder: placeholder,
          value:       current,
          maxLines:    4,
          onChanged:   (v) => onChanged(MapEntry(storageKey, v)),
        );
      default: // text, time
        return _TextField(
          label:       label,
          placeholder: placeholder,
          value:       current,
          maxLines:    1,
          onChanged:   (v) => onChanged(MapEntry(storageKey, v)),
        );
    }
  }
}

class _TextField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final String value;
  final int maxLines;
  final ValueChanged<String> onChanged;
  const _TextField({
    required this.label, this.placeholder, required this.value,
    required this.maxLines, required this.onChanged,
  });

  @override
  State<_TextField> createState() => _TextFieldState();
}
class _TextFieldState extends State<_TextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextField old) {
    super.didUpdateWidget(old);
    // Sync controller when parent clears form (e.g. tab switch)
    if (old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _ctrl,
    maxLines:   widget.maxLines,
    onChanged:  widget.onChanged,
    decoration: InputDecoration(
      labelText:   widget.label,
      hintText:    widget.placeholder,
      border:      const OutlineInputBorder(),
      isDense:     true,
    ),
  );
}

class _SelectField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _SelectField({required this.label, required this.options, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
    items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
    onChanged: onChanged,
  );
}

class _DateField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onPick;
  const _DateField({required this.label, required this.value, required this.onPick});

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_DateField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: _ctrl,
    readOnly: true,
    decoration: InputDecoration(
      labelText: widget.label,
      border: const OutlineInputBorder(),
      isDense: true,
      suffixIcon: const Icon(Icons.calendar_today_outlined),
    ),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (picked != null) {
        final formatted =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _ctrl.text = formatted;
        widget.onPick(formatted);
      }
    },
  );
}
