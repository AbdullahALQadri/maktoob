import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// Country code data.
class CountryCode {
  final String code;
  final String country;
  final String flag;
  final int minDigits;
  final int maxDigits;

  const CountryCode({
    required this.code,
    required this.country,
    required this.flag,
    required this.minDigits,
    required this.maxDigits,
  });

  static const List<CountryCode> all = [
    CountryCode(code: '+970', country: 'Palestine', flag: '\u{1F1F5}\u{1F1F8}', minDigits: 9, maxDigits: 9),
    CountryCode(code: '+972', country: 'Israel', flag: '\u{1F1EE}\u{1F1F1}', minDigits: 9, maxDigits: 9),
    CountryCode(code: '+962', country: 'Jordan', flag: '\u{1F1EF}\u{1F1F4}', minDigits: 9, maxDigits: 9),
    CountryCode(code: '+20', country: 'Egypt', flag: '\u{1F1EA}\u{1F1EC}', minDigits: 10, maxDigits: 10),
    CountryCode(code: '+966', country: 'Saudi Arabia', flag: '\u{1F1F8}\u{1F1E6}', minDigits: 9, maxDigits: 9),
    CountryCode(code: '+971', country: 'UAE', flag: '\u{1F1E6}\u{1F1EA}', minDigits: 9, maxDigits: 9),
    CountryCode(code: '+974', country: 'Qatar', flag: '\u{1F1F6}\u{1F1E6}', minDigits: 8, maxDigits: 8),
    CountryCode(code: '+965', country: 'Kuwait', flag: '\u{1F1F0}\u{1F1FC}', minDigits: 8, maxDigits: 8),
    CountryCode(code: '+968', country: 'Oman', flag: '\u{1F1F4}\u{1F1F2}', minDigits: 8, maxDigits: 8),
    CountryCode(code: '+973', country: 'Bahrain', flag: '\u{1F1E7}\u{1F1ED}', minDigits: 8, maxDigits: 8),
    CountryCode(code: '+961', country: 'Lebanon', flag: '\u{1F1F1}\u{1F1E7}', minDigits: 7, maxDigits: 8),
    CountryCode(code: '+963', country: 'Syria', flag: '\u{1F1F8}\u{1F1FE}', minDigits: 9, maxDigits: 9),
    CountryCode(code: '+964', country: 'Iraq', flag: '\u{1F1EE}\u{1F1F6}', minDigits: 10, maxDigits: 10),
    CountryCode(code: '+90', country: 'Turkey', flag: '\u{1F1F9}\u{1F1F7}', minDigits: 10, maxDigits: 10),
    CountryCode(code: '+1', country: 'USA/Canada', flag: '\u{1F1FA}\u{1F1F8}', minDigits: 10, maxDigits: 10),
    CountryCode(code: '+44', country: 'UK', flag: '\u{1F1EC}\u{1F1E7}', minDigits: 10, maxDigits: 10),
    CountryCode(code: '+49', country: 'Germany', flag: '\u{1F1E9}\u{1F1EA}', minDigits: 10, maxDigits: 11),
    CountryCode(code: '+33', country: 'France', flag: '\u{1F1EB}\u{1F1F7}', minDigits: 9, maxDigits: 9),
  ];

  static CountryCode findByCode(String code) {
    return all.firstWhere((c) => c.code == code, orElse: () => all.first);
  }
}

/// Phone input card with country code selector.
class PhoneInputCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String submitButtonText;

  const PhoneInputCard({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    required this.isLoading,
    required this.onSubmit,
    required this.submitButtonText,
  });

  int _getMaxPhoneLength() {
    final country = CountryCode.findByCode(selectedCountryCode);
    return country.maxDigits + 1; // +1 for potential leading 0
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.061)),
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
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PhoneField(
              controller: phoneController,
              selectedCountryCode: selectedCountryCode,
              onCountryCodeChanged: onCountryCodeChanged,
              maxLength: _getMaxPhoneLength(),
            ),
            SizedBox(height: context.dynamicHeight(0.03)),
            PrimaryButton(
              text: submitButtonText,
              onPressed: isLoading ? null : onSubmit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final int maxLength;

  const _PhoneField({
    required this.controller,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final country = CountryCode.findByCode(selectedCountryCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.translate('auth_phone_number'),
          style: AppTextStyles.labelMedium.copyWith(color: context.textTertiary),
        ),
        SizedBox(height: context.dynamicHeight(0.007)),
        Row(
          children: [
            // Country Code Dropdown
            Container(
              decoration: BoxDecoration(
                color: context.themeSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountryCode,
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
                          Text(
                            c.code,
                            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => onCountryCodeChanged(value!),
                ),
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.021)),
            // Phone Input
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxLength),
                ],
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: t.translate('auth_phone_hint'),
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.iconDefault),
                  prefixIcon: Container(
                    margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
                    child: Icon(Icons.phone_outlined, color: AppColors.primaryColor, size: 22),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  filled: true,
                  fillColor: context.themeSurface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.04),
                    vertical: context.dynamicHeight(0.018),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.red500),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.translate('auth_phone_required');
                  }

                  String phone = value;
                  if (phone.startsWith('0')) phone = phone.substring(1);

                  if (phone.length < country.minDigits || phone.length > country.maxDigits) {
                    if (country.minDigits == country.maxDigits) {
                      return isArabic
                          ? 'رقم الهاتف يجب أن يكون ${country.minDigits} أرقام'
                          : 'Phone number must be ${country.minDigits} digits';
                    }
                    return isArabic
                        ? 'رقم الهاتف يجب أن يكون بين ${country.minDigits} و ${country.maxDigits} أرقام'
                        : 'Phone number must be ${country.minDigits}-${country.maxDigits} digits';
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
}
