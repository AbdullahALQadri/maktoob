import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/animations/staggered_slide_fade.dart';
import '../../domain/entities/recent_event_entity.dart';

class RecentEventCardWidget extends StatelessWidget {
  final RecentEventEntity event;
  final int index;
  final VoidCallback? onTap;

  const RecentEventCardWidget({
    super.key,
    required this.event,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredSlideFade(
      index: index,
      baseDelayMs: 500,
      staggerMs: 100,
      slideOffset: 30,
      child: Padding(
        padding: EdgeInsets.only(bottom: context.dynamicHeight(0.015)),
        child: GestureDetector(
          onTap: onTap,
          child: _buildEventCard(context),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              // Gradient icon container
              Container(
                width: context.dynamicWidth(0.12),
                height: context.dynamicWidth(0.12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: event.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.035)),
                ),
                child: Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: context.dynamicWidth(0.061),
                ),
              ),
              SizedBox(width: context.dynamicWidth(0.029)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.04),
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.dynamicHeight(0.002)),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: context.dynamicWidth(0.035),
                          color: context.iconDefault,
                        ),
                        SizedBox(width: context.dynamicWidth(0.011)),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.032),
                              color: context.iconSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Date badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.024),
                  vertical: context.dynamicHeight(0.007),
                ),
                decoration: BoxDecoration(
                  color: context.overlayBg,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: context.dynamicWidth(0.029),
                      color: context.textSecondary,
                    ),
                    SizedBox(width: context.dynamicWidth(0.011)),
                    Text(
                      _formatDate(event.date),
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.029),
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          // Stats row
          Row(
            children: [
              _buildEventStat(context, 'Invitations', event.invitations.toString(), AppColors.blue500),
              SizedBox(width: context.dynamicWidth(0.04)),
              _buildEventStat(context, 'Responses', event.responses.toString(), AppColors.purple500),
              SizedBox(width: context.dynamicWidth(0.04)),
              _buildEventStat(context, 'Attending', event.attending.toString(), AppColors.green600),
            ],
          ),
          SizedBox(height: context.dynamicHeight(0.02)),
          // Progress bars
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(
                context: context,
                label: 'Response Rate',
                value: event.responseRate,
                color: AppColors.purple500,
              ),
              SizedBox(height: context.dynamicHeight(0.01)),
              _buildProgressBar(
                context: context,
                label: 'Attending Rate',
                value: event.attendingRate,
                color: AppColors.green600,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventStat(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.045),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
              color: context.iconSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required BuildContext context,
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: context.iconSecondary,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: context.dynamicHeight(0.005)),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          builder: (context, animatedValue, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
              child: SizedBox(
                height: context.dynamicHeight(0.007),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: context.borderColor,
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: animatedValue,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(context.dynamicWidth(0.011)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    final parts = dateString.split('-');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[int.parse(parts[1]) - 1];
    final day = int.parse(parts[2]);
    return '$month $day';
  }
}
