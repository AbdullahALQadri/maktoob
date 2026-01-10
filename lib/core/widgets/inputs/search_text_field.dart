import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

/// A search-specific text field widget with search icon and clear button.
///
/// This widget provides a specialized text input field for search functionality
/// with built-in search icon, clear button, and optional search debouncing.
///
/// Example usage:
/// ```dart
/// SearchTextField(
///   controller: searchController,
///   hintText: 'Search events...',
///   onChanged: (value) => handleSearch(value),
///   onClear: () => clearSearch(),
/// )
/// ```
class SearchTextField extends StatefulWidget {
  /// The controller for the text field.
  final TextEditingController? controller;

  /// The hint text to display when the field is empty.
  final String hintText;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the search is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Callback when the clear button is tapped.
  final VoidCallback? onClear;

  /// Callback when the search icon is tapped.
  final VoidCallback? onSearchTap;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to auto-focus this field.
  final bool autofocus;

  /// Border radius for the field.
  final double borderRadius;

  /// Height of the search field.
  final double height;

  /// Fill color for the field.
  final Color? fillColor;

  /// Border color.
  final Color? borderColor;

  /// Custom prefix icon.
  final IconData searchIcon;

  /// Whether to show the clear button when there's text.
  final bool showClearButton;

  /// Focus node for the field.
  final FocusNode? focusNode;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onSearchTap,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.borderRadius = 12,
    this.height = 48,
    this.fillColor,
    this.borderColor,
    this.searchIcon = Icons.search,
    this.showClearButton = true,
    this.focusNode,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.fillColor ?? AppColors.gray100,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _isFocused
              ? AppColors.purple600
              : (widget.borderColor ?? AppColors.gray200),
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Search icon
          GestureDetector(
            onTap: widget.onSearchTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                widget.searchIcon,
                size: 22,
                color: _isFocused ? AppColors.purple600 : AppColors.gray400,
              ),
            ),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
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
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          // Clear button
          if (widget.showClearButton && _hasText)
            GestureDetector(
              onTap: _handleClear,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}
