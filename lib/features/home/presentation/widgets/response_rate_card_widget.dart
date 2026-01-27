import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ResponseRateCardWidget extends StatefulWidget {
  final double responseRate;
  final int totalResponded;
  final int totalGuests;

  const ResponseRateCardWidget({
    super.key,
    required this.responseRate,
    required this.totalResponded,
    required this.totalGuests,
  });

  @override
  State<ResponseRateCardWidget> createState() => _ResponseRateCardWidgetState();
}

class _ResponseRateCardWidgetState extends State<ResponseRateCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
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
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(19.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.emerald500, AppColors.green600],
                        ),
                        borderRadius: BorderRadius.circular(11.w),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 19.w,
                      ),
                    ),
                    SizedBox(width: 11.w),
                    Text(
                      'Response Rate',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 9.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(widget.responseRate * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Progress bar with animation
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 12.h,
                    child: Stack(
                      children: [
                        // Background
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Progress
                        FractionallySizedBox(
                          widthFactor:
                              widget.responseRate * _progressController.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.emerald500,
                                  AppColors.green600
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8.h,
              children: [
                Text(
                  '${widget.totalResponded} of ${widget.totalGuests} guests responded',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.gray500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 13.w,
                      color: AppColors.gray400,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Updated 2h ago',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
