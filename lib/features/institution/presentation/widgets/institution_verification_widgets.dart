import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/institution_entity.dart';
import '../cubit/institution_cubit.dart';
import 'institution_widgets.dart';

/// Status-specific notice above the profile: suspension, pending changes,
/// or what is still missing before review.
class InstitutionStatusNotice extends StatelessWidget {
  final InstitutionEntity institution;

  const InstitutionStatusNotice({super.key, required this.institution});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final notices = <(String, String?, Color, Color)>[];

    if (institution.isSuspended) {
      notices.add((
        t.translate('institution_suspended_title'),
        [t.translate('institution_suspended_body'), institution.suspensionReason]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .join('\n'),
        AppColors.gray100,
        AppColors.gray700,
      ));
    }
    if (institution.pendingChanges != null) {
      notices.add((
        t.translate('institution_changes_pending_title'),
        t.translate('institution_changes_pending'),
        AppColors.amber50,
        AppColors.amber700,
      ));
    }
    if (institution.status == InstitutionStatus.pending && !institution.verification.isComplete) {
      notices.add((
        t.translate('institution_complete_verification_title'),
        t.translate('institution_complete_verification_body'),
        AppColors.amber50,
        AppColors.amber700,
      ));
    }
    if (notices.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final (title, body, bg, fg) in notices)
          Container(
            width: double.infinity,
            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            padding: const EdgeInsetsDirectional.all(AppSpacing.smd),
            decoration: BoxDecoration(
              color: bg,
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
                      color: done ? AppColors.green600 : AppColors.gray500,
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

/// Private verification documents: list, upload (PDF/image), delete before approval.
class InstitutionDocumentsCard extends StatelessWidget {
  final InstitutionEntity institution;
  final bool busy;

  const InstitutionDocumentsCard({super.key, required this.institution, this.busy = false});

  Future<void> _upload(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<InstitutionCubit>();

    final type = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Text(t.translate('institution_document_choose_type'), style: AppTextStyles.titleSmall),
            ),
            for (final type in kInstitutionDocumentTypes)
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(t.translate('institution_doc_$type')),
                onTap: () => Navigator.pop(sheet, type),
              ),
          ],
        ),
      ),
    );
    if (type == null || !context.mounted) return;
    await pickAndUploadInstitutionDocument(context, cubit, type);
  }

  Future<void> _delete(BuildContext context, InstitutionDocumentEntity doc) async {
    final t = AppLocalizations.of(context)!;
    final cubit = context.read<InstitutionCubit>();
    final ok = await AppDialog.showConfirmation(
      context,
      title: t.translate('institution_document_delete'),
      message: doc.originalName,
      confirmText: t.translate('common_delete'),
      cancelText: t.translate('common_cancel'),
    );
    if (ok) await cubit.deleteDocument(doc.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('institution_documents_title'),
              style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text(t.translate('institution_documents_privacy'),
              style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          if (institution.documents.isEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.sm),
              child: Text(t.translate('institution_documents_empty'),
                  style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary)),
            ),
          for (final doc in institution.documents)
            ListTile(
              key: Key('institution_doc_${doc.id}'),
              contentPadding: EdgeInsetsDirectional.zero,
              leading: Icon(
                doc.originalName.toLowerCase().endsWith('.pdf')
                    ? Icons.picture_as_pdf_outlined
                    : Icons.image_outlined,
                color: AppColors.primaryColor,
              ),
              title: Text(t.translate('institution_doc_${doc.type}')),
              subtitle: Text(doc.originalName, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: institution.canDeleteDocuments
                  ? IconButton(
                      tooltip: t.translate('institution_document_delete'),
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: busy ? null : () => _delete(context, doc),
                    )
                  : null,
            ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const Key('institution_upload_document'),
            onPressed: busy ? null : () => _upload(context),
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(t.translate('institution_document_upload')),
          ),
        ],
      ),
    );
  }
}
