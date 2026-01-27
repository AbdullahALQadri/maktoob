import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: GestureDetector(
          onTap: onTap,
          child: _buildEventCard(context),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.w),
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
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: event.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(13.w),
                ),
                child: Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 23.w,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13.w,
                          color: AppColors.gray400,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            event.venue,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.gray500,
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
                  horizontal: 9.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(9.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 11.w,
                      color: AppColors.gray600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(event.date),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Stats row
          Row(
            children: [
              _buildEventStat(context, 'Invitations', event.invitations.toString(), AppColors.blue500),
              SizedBox(width: 15.w),
              _buildEventStat(context, 'Responses', event.responses.toString(), AppColors.purple500),
              SizedBox(width: 15.w),
              _buildEventStat(context, 'Attending', event.attending.toString(), AppColors.green600),
            ],
          ),
          SizedBox(height: 16.h),
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
              SizedBox(height: 8.h),
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
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.gray500,
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
                fontSize: 11.sp,
                color: AppColors.gray500,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          builder: (context, animatedValue, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4.w),
              child: SizedBox(
                height: 6.h,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: animatedValue,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4.w),
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
