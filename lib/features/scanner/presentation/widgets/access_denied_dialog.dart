import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/check_in_guest_entity.dart';

class AccessDeniedDialog extends StatelessWidget {
  final CheckInGuestEntity guest;
  final VoidCallback onClose;

  const AccessDeniedDialog({
    super.key,
    required this.guest,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 20,
      child: Container(
        width: 319.w,
        padding: EdgeInsets.all(23.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.red500.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 83.w,
                    height: 83.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.red500,
                          AppColors.red500.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.red500.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 45.w,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),

            // Status Text
            Text(
              t.translate('scanner_already_checked'),
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.red500,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              t.translate('scanner_already_checked_desc'),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

            // Guest Details Card
            Container(
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Guest Avatar and Name
                  Row(
                    children: [
                      Container(
                        width: 53.w,
                        height: 53.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.gray500,
                              AppColors.gray600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 13.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guest.name,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: guest.isVip
                                        ? AppColors.amber500.withValues(alpha: 0.15)
                                        : AppColors.blue500.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    guest.status,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: guest.isVip ? AppColors.amber500 : AppColors.blue500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.green600.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 11.w,
                                        color: AppColors.green600,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        t.translate('scanner_checked'),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.green600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 1,
                    color: AppColors.gray200,
                  ),
                  SizedBox(height: 12.h),
                  // Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          Icons.group,
                          t.translate('scanner_companions'),
                          guest.companions.toString(),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 41.h,
                        color: AppColors.gray200,
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          Icons.qr_code,
                          t.translate('scanner_qr_code'),
                          guest.qrCode.length > 8
                              ? '${guest.qrCode.substring(0, 8)}...'
                              : guest.qrCode,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red500,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 15.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  t.translate('common_close'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 19.w,
          color: AppColors.gray500,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.gray500,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }
}
