import 'package:equatable/equatable.dart';

import 'json_values.dart';

/// Occasion group (أفراح، مواليد، ...) used by the two-step type picker.
class EventTypeGroupModel extends Equatable {
  final int id;
  final String slug;
  final String nameAr;
  final String nameEn;
  final String? icon;
  final String? color;

  const EventTypeGroupModel({
    required this.id,
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    this.icon,
    this.color,
  });

  factory EventTypeGroupModel.fromJson(Map<String, dynamic> json) {
    final nameAr = asString(json['name_ar']) ?? asString(json['name']) ?? '';
    final nameEn = asString(json['name_en']) ?? nameAr;
    return EventTypeGroupModel(
      id: asInt(json['id']) ?? 0,
      slug: asString(json['slug']) ?? '',
      nameAr: nameAr.isNotEmpty ? nameAr : nameEn,
      nameEn: nameEn,
      icon: asString(json['icon']),
      color: asString(json['color']),
    );
  }

  bool get isOther => slug == 'other';

  @override
  List<Object?> get props => [id, slug, nameAr, nameEn, icon, color];
}

/// One option of a `select` / `radio` form field.
class FormFieldOption extends Equatable {
  final String value;
  final String labelAr;
  final String labelEn;

  const FormFieldOption({
    required this.value,
    required this.labelAr,
    required this.labelEn,
  });

  /// Accepts `{value,label_ar,label_en}`, `{value,label}` or a plain string.
  static FormFieldOption? tryParse(dynamic raw) {
    if (raw is String || raw is num) {
      final v = raw.toString();
      return v.isEmpty ? null : FormFieldOption(value: v, labelAr: v, labelEn: v);
    }
    if (raw is Map) {
      final value = asString(raw['value']) ??
          asString(raw['key']) ??
          asString(raw['label_en']) ??
          asString(raw['label_ar']) ??
          asString(raw['label']);
      if (value == null) return null;
      final ar = asString(raw['label_ar']) ?? asString(raw['label']) ?? value;
      final en = asString(raw['label_en']) ?? asString(raw['label']) ?? ar;
      return FormFieldOption(value: value, labelAr: ar, labelEn: en);
    }
    return null;
  }

  @override
  List<Object?> get props => [value, labelAr, labelEn];
}

/// Form field definition from API
class EventTypeFormField extends Equatable {
  final String key;
  final String label; // English label
  final String labelAr;
  final String type; // text, textarea, number, date, time, select, checkbox, radio
  final bool isRequired;
  final bool required; // Alias for isRequired
  final String? hint; // English placeholder
  final String? hintAr;
  final List<FormFieldOption> options;
  final int sortOrder;

  const EventTypeFormField({
    required this.key,
    required this.label,
    required this.labelAr,
    required this.type,
    bool isRequired = false,
    bool? required,
    this.hint,
    this.hintAr,
    this.options = const [],
    this.sortOrder = 0,
  }) : isRequired = required ?? isRequired,
       required = required ?? isRequired;

  factory EventTypeFormField.fromJson(Map<String, dynamic> json) {
    final key = asString(json['field_key']) ?? asString(json['key']) ?? '';
    final labelAr = asString(json['label_ar']) ?? asString(json['label']) ?? key;
    final labelEn = asString(json['label_en']) ?? asString(json['label']) ?? labelAr;
    final hintAr = asString(json['placeholder_ar']) ??
        asString(json['hint_ar']) ??
        asString(json['placeholder']);
    final hintEn = asString(json['placeholder_en']) ??
        asString(json['hint']) ??
        asString(json['placeholder']);

    var rawOptions = json['options'];
    if (rawOptions is Map) rawOptions = rawOptions.values.toList();
    final options = rawOptions is List
        ? rawOptions.map(FormFieldOption.tryParse).whereType<FormFieldOption>().toList()
        : const <FormFieldOption>[];

    return EventTypeFormField(
      key: key,
      label: labelEn,
      labelAr: labelAr,
      type: asString(json['field_type']) ?? asString(json['type']) ?? 'text',
      isRequired: asBool(json['is_required'] ?? json['required']),
      hint: hintEn,
      hintAr: hintAr,
      options: options,
      sortOrder: asInt(json['sort_order']) ?? 0,
    );
  }

  /// Parses a list of fields, dropping ones without a key, sorted by sort_order.
  static List<EventTypeFormField> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final fields = raw
        .whereType<Map>()
        .map((m) => EventTypeFormField.fromJson(Map<String, dynamic>.from(m)))
        .where((f) => f.key.isNotEmpty)
        .toList();
    fields.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return fields;
  }

  String localizedLabel(bool isEnglish) => isEnglish ? label : labelAr;

  String? localizedHint(bool isEnglish) => isEnglish ? (hint ?? hintAr) : (hintAr ?? hint);

  @override
  List<Object?> get props =>
      [key, label, labelAr, type, isRequired, hint, hintAr, options, sortOrder];
}
