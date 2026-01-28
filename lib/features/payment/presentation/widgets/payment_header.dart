import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Gradient header for payment upload screen.
class PaymentHeader extends StatelessWidget {
  const PaymentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: context.topPadding + context.dynamicHeight(0.03),
        left: context.dynamicWidth(0.04),
        right: context.dynamicWidth(0.04),
        bottom: context.dynamicHeight(0.039),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue600, AppColors.primaryColor],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(context.dynamicWidth(0.101)),
          bottomRight: Radius.circular(context.dynamicWidth(0.101)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.029)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: context.dynamicWidth(0.069),
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Invoice',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.069),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.dynamicHeight(0.005)),
                Text(
                  'Submit your payment receipt',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.035),
                    color: Colors.white70,
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
