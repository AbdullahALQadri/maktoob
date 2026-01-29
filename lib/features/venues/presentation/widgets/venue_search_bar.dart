import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Search bar widget for filtering venues.
class VenueSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const VenueSearchBar({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(fontSize: context.dynamicWidth(0.04)),
          decoration: InputDecoration(
            hintText: 'Search venues...',
            hintStyle: TextStyle(
              color: context.iconDefault,
              fontSize: context.dynamicWidth(0.04),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: context.iconDefault,
              size: context.dynamicWidth(0.056),
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: context.iconDefault,
                      size: context.dynamicWidth(0.051),
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.051),
              vertical: context.dynamicHeight(0.02),
            ),
          ),
        ),
      ),
    );
  }
}
