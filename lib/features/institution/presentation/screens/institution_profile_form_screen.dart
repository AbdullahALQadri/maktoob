import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/design/window_size.dart';
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

part 'institution_profile_form_contact.dart';
part 'institution_profile_form_sections.dart';

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

  /// The sections live in `institution_profile_form_sections.dart`; they
  /// change the form's state through here.
  void _change(VoidCallback change) => setState(change);

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
          backgroundColor: context.scaffoldBg,
          appBar: AppBar(title: Text(t.translate('institution_profile_edit'))),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsetsDirectional.fromSTEB(context.pageGutter, AppSpacing.md, context.pageGutter, AppSpacing.xl),
                children: [
                  if (locked) ..._lockedNotice(t),
                  ..._logoPicker(t, busy: busy),
                  ..._identitySection(t, busy: busy, locked: locked, isArabic: isArabic),
                  ..._representativeSection(t, busy: busy, locked: locked, isArabic: isArabic),
                  ..._contactSection(t, busy: busy, isArabic: isArabic, governorates: governorates),
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
