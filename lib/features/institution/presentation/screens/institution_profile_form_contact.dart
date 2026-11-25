part of 'institution_profile_form_screen.dart';

/// How to reach the institution, and the declaration that the file is true.
extension _InstitutionFormContact on _InstitutionProfileFormScreenState {
  List<Widget> _contactSection(
    AppLocalizations t, {
    required bool busy,
    required bool isArabic,
    required Map<String, String> governorates,
  }) => [
    _SectionLabel(t.translate('institution_section_contact')),
    TextFormField(controller: _contactPerson, decoration: _decoration(t.translate('institution_contact_person'))),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _contactPhone,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      decoration: _decoration(t.translate('institution_contact_phone')),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      decoration: _decoration(t.translate('institution_official_email')),
      validator: (v) {
        final s = (v ?? '').trim();
        if (s.isEmpty) return null;
        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s) ? null : t.translate('auth_email_invalid');
      },
    ),
    const SizedBox(height: AppSpacing.smd),
    CountryPickerField(
      key: const Key('institution_country'),
      label: t.translate('institution_country'),
      value: _country,
      countries: _countryOptions(t),
      enabled: !busy,
      onChanged: (code) => _change(() => _country = code),
    ),
    const SizedBox(height: AppSpacing.smd),
    DropdownButtonFormField<String>(
      // The chosen value takes the field's width and shortens, never spills.
      isExpanded: true,
      initialValue: governorates.containsKey(_governorate) ? _governorate : null,
      decoration: _decoration(t.translate('auth_governorate')),
      items: [for (final e in governorates.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
      onChanged: (v) => _change(() => _governorate = v),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(controller: _address, decoration: _decoration(t.translate('institution_address'))),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _description,
      maxLines: 3,
      maxLength: 1000,
      decoration: _decoration(t.translate('institution_description')),
    ),
    if (!(_i?.declarationAccepted ?? false)) ...[
      const SizedBox(height: AppSpacing.sm),
      CheckboxListTile(
        key: const Key('institution_declaration'),
        value: _declaration,
        contentPadding: EdgeInsetsDirectional.zero,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: busy ? null : (v) => _change(() => _declaration = v ?? false),
        title: Text(
          t.translate('institution_declaration'),
          style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary),
        ),
      ),
    ],
    const SizedBox(height: AppSpacing.lg),
  ];
}
