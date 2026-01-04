import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress; // must be between 0.0 and 1.0
  final double width;
  final double height;
  final EdgeInsets padding;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.width = 250,
    this.height = 6,
    this.padding = const EdgeInsets.only(bottom: 30),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: padding,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor.withOpacity(.1),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: width * progress.clamp(0.0, 1.0),
            height: height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006E7F), Color(0xFFFB8801)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}
