import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../core/utils/person_name.dart';
import '../../domain/entities/identity_entities.dart';
import '../../domain/identity_rules.dart';
import 'country_picker_field.dart';
import 'identity_photo_field.dart';

part 'identity_form_sections.dart';

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

    widget.onSubmit(
      IdentitySubmissionInput(
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
      ),
    );
  }

  InputDecoration _decoration(String label, {String? helper, String? error, bool required = false}) => InputDecoration(
    labelText: required ? '$label *' : label,
    helperText: helper,
    helperMaxLines: 3,
    errorText: error,
    errorMaxLines: 3,
    border: const OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
  );

  /// The sections live in `identity_form_sections.dart`; they change the
  /// form's state through here.
  void _change(VoidCallback change) => setState(change);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final types = widget.options.documentTypes.isNotEmpty
        ? widget.options.documentTypes
        : [
            for (final k in kIdentityDocumentTypes)
              IdentityOptionItem(key: k, label: t.translate('identity_doc_type_$k')),
          ];
    final arabicCore = _fourPart || !_latinRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._documentSection(t, types),
        ..._namesSection(t, required: arabicCore),
        ..._photosSection(t),
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
