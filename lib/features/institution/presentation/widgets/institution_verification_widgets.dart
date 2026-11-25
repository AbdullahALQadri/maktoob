import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/institution_entity.dart';
import '../cubit/institution_cubit.dart';
import 'institution_widgets.dart';
export 'institution_documents_card.dart';

/// Status-specific notice above the profile: suspension, pending changes,
/// or what is still missing before review.
class InstitutionStatusNotice extends StatelessWidget {
  final InstitutionEntity institution;

  const InstitutionStatusNotice({super.key, required this.institution});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // Each notice: title, body, and the colour it is drawn in.
    final notices = <(String, String?, Color)>[];

    if (institution.isSuspended) {
      notices.add((
        t.translate('institution_suspended_title'),
        [t.translate('institution_suspended_body'), institution.suspensionReason]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .join('\n'),
        context.textSecondary,
      ));
    }
    if (institution.pendingChanges != null) {
      notices.add((
        t.translate('institution_changes_pending_title'),
        t.translate('institution_changes_pending'),
        AppColors.amber700,
      ));
    }
    if (institution.status == InstitutionStatus.pending && !institution.verification.isComplete) {
      notices.add((
        t.translate('institution_complete_verification_title'),
        t.translate('institution_complete_verification_body'),
        AppColors.amber700,
      ));
    }
    if (notices.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final (title, body, fg) in notices)
          Container(
            width: double.infinity,
            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: fg.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall.copyWith(color: fg)),
                if ((body ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(body!, style: AppTextStyles.bodySmall.copyWith(color: context.textPrimary)),
                ],
              ],
            ),
          ),
      ],
    );
  }
}


/// The review checklist (KYB): official name, sector, legal details,
/// certificate, the representative's verified identity and authority,
/// declaration, logo. Rows with an action open it while not done.
class InstitutionChecklistCard extends StatelessWidget {
  final InstitutionVerification verification;

  /// The representative's identity: opens the identity verification screen.
  final VoidCallback? onVerifyIdentity;

  /// Legal details or the representative role: opens the profile form.
  final VoidCallback? onEditProfile;

  /// Authorization letter (acting by mandate): opens the upload.
  final VoidCallback? onUploadAuthorization;

  const InstitutionChecklistCard({
    super.key,
    required this.verification,
    this.onVerifyIdentity,
    this.onEditProfile,
    this.onUploadAuthorization,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = <(String, bool, bool, VoidCallback?, String)>[
      (t.translate('institution_check_name'), verification.name, true, onEditProfile, 'name'),
      (t.translate('institution_check_sector'), verification.sector, true, onEditProfile, 'sector'),
      (t.translate('institution_check_legal_details'), verification.legalDetails, true, onEditProfile, 'legal_details'),
      (t.translate('institution_check_certificate'), verification.registrationDocument, true, null, 'registration_document'),
      (t.translate('institution_check_representative_identity'), verification.representativeIdentity, true, onVerifyIdentity, 'representative_identity'),
      (t.translate('institution_check_authorization'), verification.authorization, true, onUploadAuthorization ?? onEditProfile, 'authorization'),
      (t.translate('institution_check_declaration'), verification.declaration, true, onEditProfile, 'declaration'),
      (t.translate('institution_check_logo'), verification.logo, false, onEditProfile, 'logo'),
    ];

    return OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('institution_checklist_title'),
              style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
          const SizedBox(height: AppSpacing.sm),
          for (final (label, done, required, action, key) in items)
            InkWell(
              key: Key('institution_check_$key'),
              onTap: done ? null : action,
              borderRadius: AppSpacing.borderRadiusSm,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: done ? AppColors.green600 : context.iconSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        required ? label : '$label (${t.translate('institution_recommended')})',
                        style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
                      ),
                    ),
                    if (!done && action != null)
                      Icon(Icons.chevron_right_rounded, size: AppSpacing.iconSm, color: context.iconSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pick a PDF / image and upload it as [type] (e.g. `authorization_letter`).
Future<void> pickAndUploadInstitutionDocument(BuildContext context, InstitutionCubit cubit, String type) async {
  final t = AppLocalizations.of(context)!;
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
  );
  if (file == null || file.path == null) return;
  if ((await file.length() ?? 0) > 8 * 1024 * 1024) {
    if (context.mounted) {
      AppSnackBar.showError(context, message: t.translate('institution_document_too_large'));
    }
    return;
  }
  await cubit.uploadDocument(type: type, filePath: file.path!);
}
