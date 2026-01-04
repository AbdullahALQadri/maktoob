import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_font_weight.dart';
import '../../utils/app_strings.dart';

Widget textFieldWidget({
  required TextEditingController controller,
  required String hintText,
  TextInputType? textInputType,
  String? Function(String?)? validator,
  Widget? suffixIcon,
  Widget? prefixIcon,
  bool readOnly = false,
  int? maxLength,
  bool isPassword = false,
  TextInputType? keyboardType,
  TextAlign textAlign = TextAlign.start,
  VoidCallback? onSuffixTap,
}) {
  return TextFormField(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    controller: controller,
    keyboardType: keyboardType,
    validator: validator != null ? (value) => validator(value) : null,
    maxLength: maxLength,
    obscureText: isPassword,
    readOnly: readOnly,
    cursorColor: AppColors.primaryColor,
    textAlign: textAlign,
    decoration: InputDecoration(
      counterText: "",
      filled: true,

      hintText: hintText,
      hintStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        color: AppColors.black.withOpacity(0.6),
        fontSize: 16,
        fontWeight: AppFontWeight.medium,
      ),
      suffixIcon: suffixIcon != null
          ? Padding(
        padding: EdgeInsetsDirectional.only(end: 10),
        child: GestureDetector(
          onTap: onSuffixTap,
          child: SizedBox(
            height: 24,
            width: 24,
            child: suffixIcon,
          ),
        ),
      )
          : null,
      suffixIconColor: AppColors.black,
      prefixIcon: prefixIcon != null
          ? Padding(
        padding: EdgeInsetsDirectional.only(start: 5, end: 5),
        child: prefixIcon,
      )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 0.25),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 0.25),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 0.25),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.red,
          width: 0.25,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 0.25),
      ),
    ),
  );
}
