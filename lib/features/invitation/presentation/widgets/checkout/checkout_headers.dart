import 'package:flutter/material.dart';
import '../../../../../core/core.dart';


class CheckoutPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const CheckoutPageHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: context.textSecondary),
        ),
      ],
    );
  }
}



class CheckoutSectionLabel extends StatelessWidget {
  final String text;
  const CheckoutSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.gray500,
        letterSpacing: 0.6,
      ),
    );
  }
}
