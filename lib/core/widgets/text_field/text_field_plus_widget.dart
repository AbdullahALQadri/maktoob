import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';
import '../../utils/app_font_weight.dart';

Widget textFieldPlusWidget({
  required TextEditingController controller,
  required String hintLabel,
  required String hintText,
  TextInputType? textInputType,
  String? Function(String?)? validator,
  Widget? suffixIcon,
  Widget? prefixIcon,
  bool readOnly = false,
  int? maxLength,
  bool isPassword = false,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    controller: controller,
    keyboardType: keyboardType,
    validator: (value) => validator!(value),
    maxLength: maxLength,
    obscureText: isPassword,
    readOnly: readOnly,
    cursorColor: AppColors.primaryColor,
    decoration: InputDecoration(
      counterText: "",
      fillColor: AppColors.white,
      filled: true,

      // labelText: hintLabel,
      label: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          hintLabel,
          style: TextStyle(
            fontFamily: AppStrings.fontFamily,
            // color: AppColors.greyText,
            fontSize: 14,
            fontWeight: AppFontWeight.regular,
          ),
        ),
      ),
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: EdgeInsetsDirectional.only(start: 30),

      labelStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        // color: AppColors.greyText,
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
      ),
      hintStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        // color: AppColors.greyText,
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
      ),

      // suffixIcon: suffixIcon,
      suffixIcon: Padding(
        padding: EdgeInsetsDirectional.only(end: 20),
        child: suffixIcon,
      ),
      suffixStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        // color: AppColors.greyText,
        fontSize: 14,
        fontWeight: AppFontWeight.regular,
      ),
      suffixIconColor: AppColors.black,
      prefixIcon: prefixIcon,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        // borderSide: BorderSide(width: 1, color: AppColors.greyText),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        // borderSide: BorderSide(width: 1, color: AppColors.greyText),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        // borderSide: BorderSide(width: 1, color: AppColors.greyText),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: AppColors.red, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        // borderSide: BorderSide(width: 1, color: AppColors.greyText),
      ),
    ),
  );
}
