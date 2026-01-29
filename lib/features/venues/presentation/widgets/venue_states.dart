import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Empty state widget when no venues are found.
class VenueEmptyState extends StatelessWidget {
  const VenueEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: context.dynamicWidth(0.16),
            color: context.borderColor,
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            'No venues found',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.045),
              color: context.iconSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.035),
              color: context.iconDefault,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget for venue loading failure.
class VenueErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const VenueErrorState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: context.dynamicWidth(0.16),
            color: context.borderColor,
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          Text(
            'Failed to load venues',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.045),
              color: context.iconSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.061),
                vertical: context.dynamicHeight(0.015),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(fontSize: context.dynamicWidth(0.035)),
            ),
          ),
        ],
      ),
    );
  }
}
