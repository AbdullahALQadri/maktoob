import 'package:equatable/equatable.dart';

class AiFormFieldModel extends Equatable {
  final String fieldKey;
  final String labelAr;
  final String labelEn;
  final String? placeholderAr;
  final String? placeholderEn;
  final String fieldType; // text | textarea | date | time | select
  final List<String>? options;
  final bool isRequired;

  const AiFormFieldModel({
    required this.fieldKey,
    required this.labelAr,
    required this.labelEn,
    this.placeholderAr,
    this.placeholderEn,
    required this.fieldType,
    this.options,
    required this.isRequired,
  });

  factory AiFormFieldModel.fromJson(Map<String, dynamic> json) {
    List<String>? options;
    if (json['options'] is List) {
      options = (json['options'] as List).map((e) => e.toString()).toList();
    }
    return AiFormFieldModel(
      fieldKey:       (json['field_key'] as String?) ?? '',
      labelAr:        (json['label_ar'] as String?) ?? (json['label'] as String?) ?? '',
      labelEn:        (json['label_en'] as String?) ?? (json['label'] as String?) ?? '',
      placeholderAr:  json['placeholder_ar'] as String?,
      placeholderEn:  json['placeholder_en'] as String?,
      fieldType:      (json['field_type'] as String?) ?? 'text',
      options:        options,
      isRequired:     (json['is_required'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [fieldKey, labelAr, fieldType];
}
