import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../core/utils/person_name.dart';
import '../../domain/entities/identity_entities.dart';
import '../../domain/identity_rules.dart';
import 'country_picker_field.dart';
import 'identity_photo_field.dart';

/// Y-m-d, as the backend expects dates.
String identityDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// The identity document form. The name is typed in parts exactly as printed
/// on the document; which parts are required follows the document (a
/// Palestinian ID: the four Arabic parts; a passport: the Latin name).
/// Server field errors ([serverErrors]) show under the matching input.
class IdentityForm extends StatefulWidget {
  final IdentityOptionsEntity options;
  final Map<String, String> serverErrors;
  final bool busy;
  final ValueChanged<IdentitySubmissionInput> onSubmit;

  const IdentityForm({
    super.key,
    required this.options,
    required this.onSubmit,
    this.serverErrors = const {},
    this.busy = false,
  });

  @override
  State<IdentityForm> createState() => _IdentityFormState();
}

class _IdentityFormState extends State<IdentityForm> {
  final _number = TextEditingController();
  final _names = {
    for (final f in [...IdentityRules.arabicFields, ...IdentityRules.latinFields]) f: TextEditingController(),
  };

  String _type = 'national_id';
  String _country = 'PS';
  DateTime? _birthDate;
  DateTime? _expiresOn;
  String? _frontPath;
  String? _backPath;
  bool _declaration = false;

  /// Client-side problems: field → translation key.
  Map<String, String> _errors = const {};

  /// Server messages are shown until the field is edited.
  final Set<String> _editedSinceServer = {};

  @override
  void initState() {
    super.initState();
    final codes = widget.options.countries.map((c) => c.code);
    if (codes.isNotEmpty && !codes.contains(_country)) _country = codes.first;
  }

