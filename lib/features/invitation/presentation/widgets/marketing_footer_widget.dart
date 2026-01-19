import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/app_colors.dart';

/// Marketing footer widget for invitations
/// "Created with Maktoob - Create your invitation now"
class MarketingFooterWidget extends StatelessWidget {
  final bool compact;

  const MarketingFooterWidget({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (compact) {
      return _buildCompactFooter(screenWidth);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.035,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple50,
            AppColors.tertiaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(
          color: AppColors.purple100,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo placeholder
          Container(
            width: screenWidth * 0.08,
            height: screenWidth * 0.08,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.tertiaryColor],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: Center(
              child: Text(
                '📨',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),

          // Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Created with Maktoob',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              GestureDetector(
                onTap: _openMaktoobWebsite,
                child: Text(
                  'Create your invitation now',
                  style: TextStyle(
                    color: AppColors.tertiaryColor,
                    fontSize: screenWidth * 0.03,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFooter(double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(screenWidth * 0.015),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '📨',
            style: TextStyle(fontSize: screenWidth * 0.03),
          ),
          SizedBox(width: screenWidth * 0.015),
          GestureDetector(
            onTap: _openMaktoobWebsite,
            child: Text(
              'Created with Maktoob',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: screenWidth * 0.025,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMaktoobWebsite() async {
    final uri = Uri.parse('https://maktoob.app');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Silently fail
    }
  }
}
