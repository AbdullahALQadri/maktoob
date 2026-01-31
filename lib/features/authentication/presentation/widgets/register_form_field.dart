import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';

/// Modern styled text field for forms.
class RegisterFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  const RegisterFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textTertiary,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.006)),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          obscureText: obscureText,
          validator: validator,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: context.iconDefault,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsetsDirectional.only(start: 14, end: 10),
              child: Icon(prefixIcon, color: AppColors.primaryColor, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 14),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            filled: true,
            fillColor: context.themeSurface,
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500, width: 2),
            ),
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.red500),
          ),
        ),
      ],
    );
  }
}

/// Dropdown field with consistent styling.
class RegisterDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const RegisterDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textTertiary,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.006)),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: context.iconDefault,
              fontWeight: FontWeight.w400,
            ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red500, width: 2),
            ),
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.red500),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
