part of 'institution_profile_form_screen.dart';

/// The three parts of the institution's file: who it is officially, who
/// represents it, and how to reach it.
extension _InstitutionFormSections on _InstitutionProfileFormScreenState {
  /// Once approved, the official details change only through the team.
  List<Widget> _lockedNotice(AppLocalizations t) => [
    OutlinedCard(
      child: Text(
        t.translate('institution_identity_review_note'),
        style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
      ),
    ),
    const SizedBox(height: AppSpacing.md),
  ];

  /// The logo: the one just picked, else the one on file.
  List<Widget> _logoPicker(AppLocalizations t, {required bool busy}) => [
    Row(
      children: [
        _logoPath != null
            ? ClipRRect(
                borderRadius: AppSpacing.borderRadiusMd,
                child: Image.file(File(_logoPath!), width: 64, height: 64, fit: BoxFit.cover),
              )
            : InstitutionLogo(url: _i?.pendingChanges?.logoUrl ?? _i?.logoUrl, size: 64),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                key: const Key('institution_pick_logo'),
                onPressed: busy ? null : _pickLogo,
                icon: const Icon(Icons.image_outlined),
                label: Text(t.translate('institution_logo_upload')),
              ),
              Text(
                t.translate('institution_logo_hint'),
                style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      ],
    ),
    const SizedBox(height: AppSpacing.md),
  ];

  List<Widget> _identitySection(
    AppLocalizations t, {
    required bool busy,
    required bool locked,
    required bool isArabic,
  }) => [
    _SectionLabel(t.translate('institution_section_identity')),
    TextFormField(
      key: const Key('institution_name_ar'),
      controller: _nameAr,
      decoration: _decoration(
        t.translate('institution_official_name_ar'),
        helper: t.translate('institution_official_name_hint'),
      ),
      validator: (v) => (v ?? '').trim().length < 2 ? t.translate('auth_field_required') : null,
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _nameEn,
      textDirection: TextDirection.ltr,
      decoration: _decoration(t.translate('institution_official_name_en')),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      key: const Key('institution_trade_name_ar'),
      controller: _tradeNameAr,
      decoration: _decoration(
        t.translate('institution_trade_name_ar'),
        helper: t.translate('institution_trade_name_hint'),
      ),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _tradeNameEn,
      textDirection: TextDirection.ltr,
      decoration: _decoration(t.translate('institution_trade_name_en')),
    ),
    const SizedBox(height: AppSpacing.smd),
    DropdownButtonFormField<String>(
      // The chosen value takes the field's width and shortens, never spills.
      isExpanded: true,
      initialValue: kInstitutionSectors.contains(_sector) ? _sector : null,
      decoration: _decoration(t.translate('institution_sector')),
      validator: (v) => v == null ? t.translate('auth_field_required') : null,
      items: [
        for (final s in kInstitutionSectors)
          DropdownMenuItem(value: s, child: Text(t.translate('institution_sector_$s'))),
      ],
      onChanged: (v) => _change(() => _sector = v),
    ),
    const SizedBox(height: AppSpacing.smd),
    DropdownButtonFormField<String>(
      // The chosen value takes the field's width and shortens, never spills.
      isExpanded: true,
      key: const Key('institution_legal_form'),
      initialValue: kInstitutionLegalForms.contains(_legalForm) ? _legalForm : null,
      decoration: _decoration(
        t.translate('institution_legal_form'),
        helper: t.translate('institution_required_for_review'),
      ),
      items: [
        for (final f in kInstitutionLegalForms)
          DropdownMenuItem(value: f, child: Text(t.translate('institution_legal_form_$f'))),
      ],
      onChanged: (v) => _change(() => _legalForm = v),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _registration,
      textDirection: TextDirection.ltr,
      decoration: _decoration(
        t.translate('institution_registration_number'),
        helper: t.translate('institution_registration_number_hint'),
      ),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _tax,
      textDirection: TextDirection.ltr,
      decoration: _decoration(t.translate('institution_tax_number')),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _authority,
      decoration: _decoration(
        t.translate('institution_registration_authority'),
        helper: t.translate('institution_registration_authority_hint'),
      ),
    ),
    const SizedBox(height: AppSpacing.smd),
    CountryPickerField(
      key: const Key('institution_registration_country'),
      label: t.translate('institution_registration_country'),
      helperText: t.translate('institution_required_for_review'),
      value: _registrationCountry,
      countries: _countryOptions(t),
      enabled: !busy,
      onChanged: (code) => _change(() => _registrationCountry = code),
    ),
    const SizedBox(height: AppSpacing.smd),
    InkWell(
      key: const Key('institution_registration_date'),
      onTap: busy ? null : _pickRegistrationDate,
      borderRadius: AppSpacing.borderRadiusMd,
      child: InputDecorator(
        isEmpty: (_registrationDate ?? '').isEmpty,
        decoration: _decoration(t.translate('institution_registration_date')).copyWith(
          suffixIcon: (_registrationDate ?? '').isEmpty
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: busy ? null : () => _change(() => _registrationDate = null),
                ),
        ),
        child: Text(
          _registrationDate ?? '',
          textDirection: TextDirection.ltr,
          style: AppTextStyles.bodyLarge.copyWith(color: context.textPrimary),
        ),
      ),
    ),
    const SizedBox(height: AppSpacing.lg),
  ];

  List<Widget> _representativeSection(
    AppLocalizations t, {
    required bool busy,
    required bool locked,
    required bool isArabic,
  }) => [
    _SectionLabel(t.translate('institution_section_representative')),
    DropdownButtonFormField<String>(
      // The chosen value takes the field's width and shortens, never spills.
      isExpanded: true,
      key: const Key('institution_representative_role'),
      initialValue: kInstitutionRepresentativeRoles.contains(_representativeRole) ? _representativeRole : null,
      decoration: _decoration(
        t.translate('institution_representative_role'),
        helper: t.translate(
          _representativeRole == 'authorized'
              ? 'institution_representative_authorized_hint'
              : 'institution_representative_role_hint',
        ),
      ),
      items: [
        for (final r in kInstitutionRepresentativeRoles)
          DropdownMenuItem(value: r, child: Text(t.translate('institution_representative_role_$r'))),
      ],
      onChanged: (v) => _change(() => _representativeRole = v),
    ),
    const SizedBox(height: AppSpacing.smd),
    TextFormField(
      controller: _website,
      keyboardType: TextInputType.url,
      textDirection: TextDirection.ltr,
      decoration: _decoration(t.translate('institution_website')),
    ),
    const SizedBox(height: AppSpacing.lg),
  ];
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.titleSmall.copyWith(color: context.textSecondary)),
    );
  }
}
