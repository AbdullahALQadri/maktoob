import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/widgets.dart';
import 'admin_approval_screen.dart';
import 'otp_verification_screen.dart';

/// Registration screen for new users and institutions.
class RegisterScreen extends StatefulWidget {
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({super.key, this.onLoginTap, this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _customGovernorateController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserType _selectedUserType = UserType.user;
  String _selectedCountryCode = '+970';
  int? _selectedInstitutionFieldIndex;
  int? _selectedGovernorateIndex;
  bool _showCustomGovernorate = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _customGovernorateController.dispose();
    super.dispose();
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.startsWith('0')) phoneNumber = phoneNumber.substring(1);
      final fullPhone = '$_selectedCountryCode$phoneNumber';

      String? governorateValue;
      if (_selectedUserType == UserType.institution && _selectedGovernorateIndex != null) {
        governorateValue = _showCustomGovernorate
            ? _customGovernorateController.text.trim()
            : _RegisterData.governorates[_selectedGovernorateIndex!];
      }

      context.read<AuthCubit>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
            phone: fullPhone,
            password: _passwordController.text,
            userType: _selectedUserType.apiValue,
            governorate: governorateValue,
            location: _selectedUserType == UserType.institution ? _locationController.text.trim() : null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _handleAuthState,
      child: Scaffold(
        body: AuthGradientBackground(
          child: Stack(
            children: [
              const AuthDecorativePattern(),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          SizedBox(height: context.dynamicHeight(0.02)),
                          _RegisterHeader(onBack: widget.onLoginTap),
                          SizedBox(height: context.dynamicHeight(0.025)),
                          _buildFormCard(),
                          SizedBox(height: context.dynamicHeight(0.02)),
                          _LoginLink(onLoginTap: widget.onLoginTap),
                          SizedBox(height: context.dynamicHeight(0.03)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthRegistered) {
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.startsWith('0')) phoneNumber = phoneNumber.substring(1);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<AuthCubit>(),
            child: OtpVerificationScreen(
              phone: '$_selectedCountryCode$phoneNumber',
              userType: _selectedUserType,
              onVerified: () {
                if (_selectedUserType == UserType.institution) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminApprovalWaitingScreen()),
                  );
                } else {
                  widget.onRegisterSuccess?.call();
                }
              },
              onBack: () {},
            ),
          ),
        ),
      );
    } else if (state is AuthAuthenticated) {
      widget.onRegisterSuccess?.call();
    } else if (state is AuthError) {
      AppSnackBar.showError(context, message: state.message);
    }
  }

  Widget _buildFormCard() {
    final t = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.051)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserTypeSelector(
                  selectedType: _selectedUserType,
                  onChanged: (type) => setState(() {
                    _selectedUserType = type;
                    if (type == UserType.user) _selectedCountryCode = '+970';
                  }),
                ),
                SizedBox(height: context.dynamicHeight(0.022)),
                _buildNameField(t),
                SizedBox(height: context.dynamicHeight(0.016)),
                _buildPhoneField(t),
                SizedBox(height: context.dynamicHeight(0.016)),
                _buildEmailField(t),
                SizedBox(height: context.dynamicHeight(0.016)),
                if (_selectedUserType == UserType.institution) ..._buildInstitutionFields(t),
                _buildPasswordFields(t),
                SizedBox(height: context.dynamicHeight(0.025)),
                _RegisterButton(onRegister: _handleRegister),
                if (_selectedUserType == UserType.institution) _InstitutionInfoBanner(t: t),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(AppLocalizations t) {
    return RegisterFormField(
      controller: _nameController,
      label: _selectedUserType == UserType.institution
          ? t.translate('auth_institution_name')
          : t.translate('auth_full_name'),
      hint: _selectedUserType == UserType.institution
          ? t.translate('auth_institution_name_hint')
          : t.translate('auth_full_name_hint'),
      prefixIcon: _selectedUserType == UserType.institution
          ? Icons.business_rounded
          : Icons.person_outline_rounded,
      validator: (value) {
        if (value == null || value.isEmpty) return t.translate('auth_field_required');
        if (value.length < 2) return t.translate('auth_min_2_chars');
        return null;
      },
    );
  }

  Widget _buildPhoneField(AppLocalizations t) {
    final country = CountryCode.findByCode(_selectedCountryCode);
    final maxLength = country.maxDigits + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('auth_phone_number'),
          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600, color: context.textTertiary),
        ),
        SizedBox(height: context.dynamicHeight(0.006)),
        Row(
          children: [
            _CountryCodeSelector(
              selectedCode: _selectedCountryCode,
              isFixed: _selectedUserType == UserType.user,
              onChanged: (code) => setState(() => _selectedCountryCode = code),
            ),
            SizedBox(width: context.dynamicWidth(0.021)),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxLength),
                ],
                style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary, fontWeight: FontWeight.w500),
                decoration: _inputDecoration(t.translate('auth_phone_hint'), Icons.phone_outlined),
                validator: (value) => _validatePhone(value, t, country),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _validatePhone(String? value, AppLocalizations t, CountryCode country) {
    if (value == null || value.isEmpty) return t.translate('auth_phone_required');

    String phone = value;
    if (phone.startsWith('0')) phone = phone.substring(1);

    if (phone.length < country.minDigits || phone.length > country.maxDigits) {
      if (country.minDigits == country.maxDigits) {
        return _isArabic
            ? 'رقم الهاتف يجب أن يكون ${country.minDigits} أرقام'
            : 'Phone number must be ${country.minDigits} digits';
      }
      return _isArabic
          ? 'رقم الهاتف يجب أن يكون بين ${country.minDigits} و ${country.maxDigits} أرقام'
          : 'Phone number must be ${country.minDigits}-${country.maxDigits} digits';
    }

    if (_selectedUserType == UserType.user && _selectedCountryCode == '+970' && !phone.startsWith('5')) {
      return t.translate('auth_phone_start_5');
    }
    return null;
  }

  Widget _buildEmailField(AppLocalizations t) {
    return RegisterFormField(
      controller: _emailController,
      label: t.translate('auth_email_optional'),
      hint: t.translate('auth_email_hint'),
      prefixIcon: Icons.alternate_email_rounded,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return t.translate('auth_email_invalid');
          }
        }
        return null;
      },
    );
  }

  List<Widget> _buildInstitutionFields(AppLocalizations t) {
    final fields = _isArabic ? _RegisterData.institutionFieldsAr : _RegisterData.institutionFields;
    final governorates = _isArabic ? _RegisterData.governoratesAr : _RegisterData.governorates;

    return [
      RegisterDropdownField(
        label: t.translate('auth_institution_field'),
        hint: t.translate('auth_institution_field_hint'),
        icon: Icons.category_outlined,
        items: fields,
        value: _selectedInstitutionFieldIndex != null ? fields[_selectedInstitutionFieldIndex!] : null,
        onChanged: (value) => setState(() => _selectedInstitutionFieldIndex = fields.indexOf(value!)),
        validator: (value) => value == null ? t.translate('auth_field_required') : null,
      ),
      SizedBox(height: context.dynamicHeight(0.016)),
      RegisterDropdownField(
        label: t.translate('auth_governorate'),
        hint: t.translate('auth_governorate_hint'),
        icon: Icons.map_outlined,
        items: governorates,
        value: _selectedGovernorateIndex != null ? governorates[_selectedGovernorateIndex!] : null,
        onChanged: (value) {
          setState(() {
            _selectedGovernorateIndex = governorates.indexOf(value!);
            _showCustomGovernorate = _selectedGovernorateIndex == _RegisterData.governorates.length - 1;
            if (!_showCustomGovernorate) _customGovernorateController.clear();
          });
        },
        validator: (value) => value == null ? t.translate('auth_field_required') : null,
      ),
      SizedBox(height: context.dynamicHeight(0.016)),
      if (_showCustomGovernorate) ...[
        RegisterFormField(
          controller: _customGovernorateController,
          label: t.translate('auth_governorate_name'),
          hint: t.translate('auth_governorate_name_hint'),
          prefixIcon: Icons.edit_location_alt_outlined,
          validator: (value) {
            if (_showCustomGovernorate) {
              if (value == null || value.isEmpty) return t.translate('auth_governorate_required');
              if (value.length < 2) return t.translate('auth_min_2_chars');
            }
            return null;
          },
        ),
        SizedBox(height: context.dynamicHeight(0.016)),
      ],
      RegisterFormField(
        controller: _locationController,
        label: t.translate('auth_location'),
        hint: t.translate('auth_location_hint'),
        prefixIcon: Icons.location_on_outlined,
        validator: (value) => value == null || value.isEmpty ? t.translate('auth_location_required') : null,
      ),
      SizedBox(height: context.dynamicHeight(0.016)),
    ];
  }

  Widget _buildPasswordFields(AppLocalizations t) {
    return Column(
      children: [
        RegisterFormField(
          controller: _passwordController,
          label: t.translate('auth_password'),
          hint: t.translate('auth_create_password_hint'),
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: context.iconDefault,
              size: 22,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return t.translate('auth_password_enter');
            if (value.length < 6) return t.translate('auth_password_min_length');
            return null;
          },
        ),
        SizedBox(height: context.dynamicHeight(0.016)),
        RegisterFormField(
          controller: _confirmPasswordController,
          label: t.translate('auth_confirm_password'),
          hint: t.translate('auth_confirm_password_hint'),
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            child: Icon(
              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: context.iconDefault,
              size: 22,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return t.translate('auth_confirm_password_required');
            if (value != _passwordController.text) return t.translate('auth_passwords_mismatch');
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySmall.copyWith(color: context.iconDefault),
      prefixIcon: Container(
        margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
        child: Icon(icon, color: AppColors.primaryColor, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      filled: true,
      fillColor: context.themeSurface,
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.014),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.red500, width: 1),
      ),
    );
  }
}

