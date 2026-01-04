import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_font_weight.dart';
import '../../utils/app_strings.dart';




Widget searchTextFieldWidget({
  required TextEditingController controller,
  required String hintText,
  Widget? suffix,
  Widget? prefix,
  void Function()? onTap,
  void Function(String)? onSubmitted,
}) {
  return TextFormField(
    enabled: true,
    onTap: onTap,
    onFieldSubmitted: onSubmitted,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    controller: controller,
    keyboardType: TextInputType.text,
    cursorColor: AppColors.primaryColor,
    minLines: 1,
    maxLines: 1,
    decoration: InputDecoration(
      // contentPadding: EdgeInsetsDirectional.only(
      //   end: 10.w
      // ),
      // contentPadding: EdgeInsetsDirectional.all(10.w),
      contentPadding: EdgeInsetsDirectional.all(10),
      fillColor: Colors.white,
      filled: true,
      hintText: hintText,
      suffixIcon: suffix,
      prefixIcon: prefix,
      hintStyle: TextStyle(
        fontFamily: AppStrings.fontFamily,
        // color: AppColors.greyText,
        fontSize: 14,
        // fontSize: 14.sp,
        fontWeight: AppFontWeight.regular,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          // color: AppColors.borderColor1,
          // color: AppColors.borderColor1,
          width: 0.50,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          // color: AppColors.borderColor1,
          width: 0.50,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          // color: AppColors.borderColor1,
          width: 0.50,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.red,
          width: 0.50,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          // color: AppColors.borderColor1,
          width: 0.50,
        ),
      ),
    ),
  );
}
