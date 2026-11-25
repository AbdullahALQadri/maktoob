import 'package:flutter/material.dart';
import '../../../../../core/core.dart';


class WizardLabeledInput extends StatelessWidget {
  final String label;
  final Widget child;
  const WizardLabeledInput({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}



class WizardTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const WizardTextField({
    super.key,
    this.controller,
    this.maxLines = 1,
    required this.hintText,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.gray400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 14 : 16,
          vertical: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
                child: Icon(prefixIcon, color: AppColors.gray500, size: 22),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        border: _border(AppColors.gray200),
        enabledBorder: _border(AppColors.gray200),
        focusedBorder: _border(AppColors.primaryColor, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
