import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import 'package:maktoob/core/widgets/loading/mk_spinner.dart';

class GuestImportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isActive;

  const GuestImportButton({super.key, 
    required this.icon,
    required this.label,
    required this.count,
    required this.onPressed,
    this.isLoading = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.02),
          horizontal: context.dynamicWidth(0.021),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : context.overlayBg,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          border: Border.all(
            color: isActive ? AppColors.primary : context.borderColor,
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: context.dynamicWidth(0.069),
                height: context.dynamicWidth(0.069),
                child: MkSpinner(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(
                icon,
                size: context.dynamicWidth(0.069),
                color: isActive ? AppColors.primary : context.textSecondary,
              ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : context.textTertiary,
              ),
            ),
            if (count > 0) ...[
              SizedBox(height: context.dynamicHeight(0.005)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.dynamicWidth(0.021),
                  vertical: context.dynamicHeight(0.002),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.024)),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.029),
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class ExcelFormatNotice extends StatelessWidget {
  final AppLocalizations? l;

  const ExcelFormatNotice({super.key, this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.029)),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: context.dynamicWidth(0.045),
            color: AppColors.amber700,
          ),
          SizedBox(width: context.dynamicWidth(0.021)),
          Expanded(
            child: Text(
              l?.translate('invitation_excel_format_notice') ??
                  'Excel format: Guest name, Phone number (+972 or +970)',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: AppColors.amber700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
