import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Info card with payment instructions.
class PaymentInfoCard extends StatelessWidget {
  const PaymentInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.051)),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.051)),
        border: Border.all(color: AppColors.blue500.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.024)),
            decoration: BoxDecoration(
              color: AppColors.blue500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
            ),
            child: Icon(
              Icons.info_outline,
              color: AppColors.blue600,
              size: context.dynamicWidth(0.061),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Instructions',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.01)),
                Text(
                  'Please transfer the payment amount to the bank account below and upload your transfer receipt or invoice as proof of payment.',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.035),
                    color: AppColors.gray600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
