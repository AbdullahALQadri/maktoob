import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Custom app bar for create invitation screen.
class CreateInvitationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;
  final String title;

  const CreateInvitationAppBar({
    super.key,
    required this.onBack,
    this.title = 'Create Invitation',
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.021)),
        child: GestureDetector(
          onTap: onBack,
          child: Container(
            width: context.dynamicWidth(0.101),
            height: context.dynamicWidth(0.101),
            decoration: BoxDecoration(
              color: context.overlayBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.borderColor,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: context.textPrimary,
              size: context.dynamicWidth(0.056),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: context.dynamicWidth(0.045),
        ),
      ),
      centerTitle: true,
    );
  }
}
