import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../../identity/domain/entities/identity_entities.dart';
import '../../../identity/domain/usecases/get_identity_usecase.dart';
import '../../../identity/presentation/widgets/country_picker_field.dart';
import '../../../identity/presentation/widgets/identity_form.dart' show identityDate;
import '../../domain/entities/institution_entity.dart';
import '../cubit/institution_cubit.dart';
import '../cubit/institution_state.dart';
import '../widgets/institution_widgets.dart';

/// Edit (or resubmit after rejection) the institution profile:
/// `POST /institution/profile`. Pops `true` when saved.
///
/// On an approved institution, identity fields (names, sector, official
/// numbers, website, logo) are reviewed by staff before they go live; the
/// form shows the requested values and says so.
///
/// Expects an [InstitutionCubit] above it.
class InstitutionProfileFormScreen extends StatefulWidget {
  final InstitutionEntity? initial;

  const InstitutionProfileFormScreen({super.key, this.initial});

  @override
  State<InstitutionProfileFormScreen> createState() => _InstitutionProfileFormScreenState();
}

class _InstitutionProfileFormScreenState extends State<InstitutionProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  InstitutionEntity? get _i => widget.initial;
  String? _req(String column, String? live) => _i?.requested(column, live) ?? live;

  late final _nameAr = TextEditingController(text: _req('name_ar', _i?.nameAr));
  late final _nameEn = TextEditingController(text: _req('name_en', _i?.nameEn));
  late final _registration = TextEditingController(text: _req('registration_number', _i?.registrationNumber));
  late final _tax = TextEditingController(text: _req('tax_number', _i?.taxNumber));
  late final _website = TextEditingController(text: _req('website', _i?.website));
  late final _email = TextEditingController(text: _i?.officialEmail);
  late final _contactPerson = TextEditingController(text: _i?.contactPerson);
  late final _contactPhone = TextEditingController(text: _i?.contactPhone);
  late final _address = TextEditingController(text: _i?.address);
  late final _description = TextEditingController(text: _i?.description);
  late String? _sector = _req('sector', _i?.sector);
  late String? _governorate = _i?.governorate;
  late bool _declaration = _i?.declarationAccepted ?? false;
  String? _logoPath;

  // KYB: who the organization legally is and who acts for it.
  late final _tradeNameAr = TextEditingController(text: _req('trade_name_ar', _i?.tradeNameAr));
  late final _tradeNameEn = TextEditingController(text: _req('trade_name_en', _i?.tradeNameEn));
  late final _authority = TextEditingController(text: _req('registration_authority', _i?.registrationAuthority));
  late String? _legalForm = _req('legal_form', _i?.legalForm);
  late String? _registrationCountry = _req('registration_country', _i?.registrationCountry) ?? 'PS';
  late String? _registrationDate = _req('registration_date', _i?.registrationDate);
  late String? _representativeRole = _req('representative_role', _i?.representativeRole);
  late String? _country = _i?.country ?? 'PS';

  /// Country names from `GET /auth/identity` options (app language).
  List<CountryOption> _countries = const [];
  bool _countriesRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_countriesRequested) return;
    _countriesRequested = true;
    if (!di.sl.isRegistered<GetIdentityUseCase>()) return;
    final locale = Localizations.localeOf(context).languageCode;
    di.sl<GetIdentityUseCase>()(GetIdentityParams(locale: locale)).then((result) {
      result.fold((_) {}, (overview) {
        if (mounted && overview.options.countries.isNotEmpty) {
          setState(() => _countries = overview.options.countries);
        }
      });
    });
  }

  /// Until the list loads (or offline): Palestine, so the default still reads well.
  List<CountryOption> _countryOptions(AppLocalizations t) => _countries.isNotEmpty
      ? _countries
      : [CountryOption(code: 'PS', name: t.translate('identity_country_ps'))];

  Future<void> _pickRegistrationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_registrationDate ?? '') ?? DateTime(now.year - 5),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _registrationDate = identityDate(picked));
  }

  @override
  void dispose() {
    for (final c in [
      _nameAr, _nameEn, _registration, _tax, _website, _email,
      _contactPerson, _contactPhone, _address, _description,
      _tradeNameAr, _tradeNameEn, _authority,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 90,
    );
    if (picked != null && mounted) setState(() => _logoPath = picked.path);
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_declaration) {
      AppSnackBar.showError(context, message: t.translate('institution_declaration_required'));
      return;
    }
    final ok = await context.read<InstitutionCubit>().saveProfile(InstitutionProfileInput(
          nameAr: _nameAr.text.trim(),
          nameEn: _nameEn.text.trim(),
          sector: _sector,
          contactPerson: _contactPerson.text.trim(),
          contactPhone: _contactPhone.text.trim(),
          registrationNumber: _registration.text.trim(),
          taxNumber: _tax.text.trim(),
          website: _website.text.trim(),
          officialEmail: _email.text.trim(),
          governorate: _governorate,
          address: _address.text.trim(),
          description: _description.text.trim(),
          tradeNameAr: _tradeNameAr.text.trim(),
          tradeNameEn: _tradeNameEn.text.trim(),
          legalForm: _legalForm,
          registrationAuthority: _authority.text.trim(),
          registrationCountry: _registrationCountry,
          registrationDate: _registrationDate,
          representativeRole: _representativeRole,
          country: _country,
          declaration: _declaration && !(_i?.declarationAccepted ?? false),
          logoPath: _logoPath,
          sendEmpty: true,
        ));
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(String label, {String? helper}) => InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 3,
        border: const OutlineInputBorder(borderRadius: AppSpacing.borderRadiusMd),
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = !t.isEnLocale;
    final locked = _i?.isIdentityLocked ?? false;
    final governorates = {
      for (final e in kPalestineGovernorates.entries) e.key: isArabic ? e.value : e.key,
      if ((_governorate ?? '').isNotEmpty && !kPalestineGovernorates.containsKey(_governorate))
        _governorate!: _governorate!,
    };

    return BlocConsumer<InstitutionCubit, InstitutionState>(
      listener: (context, state) {
        if (state is InstitutionLoaded && state.messageIsError) {
          showInstitutionMessage(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final busy = state is InstitutionLoaded && state.isBusy;
        return Scaffold(
          backgroundColor: AppColors.surfaceBg,
          appBar: MaktoobAppBar(title: t.translate('institution_profile_edit')),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                children: [
                  if (locked) ...[
                    OutlinedCard(
                      child: Text(
                        t.translate('institution_identity_review_note'),
                        style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
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
                    initialValue: kInstitutionSectors.contains(_sector) ? _sector : null,
                    decoration: _decoration(t.translate('institution_sector')),
                    validator: (v) => v == null ? t.translate('auth_field_required') : null,
                    items: [
                      for (final s in kInstitutionSectors)
                        DropdownMenuItem(value: s, child: Text(t.translate('institution_sector_$s'))),
                    ],
                    onChanged: (v) => setState(() => _sector = v),
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  DropdownButtonFormField<String>(
                    key: const Key('institution_legal_form'),
                    initialValue: kInstitutionLegalForms.contains(_legalForm) ? _legalForm : null,
                    isExpanded: true,
                    decoration: _decoration(
                      t.translate('institution_legal_form'),
                      helper: t.translate('institution_required_for_review'),
                    ),
                    items: [
                      for (final f in kInstitutionLegalForms)
                        DropdownMenuItem(value: f, child: Text(t.translate('institution_legal_form_$f'))),
                    ],
                    onChanged: (v) => setState(() => _legalForm = v),
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
                    onChanged: (code) => setState(() => _registrationCountry = code),
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
                                onPressed: busy ? null : () => setState(() => _registrationDate = null),
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
                  _SectionLabel(t.translate('institution_section_representative')),
                  DropdownButtonFormField<String>(
                    key: const Key('institution_representative_role'),
                    initialValue: kInstitutionRepresentativeRoles.contains(_representativeRole) ? _representativeRole : null,
                    isExpanded: true,
                    decoration: _decoration(
                      t.translate('institution_representative_role'),
                      helper: t.translate(_representativeRole == 'authorized'
                          ? 'institution_representative_authorized_hint'
                          : 'institution_representative_role_hint'),
                    ),
                    items: [
                      for (final r in kInstitutionRepresentativeRoles)
                        DropdownMenuItem(value: r, child: Text(t.translate('institution_representative_role_$r'))),
                    ],
                    onChanged: (v) => setState(() => _representativeRole = v),
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  TextFormField(
                    controller: _website,
                    keyboardType: TextInputType.url,
                    textDirection: TextDirection.ltr,
                    decoration: _decoration(t.translate('institution_website')),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionLabel(t.translate('institution_section_contact')),
                  TextFormField(
                    controller: _contactPerson,
                    decoration: _decoration(t.translate('institution_contact_person')),
                  ),
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
                      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
                          ? null
                          : t.translate('auth_email_invalid');
                    },
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  CountryPickerField(
                    key: const Key('institution_country'),
                    label: t.translate('institution_country'),
                    value: _country,
                    countries: _countryOptions(t),
                    enabled: !busy,
                    onChanged: (code) => setState(() => _country = code),
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  DropdownButtonFormField<String>(
                    initialValue: governorates.containsKey(_governorate) ? _governorate : null,
                    decoration: _decoration(t.translate('auth_governorate')),
                    items: [
                      for (final e in governorates.entries)
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ],
                    onChanged: (v) => setState(() => _governorate = v),
                  ),
                  const SizedBox(height: AppSpacing.smd),
                  TextFormField(
                    controller: _address,
                    decoration: _decoration(t.translate('institution_address')),
                  ),
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
                      onChanged: busy ? null : (v) => setState(() => _declaration = v ?? false),
                      title: Text(
                        t.translate('institution_declaration'),
                        style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    text: t.translate(locked ? 'common_save' : 'institution_save_and_submit'),
                    isLoading: busy,
                    onPressed: busy ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.titleSmall.copyWith(color: AppColors.gray700)),
    );
  }
}
