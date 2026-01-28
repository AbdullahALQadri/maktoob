import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Header widget for venue screen with gradient background.
class VenueHeader extends StatelessWidget {
  final int venueCount;
  final bool showAddForm;
  final VoidCallback? onAddPressed;

  const VenueHeader({
    super.key,
    required this.venueCount,
    required this.showAddForm,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.02),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TitleSection(venueCount: venueCount),
          _AddButton(
            showAddForm: showAddForm,
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final int venueCount;

  const _TitleSection({required this.venueCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Venues',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.069),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(width: context.dynamicWidth(0.029)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.dynamicWidth(0.029),
            vertical: context.dynamicHeight(0.007),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$venueCount',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: context.dynamicWidth(0.035),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool showAddForm;
  final VoidCallback? onPressed;

  const _AddButton({required this.showAddForm, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        child: Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.029)),
          child: AnimatedRotation(
            turns: showAddForm ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: context.dynamicWidth(0.061),
            ),
          ),
        ),
      ),
    );
  }
}
