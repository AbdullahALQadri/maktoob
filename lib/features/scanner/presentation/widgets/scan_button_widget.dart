import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ScanButtonWidget extends StatelessWidget {
  final bool isScanning;
  final Animation<double> scanAnimation;
  final VoidCallback? onTap;

  const ScanButtonWidget({
    super.key,
    required this.isScanning,
    required this.scanAnimation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scanAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: isScanning ? null : onTap,
          child: Container(
            height: context.dynamicHeight(0.15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isScanning
                    ? [
                        AppColors.primaryColor.withValues(alpha: 0.7),
                        AppColors.tertiaryColor.withValues(alpha: 0.7),
                      ]
                    : [
                        AppColors.primaryColor,
                        AppColors.tertiaryColor,
                      ],
              ),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: isScanning ? 0.2 : 0.4),
                  blurRadius: context.dynamicWidth(0.051),
                  offset: Offset(0, context.dynamicHeight(0.012)),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scanning animation effect
                if (isScanning)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
                      child: CustomPaint(
                        painter: ScanLinePainter(scanAnimation.value),
                      ),
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isScanning ? Icons.qr_code_scanner : Icons.camera_alt,
                      color: Colors.white,
                      size: context.dynamicWidth(0.101),
                    ),
                    SizedBox(height: context.dynamicHeight(0.015)),
                    Text(
                      isScanning ? 'Scanning...' : 'Scan QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.dynamicWidth(0.051),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (isScanning)
                      Padding(
                        padding: EdgeInsets.only(top: context.dynamicHeight(0.01)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.3, end: 1.0),
                              duration: Duration(milliseconds: 400 + (index * 200)),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Container(
                                  width: context.dynamicWidth(0.021),
                                  height: context.dynamicWidth(0.021),
                                  margin: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.011)),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: value),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for scan line animation
class ScanLinePainter extends CustomPainter {
  final double progress;

  ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, 40),
      );

    final y = progress * size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, y - 20, size.width, 40),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
