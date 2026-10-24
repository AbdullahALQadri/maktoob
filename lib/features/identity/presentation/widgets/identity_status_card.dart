import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../institution/presentation/widgets/institution_widgets.dart';
import '../../domain/entities/identity_entities.dart';

/// Not verified / under review / verified / rejected pill.
class IdentityStatusBadge extends StatelessWidget {
  final IdentityStatus status;

  const IdentityStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final (Color bg, Color fg) = switch (status) {
      IdentityStatus.verified => (AppColors.green50, AppColors.green600),
      IdentityStatus.rejected => (AppColors.red100, AppColors.red500),
      IdentityStatus.pending => (AppColors.amber50, AppColors.amber700),
      IdentityStatus.none => (AppColors.gray100, AppColors.gray700),
    };
    return Container(
      key: Key('identity_status_${status.name}'),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.smd, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderRadiusRound,
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        t.translate(status.labelKey),
        style: AppTextStyles.labelMedium.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// The client's identity verification at a glance (profile and the
/// verification screen). [onTap] opens the verification screen.
class IdentityStatusCard extends StatelessWidget {
  final IdentityStateEntity identity;
  final VoidCallback? onTap;

  /// Country names for the document line (optional).
  final String Function(String? code)? countryName;

  const IdentityStatusCard({super.key, required this.identity, this.onTap, this.countryName});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = !t.isEnLocale;
    final legalName = identity.legalName;
    final document = identity.document;

    final body = switch (identity.status) {
      IdentityStatus.none => t.translate('identity_status_none_body'),
      IdentityStatus.pending => t.translate('identity_status_pending_body'),
      IdentityStatus.rejected => t.translate('identity_status_rejected_body'),
      IdentityStatus.verified => null,
    };

    final card = OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                identity.isVerified ? Icons.verified_user_rounded : Icons.badge_outlined,
                color: identity.isVerified ? AppColors.green600 : AppColors.primaryColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  t.translate('identity_title'),
                  style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary),
                ),
              ),
              IdentityStatusBadge(status: identity.status),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right_rounded, color: context.iconSecondary),
              ],
            ],
          ),
          if (identity.required && !identity.isVerified) ...[
            const SizedBox(height: AppSpacing.smd),
            _Banner(
              key: const Key('identity_required_banner'),
              text: [t.translate('identity_required_banner'), identity.requiredReason]
                  .whereType<String>()
                  .where((s) => s.isNotEmpty)
                  .join('\n'),
            ),
          ],
          if (body != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(body, style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary, height: 1.5)),
          ],
          if (identity.status == IdentityStatus.rejected && (identity.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${t.translate('identity_rejection_reason')}: ${identity.rejectionReason}',
              key: const Key('identity_rejection_reason'),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.red500),
            ),
          ],
          if (identity.isVerified && legalName != null) ...[
            const SizedBox(height: AppSpacing.smd),
            InfoRow(label: t.translate('identity_legal_name'), value: legalName.display(isArabic)),
            if (legalName.display(!isArabic) != legalName.display(isArabic))
              InfoRow(label: t.translate('identity_legal_name_other'), value: legalName.display(!isArabic)),
            if (document != null)
              InfoRow(
                label: t.translate('identity_document'),
                value: [
                  t.translate('identity_doc_type_${document.type}'),
                  if ((document.country ?? '').isNotEmpty) countryName?.call(document.country) ?? document.country,
                  if ((document.last4 ?? '').isNotEmpty) '•••• ${document.last4}',
                ].join(' · '),
              ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.translate('identity_legal_name_locked_note'),
              style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
            ),
          ],
          if (identity.isVerified && identity.hasPending) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              t.translate('identity_new_submission_pending'),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.amber700),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      key: const Key('identity_status_card'),
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusLg,
      child: card,
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;

  const _Banner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.amber700.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.amber700, size: AppSpacing.iconSm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
