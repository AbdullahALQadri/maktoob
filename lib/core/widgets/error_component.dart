import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/media_query_values.dart';

class ErrorComponent extends StatelessWidget {
  final VoidCallback? onPress;

  const ErrorComponent({super.key, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 150.0,
          color: AppColors.primaryColor,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'حدث خطأ ما',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          'الرجاء المحاولة مجددا',
          style: TextStyle(
            color: AppColors.icons,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          height: 55.0,
          width: context.width * 0.55,
          margin: const EdgeInsets.symmetric(vertical: 15.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              backgroundColor: AppColors.primaryColor,
              elevation: 500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
            child: const Text(
              'تحميل الصفحة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () {
              if (onPress != null) {
                onPress!();
              }
            },
          ),
        ),
      ],
    );
  }
}