  @override
  void didUpdateWidget(covariant IdentityForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serverErrors != widget.serverErrors) _editedSinceServer.clear();
  }

  @override
  void dispose() {
    _number.dispose();
    for (final c in _names.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _fourPart => IdentityRules.needsFourPartArabic(_type, _country, widget.options);
  bool get _latinRequired => IdentityRules.needsLatin(_type);
  bool get _checkDigit => IdentityRules.usesCheckDigit(_type, _country, widget.options);

  String? _errorFor(String field, AppLocalizations t) {
    final local = _errors[field];
    if (local != null) return t.translate(local);
    if (_editedSinceServer.contains(field)) return null;
    return widget.serverErrors[field];
  }

  void _touched(String field) {
    if (_errors.containsKey(field) || widget.serverErrors.containsKey(field)) {
      setState(() {
        _errors = Map.of(_errors)..remove(field);
        _editedSinceServer.add(field);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final last = DateTime(now.year - widget.options.minimumAge, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(last.year - 7, last.month, last.day),
      firstDate: DateTime(1900),
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      _touched('birth_date');
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresOn ?? DateTime(now.year + 1, now.month, now.day),
      firstDate: first,
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      setState(() => _expiresOn = picked);
      _touched('document_expires_on');
    }
  }

  void _submit() {
    final names = {for (final e in _names.entries) e.key: PersonName.clean(e.value.text)};
    final errors = IdentityRules.validate(
      documentType: _type,
      country: _country,
      number: _number.text,
      names: names,
      options: widget.options,
    );
    if (_birthDate == null) {
      errors['birth_date'] = 'identity_error_birth_date';
    } else if (!IdentityRules.isAdult(_birthDate!, minimumAge: widget.options.minimumAge)) {
      errors['birth_date'] = 'identity_error_minimum_age';
    }
    if (_frontPath == null) errors['front'] = 'identity_error_front_required';
    if (!_declaration) errors['declaration'] = 'identity_error_declaration';

    setState(() => _errors = errors);
    if (errors.isNotEmpty) {
      AppSnackBar.showError(context, message: AppLocalizations.of(context)!.translate('identity_form_has_errors'));
      return;
    }

    widget.onSubmit(IdentitySubmissionInput(
      documentType: _type,
      documentCountry: _country,
      documentNumber: IdentityRules.normalizeNumber(_number.text),
      documentExpiresOn: _expiresOn == null ? null : identityDate(_expiresOn!),
      firstNameAr: names['first_name_ar']!,
      fatherNameAr: names['father_name_ar']!,
      grandfatherNameAr: names['grandfather_name_ar']!,
      familyNameAr: names['family_name_ar']!,
      givenNamesLatin: names['given_names_latin']!,
      familyNameLatin: names['family_name_latin']!,
      birthDate: identityDate(_birthDate!),
      frontPath: _frontPath!,
      backPath: _backPath,
    ));
  }

  InputDecoration _decoration(String label, {String? helper, String? error, bool required = false}) => InputDecoration(
        labelText: required ? '$label *' : label,
        helperText: helper,
        helperMaxLines: 3,
        errorText: error,
        errorMaxLines: 3,
        border: const OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
      );

  Widget _nameField(String field, String labelKey, AppLocalizations t, {required bool required, bool latin = false}) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.smd),
      child: TextField(
        key: Key('identity_$field'),
        controller: _names[field],
        enabled: !widget.busy,
        textDirection: latin ? TextDirection.ltr : TextDirection.rtl,
        textCapitalization: latin ? TextCapitalization.words : TextCapitalization.none,
        textInputAction: TextInputAction.next,
        onChanged: (_) => _touched(field),
        decoration: _decoration(t.translate(labelKey), error: _errorFor(field, t), required: required),
      ),
    );
  }

  Widget _dateField({
    required Key key,
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    String? error,
    String? helper,
    bool required = false,
    VoidCallback? onClear,
  }) {
    return InkWell(
      key: key,
      onTap: widget.busy ? null : onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InputDecorator(
        isEmpty: value == null,
        decoration: _decoration(label, error: error, helper: helper, required: required).copyWith(
          suffixIcon: value != null && onClear != null
              ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: widget.busy ? null : onClear)
              : const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          value == null ? '' : identityDate(value),
          textDirection: TextDirection.ltr,
          style: AppTextStyles.bodyLarge.copyWith(color: context.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final types = widget.options.documentTypes.isNotEmpty
        ? widget.options.documentTypes
        : [for (final k in kIdentityDocumentTypes) IdentityOptionItem(key: k, label: t.translate('identity_doc_type_$k'))];
    final arabicCore = _fourPart || !_latinRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(t.translate('identity_section_document')),
        DropdownButtonFormField<String>(
          key: const Key('identity_document_type'),
          initialValue: types.any((x) => x.key == _type) ? _type : types.first.key,
          decoration: _decoration(t.translate('identity_document_type'), required: true),
          items: [for (final x in types) DropdownMenuItem(value: x.key, child: Text(x.label))],
          onChanged: widget.busy
              ? null
              : (v) => setState(() {
                    _type = v ?? _type;
                    _errors = const {};
                  }),
        ),
        const SizedBox(height: AppSpacing.smd),
        CountryPickerField(
          key: const Key('identity_document_country'),
          label: '${t.translate('identity_document_country')} *',
          value: _country,
          countries: widget.options.countries,
          enabled: !widget.busy,
          errorText: _errorFor('document_country', t),
          onChanged: (code) {
            setState(() {
              _country = code;
              _errors = const {};
            });
          },
        ),
        const SizedBox(height: AppSpacing.smd),
        TextField(
          key: const Key('identity_document_number'),
          controller: _number,
          enabled: !widget.busy,
          textDirection: TextDirection.ltr,
          keyboardType: _checkDigit ? TextInputType.number : TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => _touched('document_number'),
          decoration: _decoration(
            t.translate('identity_document_number'),
            helper: t.translate(_checkDigit ? 'identity_document_number_hint_id' : 'identity_document_number_hint'),
            error: _errorFor('document_number', t),
            required: true,
          ),
        ),
        const SizedBox(height: AppSpacing.smd),
        _dateField(
          key: const Key('identity_document_expires_on'),
          label: '${t.translate('identity_document_expires_on')} (${t.translate('identity_optional')})',
          value: _expiresOn,
          onTap: _pickExpiry,
          error: _errorFor('document_expires_on', t),
          onClear: () => setState(() => _expiresOn = null),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(t.translate('identity_section_name_ar')),
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.smd),
          child: Text(
            t.translate(_fourPart ? 'identity_name_ar_hint_four_part' : 'identity_name_ar_hint'),
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, height: 1.5),
          ),
        ),
        _nameField('first_name_ar', 'identity_first_name_ar', t, required: arabicCore),
        _nameField('father_name_ar', 'identity_father_name_ar', t, required: _fourPart),
        _nameField('grandfather_name_ar', 'identity_grandfather_name_ar', t, required: _fourPart),
        _nameField('family_name_ar', 'identity_family_name_ar', t, required: arabicCore),
        const SizedBox(height: AppSpacing.sm),
        _Section(t.translate('identity_section_name_latin')),
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.smd),
          child: Text(
            t.translate(_latinRequired ? 'identity_name_latin_hint_passport' : 'identity_name_latin_hint'),
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, height: 1.5),
          ),
        ),
        _nameField('given_names_latin', 'identity_given_names_latin', t, required: _latinRequired, latin: true),
        _nameField('family_name_latin', 'identity_family_name_latin', t, required: _latinRequired, latin: true),
        const SizedBox(height: AppSpacing.sm),
        _dateField(
          key: const Key('identity_birth_date'),
          label: t.translate('identity_birth_date'),
          value: _birthDate,
          onTap: _pickBirthDate,
          required: true,
          error: _errorFor('birth_date', t),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(t.translate('identity_section_photos')),
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.smd),
          child: Text(
            t.translate('identity_photos_hint'),
            style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, height: 1.5),
          ),
        ),
        IdentityPhotoField(
          key: const Key('identity_front'),
          label: t.translate('identity_photo_front'),
          path: _frontPath,
          required: true,
          enabled: !widget.busy,
          maxBytes: widget.options.maxFileKb * 1024,
          errorText: _errorFor('front', t),
          onChanged: (p) {
            setState(() => _frontPath = p);
            _touched('front');
          },
        ),
        const SizedBox(height: AppSpacing.smd),
        IdentityPhotoField(
          key: const Key('identity_back'),
          label: t.translate('identity_photo_back'),
          path: _backPath,
          enabled: !widget.busy,
          maxBytes: widget.options.maxFileKb * 1024,
          errorText: _errorFor('back', t),
          onChanged: (p) {
            setState(() => _backPath = p);
            _touched('back');
          },
        ),
        const SizedBox(height: AppSpacing.md),
        CheckboxListTile(
          key: const Key('identity_declaration'),
          value: _declaration,
          contentPadding: EdgeInsetsDirectional.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: widget.busy
              ? null
              : (v) {
                  setState(() => _declaration = v ?? false);
                  _touched('declaration');
                },
          title: Text(
            t.translate('identity_declaration'),
            style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary, height: 1.5),
          ),
          subtitle: _errorFor('declaration', t) == null
              ? null
              : Text(_errorFor('declaration', t)!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.red500)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          t.translate('identity_privacy_note'),
          style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, height: 1.5),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          key: const Key('identity_submit'),
          text: t.translate('identity_submit'),
          icon: Icons.send_rounded,
          isLoading: widget.busy,
          onPressed: widget.busy ? null : _submit,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String text;

  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
    );
  }
}
