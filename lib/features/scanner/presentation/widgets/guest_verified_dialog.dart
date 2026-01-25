import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../domain/entities/check_in_guest_entity.dart';

class GuestVerifiedDialog extends StatelessWidget {
  final CheckInGuestEntity guest;
  final VoidCallback onClose;
  final VoidCallback onCheckIn;

  const GuestVerifiedDialog({
    super.key,
    required this.guest,
    required this.onClose,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isArabic = !(l?.isEnLocale ?? true);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 20,
      child: Container(
        width: context.dynamicWidth(0.85),
        padding: EdgeInsets.all(context.dynamicWidth(0.06)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.green600.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: context.dynamicWidth(0.22),
                    height: context.dynamicWidth(0.22),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.green600,
                          AppColors.green600.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green600.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: context.dynamicWidth(0.12),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: context.dynamicHeight(0.025)),

            // Status Text
            Text(
              isArabic ? 'تم التحقق' : 'VERIFIED',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.06),
                fontWeight: FontWeight.bold,
                color: AppColors.green600,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.008)),
            Text(
              isArabic ? 'الضيف مسجل في النظام' : 'Guest is registered in the system',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.032),
                color: AppColors.gray500,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),

            // Guest Details Card
            Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.04)),
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
                        width: context.dynamicWidth(0.14),
                        height: context.dynamicWidth(0.14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor,
                              AppColors.tertiaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            guest.name.isNotEmpty ? guest.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.dynamicWidth(0.06),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.dynamicWidth(0.035)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guest.name,
                              style: TextStyle(
                                fontSize: context.dynamicWidth(0.045),
                                fontWeight: FontWeight.bold,
                                color: AppColors.gray900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: context.dynamicHeight(0.005)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.dynamicWidth(0.02),
                                vertical: context.dynamicHeight(0.003),
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
                                  fontSize: context.dynamicWidth(0.028),
                                  fontWeight: FontWeight.w600,
                                  color: guest.isVip ? AppColors.amber500 : AppColors.blue500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.dynamicHeight(0.02)),
                  Container(
                    height: 1,
                    color: AppColors.gray200,
                  ),
                  SizedBox(height: context.dynamicHeight(0.015)),
                  // Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          Icons.group,
                          isArabic ? 'المرافقين' : 'Companions',
                          guest.companions.toString(),
                          isArabic,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: context.dynamicHeight(0.05),
                        color: AppColors.gray200,
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          context,
                          Icons.qr_code,
                          isArabic ? 'رمز QR' : 'QR Code',
                          guest.qrCode.length > 8
                              ? '${guest.qrCode.substring(0, 8)}...'
                              : guest.qrCode,
                          isArabic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: context.dynamicHeight(0.018),
                      ),
                      side: BorderSide(color: AppColors.gray400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isArabic ? 'إغلاق' : 'Close',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.038),
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.03)),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onCheckIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: context.dynamicHeight(0.018),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login_rounded,
                          size: context.dynamicWidth(0.05),
                        ),
                        SizedBox(width: context.dynamicWidth(0.02)),
                        Text(
                          isArabic ? 'تسجيل الدخول' : 'Check In',
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.038),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    bool isArabic,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: context.dynamicWidth(0.05),
          color: AppColors.gray500,
        ),
        SizedBox(height: context.dynamicHeight(0.005)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.028),
            color: AppColors.gray500,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.003)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
      ],
    );
  }
}
