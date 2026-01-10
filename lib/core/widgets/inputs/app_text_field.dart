import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

/// A reusable text field widget with consistent styling.
///
/// This widget provides a customizable text input field with support for
/// validation, icons, password visibility toggle, and various input types.
///
/// Example usage:
/// ```dart
/// AppTextField(
///   controller: emailController,
///   hintText: 'Enter your email',
///   prefixIcon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value?.isEmpty ?? true ? 'Email is required' : null,
/// )
/// ```
class AppTextField extends StatefulWidget {
  /// The controller for the text field.
  final TextEditingController? controller;

  /// The hint text to display when the field is empty.
  final String? hintText;

  /// The label text to display above the field.
  final String? labelText;

  /// The keyboard type for the text field.
  final TextInputType? keyboardType;

  /// The text input action for the keyboard.
  final TextInputAction? textInputAction;

  /// Validator function for form validation.
  final String? Function(String?)? validator;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the field is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Callback when the field receives focus.
  final VoidCallback? onTap;

  /// Whether this is a password field.
  final bool isPassword;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to auto-focus this field.
  final bool autofocus;

  /// Maximum number of lines.
  final int maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum length of the text.
  final int? maxLength;

  /// Prefix icon to display.
  final IconData? prefixIcon;

  /// Custom prefix widget.
  final Widget? prefix;

  /// Suffix icon to display.
  final IconData? suffixIcon;

  /// Custom suffix widget.
  final Widget? suffix;

  /// Callback when suffix icon is tapped.
  final VoidCallback? onSuffixTap;

  /// Text alignment.
  final TextAlign textAlign;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node for the field.
  final FocusNode? focusNode;

  /// Initial value if no controller is provided.
  final String? initialValue;

  /// Border radius for the field.
  final double borderRadius;

  /// Content padding.
  final EdgeInsetsGeometry? contentPadding;

  /// Fill color for the field.
  final Color? fillColor;

  /// Border color when not focused.
  final Color? borderColor;

  /// Border color when focused.
  final Color? focusedBorderColor;

  /// Whether to show character counter.
  final bool showCounter;

  /// Error text to display below the field.
  final String? errorText;

  /// Helper text to display below the field.
  final String? helperText;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.isPassword = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixTap,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.focusNode,
    this.initialValue,
    this.borderRadius = 12,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.showCounter = false,
    this.errorText,
    this.helperText,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontFamily: AppStrings.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          initialValue: widget.controller == null ? widget.initialValue : null,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          obscureText: widget.isPassword ? _obscureText : false,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          textAlign: widget.textAlign,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          cursorColor: AppColors.purple600,
          style: TextStyle(
            fontFamily: AppStrings.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.gray900,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontFamily: AppStrings.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray400,
            ),
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperStyle: TextStyle(
              fontFamily: AppStrings.fontFamily,
              fontSize: 12,
              color: AppColors.gray500,
            ),
            counterText: widget.showCounter ? null : '',
            filled: true,
            fillColor: widget.fillColor ?? AppColors.gray100,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: _buildPrefixIcon(),
            suffixIcon: _buildSuffixIcon(),
            border: _buildBorder(AppColors.gray200),
            enabledBorder: _buildBorder(widget.borderColor ?? AppColors.gray200),
            focusedBorder: _buildBorder(
              widget.focusedBorderColor ?? AppColors.purple600,
              width: 1.5,
            ),
            errorBorder: _buildBorder(AppColors.red500),
            focusedErrorBorder: _buildBorder(AppColors.red500, width: 1.5),
            disabledBorder: _buildBorder(AppColors.gray200),
          ),
        ),
      ],
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefix != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        child: widget.prefix,
      );
    }
    if (widget.prefixIcon != null) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
        child: Icon(
          widget.prefixIcon,
          size: 22,
          color: _isFocused ? AppColors.purple600 : AppColors.gray400,
        ),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 22,
            color: AppColors.gray400,
          ),
        ),
      );
    }
    if (widget.suffix != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: widget.suffix,
        ),
      );
    }
    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: Icon(
            widget.suffixIcon,
            size: 22,
            color: AppColors.gray400,
          ),
        ),
      );
    }
    return null;
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
