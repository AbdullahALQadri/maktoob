part of 'identity_form.dart';

/// The three parts of the identity form: the document, the legal name as
/// printed (Arabic in parts, then Latin), and the photos with the declaration.
extension _IdentityFormSections on _IdentityFormState {
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

  List<Widget> _documentSection(AppLocalizations t, List<IdentityOptionItem> types) => [
    _Section(t.translate('identity_section_document')),
    DropdownButtonFormField<String>(
      // The chosen value takes the field's width and shortens, never spills.
      isExpanded: true,
      key: const Key('identity_document_type'),
      initialValue: types.any((x) => x.key == _type) ? _type : types.first.key,
      decoration: _decoration(t.translate('identity_document_type'), required: true),
      items: [for (final x in types) DropdownMenuItem(value: x.key, child: Text(x.label))],
      onChanged: widget.busy
          ? null
          : (v) => _change(() {
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
        _change(() {
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
      onClear: () => _change(() => _expiresOn = null),
    ),
    const SizedBox(height: AppSpacing.lg),
  ];

  List<Widget> _namesSection(AppLocalizations t, {required bool required}) {
    final arabicCore = required;
    return [
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
    ];
  }

  List<Widget> _photosSection(AppLocalizations t) => [
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
        _change(() => _frontPath = p);
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
        _change(() => _backPath = p);
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
              _change(() => _declaration = v ?? false);
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
  ];
}
