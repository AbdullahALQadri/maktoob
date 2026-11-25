import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../domain/entities/institution_entity.dart';
import '../cubit/institution_cubit.dart';
import 'institution_widgets.dart';
import 'institution_verification_widgets.dart';

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
