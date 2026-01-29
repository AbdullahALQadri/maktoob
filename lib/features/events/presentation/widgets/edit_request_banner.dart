import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

class EditRequestBanner extends StatelessWidget {
  const EditRequestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.amber700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.translate('edit_event_admin_approval_required'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.amber700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
