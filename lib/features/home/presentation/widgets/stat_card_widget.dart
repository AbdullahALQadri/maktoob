import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/stat_entity.dart';

class StatCardWidget extends StatelessWidget {
  final StatEntity stat;
  final int index;

  const StatCardWidget({
    super.key,
    required this.stat,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
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
        child: Padding(
          padding: EdgeInsets.all(11.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: stat.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(9.w),
                ),
                child: Icon(
                  stat.icon,
                  color: Colors.white,
                  size: 17.w,
                ),
              ),
              SizedBox(height: 8.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                stat.label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
