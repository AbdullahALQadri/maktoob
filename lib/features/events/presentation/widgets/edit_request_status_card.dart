import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/edit_request_entity.dart';

class EditRequestStatusCard extends StatelessWidget {
  final EditRequestEntity request;

  const EditRequestStatusCard({super.key, required this.request});

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(status: request.status, t: t),
              const Spacer(),
              Text(
                _formatDate(request.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${t.translate('edit_event_changes')}: ${request.changes.keys.join(', ')}',
            style: AppTextStyles.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          if (request.adminNote != null && request.adminNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.overlayBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment_outlined,
                      size: 16, color: context.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.adminNote!,
                      style: AppTextStyles.caption.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final EditRequestStatus status;
  final AppLocalizations t;

  const _StatusBadge({required this.status, required this.t});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case EditRequestStatus.pending:
        bgColor = AppColors.amber100;
        textColor = AppColors.amber700;
        label = t.translate('edit_event_request_pending');
        break;
      case EditRequestStatus.approved:
        bgColor = const Color(0xFFDCFCE7);
        textColor = AppColors.green600;
        label = t.translate('edit_event_request_approved');
        break;
      case EditRequestStatus.rejected:
        bgColor = const Color(0xFFFEE2E2);
        textColor = AppColors.red500;
        label = t.translate('edit_event_request_rejected');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
