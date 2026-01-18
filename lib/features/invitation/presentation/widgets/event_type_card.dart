import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/models/invitation_draft_model.dart';

/// Card widget for event type selection
class EventTypeCard extends StatelessWidget {
  final GoldenEventType eventType;
  final bool isSelected;
  final VoidCallback? onTap;

  const EventTypeCard({
    super.key,
    required this.eventType,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: eventType.gradientColors,
                )
              : null,
          color: isSelected ? null : AppColors.gray100,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: isSelected
              ? null
              : Border.all(color: AppColors.gray200, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: eventType.gradientColors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji
                  Text(
                    eventType.emoji,
                    style: TextStyle(fontSize: screenWidth * 0.1),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  // Name
                  Text(
                    eventType.name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.gray800,
                    ),
                  ),
                  // Arabic name
                  Text(
                    eventType.nameAr,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      color: isSelected
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: screenWidth * 0.02,
                right: screenWidth * 0.02,
                child: Container(
                  width: screenWidth * 0.06,
                  height: screenWidth * 0.06,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: eventType.gradientColors.first,
                    size: screenWidth * 0.04,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
