import 'package:flutter/material.dart';

import '../../../../core/core.dart';

/// Submit button for payment upload.
class PaymentSubmitButton extends StatelessWidget {
  final bool isUploading;
  final bool uploadSuccess;
  final bool canSubmit;
  final VoidCallback? onPressed;

  const PaymentSubmitButton({
    super.key,
    required this.isUploading,
    required this.uploadSuccess,
    required this.canSubmit,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        onTap: canSubmit ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: context.dynamicHeight(0.07),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
            gradient: canSubmit
                ? LinearGradient(
                    colors: uploadSuccess
                        ? [AppColors.green600, AppColors.emerald500]
                        : [AppColors.primaryColor, AppColors.tertiaryColor],
                  )
                : null,
            color: canSubmit ? null : AppColors.gray300,
            boxShadow: canSubmit
                ? [
                    BoxShadow(
                      color: uploadSuccess
                          ? AppColors.green600.withValues(alpha: 0.3)
                          : AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUploading)
                SizedBox(
                  width: context.dynamicWidth(0.051),
                  height: context.dynamicWidth(0.051),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(
                  uploadSuccess ? Icons.check : Icons.upload,
                  color: Colors.white,
                  size: context.dynamicWidth(0.051),
                ),
              SizedBox(width: context.dynamicWidth(0.029)),
              Text(
                uploadSuccess ? 'Continue' : 'Submit Payment',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
