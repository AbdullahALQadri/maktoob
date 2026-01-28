import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../domain/entities/user_entity.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({
    super.key,
    this.onLoginTap,
    this.onRegisterSuccess,
  });

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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserType _selectedUserType = UserType.user;
  String _selectedCountryCode = '+970'; // Default Palestine
  int? _selectedInstitutionFieldIndex; // Index-based to work with language switching
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Country codes for institution
  final List<Map<String, String>> _countryCodes = [
    {'code': '+970', 'country': 'Palestine', 'flag': '🇵🇸'},
    {'code': '+972', 'country': 'Israel', 'flag': '🇮🇱'},
    {'code': '+962', 'country': 'Jordan', 'flag': '🇯🇴'},
    {'code': '+20', 'country': 'Egypt', 'flag': '🇪🇬'},
    {'code': '+966', 'country': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': '+971', 'country': 'UAE', 'flag': '🇦🇪'},
    {'code': '+974', 'country': 'Qatar', 'flag': '🇶🇦'},
    {'code': '+965', 'country': 'Kuwait', 'flag': '🇰🇼'},
    {'code': '+968', 'country': 'Oman', 'flag': '🇴🇲'},
    {'code': '+973', 'country': 'Bahrain', 'flag': '🇧🇭'},
    {'code': '+961', 'country': 'Lebanon', 'flag': '🇱🇧'},
    {'code': '+963', 'country': 'Syria', 'flag': '🇸🇾'},
    {'code': '+964', 'country': 'Iraq', 'flag': '🇮🇶'},
    {'code': '+90', 'country': 'Turkey', 'flag': '🇹🇷'},
    {'code': '+1', 'country': 'USA/Canada', 'flag': '🇺🇸'},
    {'code': '+44', 'country': 'UK', 'flag': '🇬🇧'},
    {'code': '+49', 'country': 'Germany', 'flag': '🇩🇪'},
    {'code': '+33', 'country': 'France', 'flag': '🇫🇷'},
  ];

  // Phone number length validation per country (min, max digits after removing leading 0)
  static const Map<String, List<int>> _phoneValidation = {
    '+970': [9, 9],      // Palestine: 9 digits
    '+972': [9, 9],      // Israel: 9 digits
    '+962': [9, 9],      // Jordan: 9 digits
    '+20': [10, 10],     // Egypt: 10 digits
    '+966': [9, 9],      // Saudi Arabia: 9 digits
    '+971': [9, 9],      // UAE: 9 digits
    '+974': [8, 8],      // Qatar: 8 digits
    '+965': [8, 8],      // Kuwait: 8 digits
    '+968': [8, 8],      // Oman: 8 digits
    '+973': [8, 8],      // Bahrain: 8 digits
    '+961': [7, 8],      // Lebanon: 7-8 digits
    '+963': [9, 9],      // Syria: 9 digits
    '+964': [10, 10],    // Iraq: 10 digits
    '+90': [10, 10],     // Turkey: 10 digits
    '+1': [10, 10],      // USA/Canada: 10 digits
    '+44': [10, 10],     // UK: 10 digits
    '+49': [10, 11],     // Germany: 10-11 digits
    '+33': [9, 9],       // France: 9 digits
  };

  // Institution field options
  final List<String> _institutionFields = [
    'Education',
    'Healthcare',
    'Technology',
    'Finance',
    'Non-Profit',
    'Government',
    'Media',
    'Hospitality',
    'Real Estate',
    'Other',
  ];

  final List<String> _institutionFieldsAr = [
    'تعليم',
    'صحة',
    'تكنولوجيا',
    'مالية',
    'منظمة غير ربحية',
    'حكومة',
    'إعلام',
    'ضيافة',
    'عقارات',
    'أخرى',
  ];

  // Palestinian Governorates
  final List<String> _governorates = [
    'Gaza',
    'North Gaza',
    'Deir al-Balah',
    'Khan Younis',
    'Rafah',
    'Jerusalem',
    'Ramallah and al-Bireh',
    'Bethlehem',
    'Hebron',
    'Jericho',
    'Nablus',
    'Jenin',
    'Tulkarm',
    'Qalqilya',
    'Salfit',
    'Tubas',
    'Other',
  ];

  final List<String> _governoratesAr = [
    'غزة',
    'شمال غزة',
    'دير البلح',
    'خان يونس',
    'رفح',
    'القدس',
    'رام الله والبيرة',
    'بيت لحم',
    'الخليل',
    'أريحا',
    'نابلس',
    'جنين',
    'طولكرم',
    'قلقيلية',
    'سلفيت',
    'طوباس',
    'أخرى',
  ];

  int? _selectedGovernorateIndex; // Index-based to work with language switching
  final _customGovernorateController = TextEditingController();
  bool _showCustomGovernorate = false; // Flag to show custom governorate field

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
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

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // Remove leading 0 from phone number if present
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.substring(1);
      }
      final fullPhone = '$_selectedCountryCode$phoneNumber';

      // Determine governorate value
      String? governorateValue;
      if (_selectedUserType == UserType.institution && _selectedGovernorateIndex != null) {
        if (_showCustomGovernorate) {
          // Use custom governorate text
          governorateValue = _customGovernorateController.text.trim();
        } else {
          // Use selected governorate (English value for API)
          governorateValue = _governorates[_selectedGovernorateIndex!];
        }
      }

      context.read<AuthCubit>().register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
            phone: fullPhone,
            password: _passwordController.text,
            userType: _selectedUserType.apiValue,
            governorate: governorateValue,
            location: _selectedUserType == UserType.institution
                ? _locationController.text.trim()
                : null,
          );
    }
  }

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  // Get max phone length for current country (including potential leading 0)
  int _getMaxPhoneLength() {
    final validation = _phoneValidation[_selectedCountryCode];
    if (validation != null) {
      // Add 1 to account for potential leading 0
      return validation[1] + 1;
    }
    return 15; // Default max length
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          // Remove leading 0 from phone number if present
          String phoneNumber = _phoneController.text.trim();
          if (phoneNumber.startsWith('0')) {
            phoneNumber = phoneNumber.substring(1);
          }
          // Navigate to OTP verification screen
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
                      // Navigate to admin approval waiting screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminApprovalWaitingScreen(),
                        ),
                      );
                    } else {
                      // User is verified, go to login
                      widget.onRegisterSuccess?.call();
                    }
                  },
                  onBack: () {
                    // Pop is handled by OTP screen itself
                  },
                ),
              ),
            ),
          );
        } else if (state is AuthAuthenticated) {
          widget.onRegisterSuccess?.call();
        } else if (state is AuthError) {
          AppSnackBar.showError(context, message: state.message);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.85),
                AppColors.tertiaryColor.withValues(alpha: 0.9),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              _buildDecorativePattern(),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dynamicWidth(0.061),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            SizedBox(height: context.dynamicHeight(0.02)),
                            _buildHeader(),
                            SizedBox(height: context.dynamicHeight(0.025)),
                            _buildFormCard(),
                            SizedBox(height: context.dynamicHeight(0.02)),
                            _buildLoginLink(),
                            SizedBox(height: context.dynamicHeight(0.03)),
                          ],
                        ),
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

  Widget _buildDecorativePattern() {
    return Stack(
      children: [
        Positioned(
          top: -context.dynamicWidth(0.301),
          left: -context.dynamicWidth(0.2),
          child: Container(
            width: context.dynamicWidth(0.701),
            height: context.dynamicWidth(0.701),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -context.dynamicWidth(0.149),
          right: -context.dynamicWidth(0.251),
          child: Container(
            width: context.dynamicWidth(0.501),
            height: context.dynamicWidth(0.501),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onLoginTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.04)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.translate('auth_create_account'),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.056),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                t.translate('auth_join_maktoob'),
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.032),
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Hero(
          tag: 'app_logo',
          child: Container(
            width: context.dynamicWidth(0.141),
            height: context.dynamicWidth(0.141),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(context.dynamicWidth(0.021)),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
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
            child: Builder(builder: (context) {
              final t = AppLocalizations.of(context)!;
              return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUserTypeSelector(),
                SizedBox(height: context.dynamicHeight(0.022)),

                // Name Field
                _buildModernTextField(
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
                    if (value == null || value.isEmpty) {
                      return t.translate('auth_field_required');
                    }
                    if (value.length < 2) {
                      return t.translate('auth_min_2_chars');
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.016)),

                // Phone Field with Country Code
                _buildPhoneField(),
                SizedBox(height: context.dynamicHeight(0.016)),

                // Email Field
                _buildModernTextField(
                  controller: _emailController,
                  label: t.translate('auth_email_optional'),
                  hint: t.translate('auth_email_hint'),
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return t.translate('auth_email_invalid');
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.016)),

                // Institution-only fields: Institution Field, Governorate, Address
                if (_selectedUserType == UserType.institution) ...[
                  _buildDropdownField(
                    label: t.translate('auth_institution_field'),
                    hint: t.translate('auth_institution_field_hint'),
                    icon: Icons.category_outlined,
                    items: _isArabic ? _institutionFieldsAr : _institutionFields,
                    value: _selectedInstitutionFieldIndex != null
                        ? (_isArabic
                            ? _institutionFieldsAr[_selectedInstitutionFieldIndex!]
                            : _institutionFields[_selectedInstitutionFieldIndex!])
                        : null,
                    onChanged: (value) {
                      setState(() {
                        // Store index for language-independent selection
                        final items = _isArabic ? _institutionFieldsAr : _institutionFields;
                        _selectedInstitutionFieldIndex = items.indexOf(value!);
                      });
                    },
                  ),
                  SizedBox(height: context.dynamicHeight(0.016)),

                  // Governorate dropdown
                  _buildDropdownField(
                    label: t.translate('auth_governorate'),
                    hint: t.translate('auth_governorate_hint'),
                    icon: Icons.map_outlined,
                    items: _isArabic ? _governoratesAr : _governorates,
                    value: _selectedGovernorateIndex != null
                        ? (_isArabic
                            ? _governoratesAr[_selectedGovernorateIndex!]
                            : _governorates[_selectedGovernorateIndex!])
                        : null,
                    onChanged: (value) {
                      setState(() {
                        // Store index for language-independent selection
                        final items = _isArabic ? _governoratesAr : _governorates;
                        _selectedGovernorateIndex = items.indexOf(value!);
                        // Check if "Other" is selected (last item in the list)
                        _showCustomGovernorate = _selectedGovernorateIndex == _governorates.length - 1;
                        // Clear custom governorate when changing to non-Other selection
                        if (!_showCustomGovernorate) {
                          _customGovernorateController.clear();
                        }
                      });
                    },
                  ),
                  SizedBox(height: context.dynamicHeight(0.016)),

                  // Custom Governorate text field - Only when "Other" is selected
                  if (_showCustomGovernorate)
                    _buildModernTextField(
                      controller: _customGovernorateController,
                      label: t.translate('auth_governorate_name'),
                      hint: t.translate('auth_governorate_name_hint'),
                      prefixIcon: Icons.edit_location_alt_outlined,
                      validator: (value) {
                        if (_showCustomGovernorate) {
                          if (value == null || value.isEmpty) {
                            return t.translate('auth_governorate_required');
                          }
                          if (value.length < 2) {
                            return t.translate('auth_min_2_chars');
                          }
                        }
                        return null;
                      },
                    ),
                  if (_showCustomGovernorate)
                    SizedBox(height: context.dynamicHeight(0.016)),

                  // Address Field
                  _buildModernTextField(
                    controller: _locationController,
                    label: t.translate('auth_location'),
                    hint: t.translate('auth_location_hint'),
                    prefixIcon: Icons.location_on_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.translate('auth_location_required');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.dynamicHeight(0.016)),
                ],

                // Password Field
                _buildModernTextField(
                  controller: _passwordController,
                  label: t.translate('auth_password'),
                  hint: t.translate('auth_create_password_hint'),
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.gray400,
                      size: 22,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.translate('auth_password_enter');
                    }
                    if (value.length < 6) {
                      return t.translate('auth_password_min_length');
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.016)),

                // Confirm Password Field
                _buildModernTextField(
                  controller: _confirmPasswordController,
                  label: t.translate('auth_confirm_password'),
                  hint: t.translate('auth_confirm_password_hint'),
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.gray400,
                      size: 22,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.translate('auth_confirm_password_required');
                    }
                    if (value != _passwordController.text) {
                      return t.translate('auth_passwords_mismatch');
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.dynamicHeight(0.025)),

                // Register Button
                _buildRegisterButton(),

                // Info text for institution
                if (_selectedUserType == UserType.institution) ...[
                  SizedBox(height: context.dynamicHeight(0.015)),
                  Container(
                    padding: EdgeInsets.all(context.dynamicWidth(0.029)),
                    decoration: BoxDecoration(
                      color: AppColors.amber50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amber200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.amber600,
                          size: 20,
                        ),
                        SizedBox(width: context.dynamicWidth(0.021)),
                        Expanded(
                          child: Text(
                            t.translate('auth_institution_review'),
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.029),
                              color: AppColors.amber700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('auth_account_type'),
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _buildUserTypeOption(
                  type: UserType.user,
                  icon: Icons.person_rounded,
                  label: t.translate('auth_individual'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildUserTypeOption(
                  type: UserType.institution,
                  icon: Icons.business_rounded,
                  label: t.translate('auth_institution'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeOption({
    required UserType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedUserType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = type;
          // Reset country code based on user type
          if (type == UserType.user) {
            _selectedCountryCode = '+970'; // Palestine only
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.015),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.gray500,
              size: context.dynamicWidth(0.051),
            ),
            SizedBox(width: context.dynamicWidth(0.021)),
            Text(
              label,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.035),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('auth_phone_number'),
          style: TextStyle(
            fontSize: context.dynamicWidth(0.032),
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.006)),
        Row(
          children: [
            // Country Code Selector
            Container(
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: _selectedUserType == UserType.user
                  // Fixed Palestine code for individual users
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.029),
                        vertical: context.dynamicHeight(0.016),
                      ),
                      child: Row(
                        children: [
                          Text('🇵🇸', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text(
                            '+970',
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.037),
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                    )
                  // Dropdown for institutions
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.dynamicWidth(0.029),
                        ),
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.gray500),
                        items: _countryCodes.map((country) {
                          return DropdownMenuItem(
                            value: country['code'],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(country['flag']!, style: TextStyle(fontSize: 18)),
                                SizedBox(width: 6),
                                Text(
                                  country['code']!,
                                  style: TextStyle(
                                    fontSize: context.dynamicWidth(0.035),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value!;
                            // Truncate phone if it exceeds new max length
                            final maxLength = _getMaxPhoneLength();
                            if (_phoneController.text.length > maxLength) {
                              _phoneController.text = _phoneController.text.substring(0, maxLength);
                              _phoneController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _phoneController.text.length),
                              );
                            }
                          });
                        },
                      ),
                    ),
            ),
            SizedBox(width: context.dynamicWidth(0.021)),
            // Phone Number Input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_getMaxPhoneLength()),
                ],
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.037),
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: t.translate('auth_phone_hint'),
                  hintStyle: TextStyle(
                    color: AppColors.gray400,
                    fontSize: context.dynamicWidth(0.032),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
                    child: Icon(
                      Icons.phone_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  filled: true,
                  fillColor: AppColors.gray50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.04),
                    vertical: context.dynamicHeight(0.014),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.red500, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.red500, width: 2),
                  ),
                  errorStyle: TextStyle(
                    color: AppColors.red500,
                    fontSize: context.dynamicWidth(0.029),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.translate('auth_phone_required');
                  }

                  // Remove leading 0 for validation
                  String phoneNumber = value;
                  if (phoneNumber.startsWith('0')) {
                    phoneNumber = phoneNumber.substring(1);
                  }

                  // Get validation rules for selected country
                  final validation = _phoneValidation[_selectedCountryCode];
                  if (validation != null) {
                    final minLength = validation[0];
                    final maxLength = validation[1];

                    if (phoneNumber.length < minLength || phoneNumber.length > maxLength) {
                      if (minLength == maxLength) {
                        return _isArabic
                            ? 'رقم الهاتف يجب أن يكون $minLength أرقام'
                            : 'Phone number must be $minLength digits';
                      } else {
                        return _isArabic
                            ? 'رقم الهاتف يجب أن يكون بين $minLength و $maxLength أرقام'
                            : 'Phone number must be $minLength-$maxLength digits';
                      }
                    }
                  }

                  // Palestine individual users: must start with 5 (mobile)
                  if (_selectedUserType == UserType.user && _selectedCountryCode == '+970') {
                    if (!phoneNumber.startsWith('5')) {
                      return t.translate('auth_phone_start_5');
                    }
                  }

                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.032),
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.006)),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: context.dynamicWidth(0.032),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(icon, color: AppColors.primaryColor, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.014),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500, width: 2),
            ),
            errorStyle: TextStyle(
              color: AppColors.red500,
              fontSize: context.dynamicWidth(0.029),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.035),
                  color: AppColors.gray900,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.translate('auth_field_required');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.032),
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.006)),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.037),
            color: AppColors.gray900,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: context.dynamicWidth(0.032),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(
                prefixIcon,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicHeight(0.014),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500, width: 2),
            ),
            errorStyle: TextStyle(
              color: AppColors.red500,
              fontSize: context.dynamicWidth(0.029),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Container(
          height: context.dynamicHeight(0.065),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.translate('auth_create_account'),
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.043),
                      fontWeight: FontWeight.w700,
                      letterSpacing: _isArabic ? 0 : 0.5,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    final t = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.translate('auth_has_account'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.95),
            fontSize: context.dynamicWidth(0.037),
          ),
        ),
        GestureDetector(
          onTap: widget.onLoginTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              t.translate('auth_login'),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: context.dynamicWidth(0.035),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Admin Approval Waiting Screen for Institutions
class AdminApprovalWaitingScreen extends StatelessWidget {
  const AdminApprovalWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withValues(alpha: 0.85),
              AppColors.tertiaryColor.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.dynamicWidth(0.08)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: context.dynamicWidth(0.301),
                  height: context.dynamicWidth(0.301),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: context.dynamicWidth(0.149),
                    color: AppColors.amber500,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.039)),

                // Title
                Text(
                  t.translate('auth_pending_approval'),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.064),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.02)),

                // Description
                Text(
                  isArabic
                      ? 'تم التحقق من رقم هاتفك بنجاح!\n\nحسابك الآن قيد المراجعة من قبل الإدارة.\nسيتم إعلامك عند الموافقة على حسابك.'
                      : 'Your phone number has been verified!\n\nYour account is now under review by the admin.\nYou will be notified once your account is approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.06)),

                // Info Card
                Container(
                  padding: EdgeInsets.all(context.dynamicWidth(0.051)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: context.dynamicHeight(0.015)),
                      Text(
                        t.translate('auth_notification_approval'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: context.dynamicWidth(0.035),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Back to Login Button
                SizedBox(
                  width: double.infinity,
                  height: context.dynamicHeight(0.065),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to login
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      t.translate('auth_back_to_login'),
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.043),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
