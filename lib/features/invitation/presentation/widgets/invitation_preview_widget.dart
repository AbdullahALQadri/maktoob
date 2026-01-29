import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';

/// Live preview widget for invitation
class InvitationPreviewWidget extends StatelessWidget {
  final GoldenEventType? eventType;
  final List<String> names;
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final String? location;
  final String? templateId;
  final bool showMarketingFooter;

  const InvitationPreviewWidget({
    super.key,
    this.eventType,
    this.names = const [],
    this.eventDate,
    this.eventTime,
    this.location,
    this.templateId,
    this.showMarketingFooter = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.width;
    final template = _getTemplateColors();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: template,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: template.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Stack(
          children: [
            // Decorative pattern
            Positioned(
              right: -screenWidth * 0.1,
              top: -screenWidth * 0.1,
              child: Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              left: -screenWidth * 0.15,
              bottom: -screenWidth * 0.15,
              child: Container(
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Event type emoji
                  if (eventType != null)
                    Text(
                      eventType!.emoji,
                      style: TextStyle(fontSize: screenWidth * 0.08),
                    ),

                  SizedBox(height: screenWidth * 0.02),

                  // Names
                  if (names.isNotEmpty && names.any((n) => n.isNotEmpty))
                    _buildNames(screenWidth)
                  else
                    Text(
                      'Your Event',
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                    ),

                  SizedBox(height: screenWidth * 0.03),

                  // Date and time
                  if (eventDate != null || eventTime != null)
                    _buildDateTime(screenWidth),

                  // Location
                  if (location != null && location!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: screenWidth * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: _getTextColor().withValues(alpha: 0.8),
                            size: screenWidth * 0.04,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            location!,
                            style: TextStyle(
                              fontSize: screenWidth * 0.032,
                              color: _getTextColor().withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Marketing footer
                  if (showMarketingFooter)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenWidth * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Text(
                        'Created with Maktoob',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          color: _getTextColor().withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNames(double screenWidth) {
    final validNames = names.where((n) => n.isNotEmpty).toList();

    if (validNames.isEmpty) {
      return const SizedBox.shrink();
    }

    if (validNames.length == 1) {
      return Text(
        validNames.first,
        style: TextStyle(
          fontSize: screenWidth * 0.055,
          fontWeight: FontWeight.bold,
          color: _getTextColor(),
        ),
        textAlign: TextAlign.center,
      );
    }

    // Two names (e.g., wedding)
    return Column(
      children: [
        Text(
          validNames[0],
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
        Text(
          '&',
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w400,
            color: _getTextColor().withValues(alpha: 0.8),
          ),
        ),
        Text(
          validNames[1],
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: _getTextColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTime(double screenWidth) {
    String dateTimeText = '';

    if (eventDate != null) {
      dateTimeText =
          '${eventDate!.day}/${eventDate!.month}/${eventDate!.year}';
    }

    if (eventTime != null) {
      final timeStr =
          '${eventTime!.hour.toString().padLeft(2, '0')}:${eventTime!.minute.toString().padLeft(2, '0')}';
      dateTimeText = dateTimeText.isNotEmpty
          ? '$dateTimeText at $timeStr'
          : timeStr;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          color: _getTextColor().withValues(alpha: 0.8),
          size: screenWidth * 0.04,
        ),
        SizedBox(width: screenWidth * 0.015),
        Text(
          dateTimeText,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: _getTextColor().withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Color> _getTemplateColors() {
    switch (templateId) {
      case 'elegant_gold':
        return const [Color(0xFFF59E0B), Color(0xFFD97706)];
      case 'modern_minimal':
        return const [Color(0xFF6B7280), Color(0xFF4B5563)];
      case 'floral_dream':
        return const [Color(0xFFF472B6), Color(0xFFEC4899)];
      case 'classic_white':
        return const [Color(0xFFF9FAFB), Color(0xFFF3F4F6)];
      case 'luxury_black':
        return const [Color(0xFF1F2937), Color(0xFF111827)];
      case 'colorful_joy':
        return const [Color(0xFF9333EA), Color(0xFFDB2777)];
      default:
        // Default to event type colors or brand colors
        return eventType?.gradientColors ??
            [AppColors.primaryColor, AppColors.tertiaryColor];
    }
  }

  Color _getTextColor() {
    // Use white text for dark backgrounds, dark text for light backgrounds
    switch (templateId) {
      case 'classic_white':
        return AppColors.gray900;
      case 'elegant_gold':
        return Colors.white;
      default:
        return Colors.white;
    }
  }
}
