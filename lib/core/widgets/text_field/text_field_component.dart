import 'package:flutter/material.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_strings.dart';


Widget textFieldComponent({
  required TextEditingController controller,
  required String title,
  required String hintText,
  // required IconData icon,
  TextInputType? keyboardType,
  bool isPassword = false,
  String? Function(String?)? validator,
  bool readOnly = false,
  Function()? onPressedIcon,
  Widget? suffix,
  Widget? prefix,
  int? maxLength,
  int? maxLines,
  int? minLines,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontFamily: AppStrings.fontFamily,
          fontSize: 16,
          // fontSize: 16.sp,
        ),
      ),
      SizedBox(height: 5),
      TextFormField(

        // style: TextStyle( height: 0.2,),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        readOnly: readOnly,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        cursorColor: AppColors.primaryColor,
        decoration: InputDecoration(
          contentPadding: EdgeInsetsDirectional.all(10),
          // isDense: true,
          suffixIcon: suffix,
          prefixIcon: prefix,
          counterText: "",
          filled: true,
          // fillColor: AppColors.grey,
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: AppStrings.fontFamily,
            color: AppColors.black.withOpacity(0.3),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    ],
  );
}
