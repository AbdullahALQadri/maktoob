import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';

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
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
                      width: context.dynamicWidth(0.1),
                      height: context.dynamicWidth(0.1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.emerald500, AppColors.green600],
                        ),
                        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: context.dynamicWidth(0.05),
                      ),
                    ),
                    SizedBox(width: context.dynamicWidth(0.03)),
                    Text(
                      'Response Rate',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.04),
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.025),
                    vertical: context.dynamicHeight(0.005),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(widget.responseRate * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.035),
                      fontWeight: FontWeight.bold,
                      color: AppColors.green600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            // Progress bar with animation
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: context.dynamicHeight(0.015),
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
            SizedBox(height: context.dynamicHeight(0.015)),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: context.dynamicHeight(0.01),
              children: [
                Text(
                  '${widget.totalResponded} of ${widget.totalGuests} guests responded',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.032),
                    color: AppColors.gray500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: context.dynamicWidth(0.035),
                      color: AppColors.gray400,
                    ),
                    SizedBox(width: context.dynamicWidth(0.01)),
                    Text(
                      'Updated 2h ago',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.03),
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
