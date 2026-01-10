import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_strings.dart';

/// A customizable bottom sheet widget with consistent styling.
///
/// This widget provides a reusable bottom sheet design with support
/// for drag handle, title, and close button.
///
/// Example usage:
/// ```dart
/// AppBottomSheet.show(
///   context,
///   title: 'Select Option',
///   child: ListView(
///     children: options.map((o) => ListTile(title: Text(o))).toList(),
///   ),
/// );
/// ```
class AppBottomSheet extends StatelessWidget {
  /// The title of the bottom sheet.
  final String? title;

  /// The content of the bottom sheet.
  final Widget child;

  /// Whether to show the drag handle.
  final bool showDragHandle;

  /// Whether to show the close button.
  final bool showCloseButton;

  /// Whether the sheet is scrollable.
  final bool isScrollable;

  /// Minimum height of the sheet as fraction of screen height.
  final double? minHeight;

  /// Maximum height of the sheet as fraction of screen height.
  final double? maxHeight;

  /// Initial height of the sheet as fraction of screen height.
  final double? initialHeight;

  /// Padding for the content.
  final EdgeInsetsGeometry? padding;

  /// Background color.
  final Color? backgroundColor;

  /// Border radius for the sheet.
  final double borderRadius;

  /// Callback when close button is pressed.
  final VoidCallback? onClose;

  /// Action widget to display in the header.
  final Widget? action;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.isScrollable = true,
    this.minHeight,
    this.maxHeight,
    this.initialHeight,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 24,
    this.onClose,
    this.action,
  });

  /// Shows a modal bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isScrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? minHeight,
    double? maxHeight,
    double? initialHeight,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double borderRadius = 24,
    Widget? action,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: AppColors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        isScrollable: isScrollable,
        minHeight: minHeight,
        maxHeight: maxHeight,
        initialHeight: initialHeight,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        action: action,
        child: child,
      ),
    );
  }

  /// Shows a draggable scrollable bottom sheet.
  static Future<T?> showDraggable<T>(
    BuildContext context, {
    required Widget Function(BuildContext, ScrollController) builder,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
    double initialChildSize = 0.5,
    Color? backgroundColor,
    double borderRadius = 24,
    Widget? action,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: AppColors.transparent,
      builder: (context) => DraggableScrollableSheet(
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        initialChildSize: initialChildSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
            ),
            child: Column(
              children: [
                // Drag handle and header
                _SheetHeader(
                  title: title,
                  showDragHandle: showDragHandle,
                  showCloseButton: showCloseButton,
                  action: action,
                ),
                // Content
                Expanded(
                  child: builder(context, scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Shows a confirm/cancel bottom sheet.
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await show<bool>(
      context,
      title: title,
      child: _ConfirmSheet(
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? 0.9;
    final effectiveMinHeight = minHeight ?? 0.2;

    Widget content = Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * effectiveMaxHeight,
        minHeight: screenHeight * effectiveMinHeight,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _SheetHeader(
            title: title,
            showDragHandle: showDragHandle,
            showCloseButton: showCloseButton,
            onClose: onClose,
            action: action,
          ),
          // Content
          if (isScrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: child,
              ),
            )
          else
            Padding(
              padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: child,
            ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: content,
    );
  }
}

/// Header widget for the bottom sheet.
class _SheetHeader extends StatelessWidget {
  final String? title;
  final bool showDragHandle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final Widget? action;

  const _SheetHeader({
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.onClose,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        if (showDragHandle)
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

        // Title and close button
        if (title != null || showCloseButton)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                // Title
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontFamily: AppStrings.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),

                // Spacer if no title
                if (title == null) const Spacer(),

                // Action
                if (action != null) ...[
                  action!,
                  const SizedBox(width: 12),
                ],

                // Close button
                if (showCloseButton)
                  GestureDetector(
                    onTap: onClose ?? () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Confirm sheet content widget.
class _ConfirmSheet extends StatelessWidget {
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;

  const _ConfirmSheet({
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          style: TextStyle(
            fontFamily: AppStrings.fontFamily,
            fontSize: 14,
            color: AppColors.gray600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.gray300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  cancelText,
                  style: TextStyle(
                    fontFamily: AppStrings.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: confirmColor ?? AppColors.purple600,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: TextStyle(
                    fontFamily: AppStrings.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