// Private widgets for RegisterScreen

class _RegisterHeader extends StatelessWidget {
  final VoidCallback? onBack;

  const _RegisterHeader({this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.translate('auth_create_account'), style: AppTextStyles.headlineSmall.white),
              const SizedBox(height: 4),
              Text(
                t.translate('auth_join_maktoob'),
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
        const AuthLogo(sizeFactor: 0.141),
      ],
    );
  }
}

class _CountryCodeSelector extends StatelessWidget {
  final String selectedCode;
  final bool isFixed;
  final ValueChanged<String> onChanged;

  const _CountryCodeSelector({
    required this.selectedCode,
    required this.isFixed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final country = CountryCode.findByCode(selectedCode);

    return Container(
      decoration: BoxDecoration(
        color: context.themeSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: isFixed
          ? Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.029),
                vertical: context.dynamicHeight(0.016),
              ),
              child: Row(
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    country.code,
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCode,
                padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.029)),
                icon: Icon(Icons.arrow_drop_down, color: context.iconSecondary),
                items: CountryCode.all.map((c) {
                  return DropdownMenuItem(
                    value: c.code,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.flag, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(c.code, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => onChanged(value!),
              ),
            ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final VoidCallback onRegister;

  const _RegisterButton({required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return PrimaryButton(
          text: AppLocalizations.of(context)!.translate('auth_create_account'),
          onPressed: isLoading ? null : onRegister,
          isLoading: isLoading,
        );
      },
    );
  }
}

class _LoginLink extends StatelessWidget {
  final VoidCallback? onLoginTap;

  const _LoginLink({this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.translate('auth_has_account'),
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.95)),
        ),
        GestureDetector(
          onTap: onLoginTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Text(
              t.translate('auth_login'),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InstitutionInfoBanner extends StatelessWidget {
  final AppLocalizations t;

  const _InstitutionInfoBanner({required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.dynamicHeight(0.015)),
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.029)),
        decoration: BoxDecoration(
          color: AppColors.amber50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.amber200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.amber600, size: 20),
            SizedBox(width: context.dynamicWidth(0.021)),
            Expanded(
              child: Text(
                t.translate('auth_institution_review'),
                style: AppTextStyles.caption.copyWith(color: AppColors.amber700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static data for registration form.
class _RegisterData {
  static const institutionFields = [
    'Education', 'Healthcare', 'Technology', 'Finance', 'Non-Profit',
    'Government', 'Media', 'Hospitality', 'Real Estate', 'Other',
  ];

  static const institutionFieldsAr = [
    'تعليم', 'صحة', 'تكنولوجيا', 'مالية', 'منظمة غير ربحية',
    'حكومة', 'إعلام', 'ضيافة', 'عقارات', 'أخرى',
  ];

  static const governorates = [
    'Gaza', 'North Gaza', 'Deir al-Balah', 'Khan Younis', 'Rafah',
    'Jerusalem', 'Ramallah and al-Bireh', 'Bethlehem', 'Hebron', 'Jericho',
    'Nablus', 'Jenin', 'Tulkarm', 'Qalqilya', 'Salfit', 'Tubas', 'Other',
  ];

  static const governoratesAr = [
    'غزة', 'شمال غزة', 'دير البلح', 'خان يونس', 'رفح',
    'القدس', 'رام الله والبيرة', 'بيت لحم', 'الخليل', 'أريحا',
    'نابلس', 'جنين', 'طولكرم', 'قلقيلية', 'سلفيت', 'طوباس', 'أخرى',
  ];
}
