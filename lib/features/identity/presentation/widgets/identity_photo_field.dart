import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';

/// One side of the identity document: take a photo or pick one from the
/// gallery. Large enough to read, kept under the server's 8 MB limit.
class IdentityPhotoField extends StatelessWidget {
  final String label;
  final String? path;
  final bool required;
  final String? errorText;
  final bool enabled;
  final int maxBytes;
  final ValueChanged<String?> onChanged;

  const IdentityPhotoField({
    super.key,
    required this.label,
    required this.path,
    required this.onChanged,
    this.required = false,
    this.errorText,
    this.enabled = true,
    this.maxBytes = 8 * 1024 * 1024,
  });

  Future<void> _pick(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(t.translate('identity_photo_camera')),
              onTap: () => Navigator.pop(sheet, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(t.translate('identity_photo_gallery')),
              onTap: () => Navigator.pop(sheet, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // Compressed on the phone: still sharp enough to read the document, and
    // well under 2 MB (some PHP deployments refuse larger uploads per file).
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2200,
      maxHeight: 2200,
      imageQuality: 85,
    );
    if (picked == null) return;
    final size = await File(picked.path).length();
    if (size > maxBytes) {
      if (context.mounted) AppSnackBar.showError(context, message: t.translate('identity_photo_too_large'));
      return;
    }
    onChanged(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final hasError = (errorText ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? label : '$label (${t.translate('identity_optional')})',
          style: AppTextStyles.labelMedium.copyWith(color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: enabled ? () => _pick(context) : null,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: hasError ? AppColors.red500 : context.borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: AlignmentDirectional.center,
            child: path == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, color: AppColors.primaryColor, size: AppSpacing.iconLg),
                      const SizedBox(height: AppSpacing.xs),
                      Text(t.translate('identity_photo_add'),
                          style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary)),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(path!), fit: BoxFit.cover),
                      PositionedDirectional(
                        top: AppSpacing.xs,
                        end: AppSpacing.xs,
                        child: IconButton.filledTonal(
                          tooltip: t.translate('common_delete'),
                          onPressed: enabled ? () => onChanged(null) : null,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(errorText!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.red500)),
        ],
      ],
    );
  }
}
