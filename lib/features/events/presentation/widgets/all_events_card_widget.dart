import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/event_entity.dart';

/// Card widget for displaying events in the View All Events screen
class AllEventsCardWidget extends StatelessWidget {
  final EventEntity event;
  final int index;
  final VoidCallback? onTap;

  const AllEventsCardWidget({
    super.key,
    required this.event,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
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
        children: [
          // Header with gradient accent
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getStatusGradient(),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19.w),
                topRight: Radius.circular(19.w),
              ),
            ),
            child: Row(
              children: [
                // Event icon
                Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(11.w),
                  ),
                  child: Icon(
                    _getEventIcon(),
                    color: Colors.white,
                    size: 23.w,
                  ),
                ),
                SizedBox(width: 11.w),
                // Event name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        event.type,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _buildStatusBadge(context),
              ],
            ),
          ),
          // Body with details
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              children: [
                // Date and venue row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.calendar_today_outlined,
                        event.date,
                        AppColors.blue500,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.access_time_outlined,
                        event.time,
                        AppColors.purple500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildInfoItem(
                  context,
                  Icons.location_on_outlined,
                  event.venue,
                  AppColors.orange500,
                ),
                SizedBox(height: 16.h),
                // Stats row
                _buildStatsRow(context),
                SizedBox(height: 12.h),
                // Response rate progress
                _buildProgressBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;

    switch (event.status) {
      case EventStatus.active:
        label = 'Ongoing';
        bgColor = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        break;
      case EventStatus.completed:
        label = 'Completed';
        bgColor = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        break;
      case EventStatus.draft:
        label = 'Draft';
        bgColor = Colors.white.withValues(alpha: 0.25);
        textColor = Colors.white;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15.w),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String text,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Icon(
            icon,
            size: 14.w,
            color: iconColor,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.gray700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 11.w,
        vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(11.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            event.invitations.toString(),
            'Invited',
            AppColors.blue500,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            event.responses.toString(),
            'Responses',
            AppColors.purple500,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            event.attending.toString(),
            'Attending',
            AppColors.green600,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
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
            fontSize: 10.sp,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      color: AppColors.gray200,
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final responseRate = event.responseRate / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Response Rate',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.gray500,
              ),
            ),
            Text(
              '${event.responseRate.toInt()}%',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        ClipRRect(
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
                  widthFactor: responseRate.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getStatusGradient(),
                      ),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getStatusGradient() {
    switch (event.status) {
      case EventStatus.active:
        return [AppColors.green600, AppColors.emerald500];
      case EventStatus.completed:
        return [AppColors.blue500, AppColors.cyan500];
      case EventStatus.draft:
        return [AppColors.amber500, AppColors.orange500];
    }
  }

  Color _getStatusColor() {
    switch (event.status) {
      case EventStatus.active:
        return AppColors.green600;
      case EventStatus.completed:
        return AppColors.blue500;
      case EventStatus.draft:
        return AppColors.amber500;
    }
  }

  IconData _getEventIcon() {
    final type = event.type.toLowerCase();
    if (type.contains('wedding') || type.contains('زفاف')) {
      return Icons.favorite;
    } else if (type.contains('birthday') || type.contains('عيد ميلاد')) {
      return Icons.cake;
    } else if (type.contains('conference') || type.contains('مؤتمر')) {
      return Icons.groups;
    } else if (type.contains('party') || type.contains('حفلة')) {
      return Icons.celebration;
    } else if (type.contains('meeting') || type.contains('اجتماع')) {
      return Icons.meeting_room;
    } else if (type.contains('graduation') || type.contains('تخرج')) {
      return Icons.school;
    } else {
      return Icons.event;
    }
  }
}
