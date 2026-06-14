import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Flat white app bar used across the redesigned wizard + AI Design screens.
///
/// Layout (RTL):
///   [leadingClose]              [title]              [trailingForward]
///
/// - [title] is shown centered in primary color.
/// - When [showCloseButton] is true a close icon sits in the leading slot.
/// - When [onForward] is provided a forward arrow sits in the trailing slot;
///   otherwise the slot is empty (used by the result screen).
/// - When [titleLeading] is provided it replaces the leading slot entirely
///   (used by Image Result to show the "Maktoob" wordmark).
class MaktoobAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color titleColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final VoidCallback? onForward;
  final Widget? titleLeading;

  const MaktoobAppBar({
    super.key,
    required this.title,
    this.titleColor = AppColors.primary,
    this.titleFontSize = 18,
    this.titleFontWeight = FontWeight.w700,
    this.showCloseButton = true,
    this.onClose,
    this.onForward,
    this.titleLeading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final Widget? leading = titleLeading ??
        (showCloseButton
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.primary),
                onPressed: onClose ?? () => Navigator.of(context).pop(),
              )
            : null);

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leading,
      leadingWidth: titleLeading != null ? 110 : null,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: titleFontSize,
          fontWeight: titleFontWeight,
        ),
      ),
      actions: [
        if (onForward != null)
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded,
                color: AppColors.primary),
            onPressed: onForward,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.gray200),
      ),
    );
  }
}
