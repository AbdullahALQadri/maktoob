import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_spacing.dart';
import '../cubit/payment_state.dart' show kMaxReceiptImages;

/// Receipt picker: up to [maxFiles] images shown as thumbnails, each with a
/// remove button, plus an "add" tile while there is room.
class UploadAreaWidget extends StatelessWidget {
  final List<PlatformFile> selectedFiles;
  final bool isUploading;
  final double uploadProgress;
  final VoidCallback onPickFile;
  final ValueChanged<int> onRemoveFile;
  final int maxFiles;

  const UploadAreaWidget({
    super.key,
    this.selectedFiles = const [],
    this.isUploading = false,
    this.uploadProgress = 0.0,
    required this.onPickFile,
    required this.onRemoveFile,
    this.maxFiles = kMaxReceiptImages,
  });

  static const double _thumbSize = 88;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.gray200),
      ),
      child: selectedFiles.isEmpty
          ? _EmptyState(onTap: isUploading ? null : onPickFile)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l
                      .translate('payment_receipts_count')
                      .replaceAll('{count}', '${selectedFiles.length}')
                      .replaceAll('{max}', '$maxFiles'),
                  key: const Key('payment_receipts_count'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
                AppSpacing.verticalSpace12,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (var i = 0; i < selectedFiles.length; i++)
                      _Thumb(
                        key: Key('payment_receipt_$i'),
                        file: selectedFiles[i],
                        size: _thumbSize,
                        onRemove: isUploading ? null : () => onRemoveFile(i),
                      ),
                    if (selectedFiles.length < maxFiles && !isUploading)
                      _AddTile(
                        key: const Key('payment_receipt_add'),
                        size: _thumbSize,
                        onTap: onPickFile,
                      ),
                  ],
                ),
                if (isUploading) ...[
                  AppSpacing.verticalSpace12,
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AppSpacing.borderRadiusSm,
                          child: LinearProgressIndicator(
                            value: uploadProgress.clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.gray200,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${(uploadProgress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onTap;

  const _EmptyState({this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return InkWell(
      key: const Key('payment_receipt_pick'),
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.lg),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primaryColor),
            AppSpacing.verticalSpace12,
            Text(
              l.translate('payment_upload_tap'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900),
            ),
            AppSpacing.verticalSpace4,
            Text(
              l.translate('payment_upload_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
            AppSpacing.verticalSpace8,
            Text(
              l.translate('payment_upload_formats'),
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final PlatformFile file;
  final double size;
  final VoidCallback? onRemove;

  const _Thumb({super.key, required this.file, required this.size, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final path = file.path;
    final Widget image;
    if (file.bytes != null) {
      image = Image.memory(file.bytes!, fit: BoxFit.cover, errorBuilder: _fallback);
    } else if (path != null) {
      image = Image.file(File(path), fit: BoxFit.cover, errorBuilder: _fallback);
    } else {
      image = _fallback(context, null, null);
    }
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(color: AppColors.gray200),
              ),
              child: ClipRRect(borderRadius: AppSpacing.borderRadiusMd, child: image),
            ),
          ),
          if (onRemove != null)
            PositionedDirectional(
              top: AppSpacing.xs,
              end: AppSpacing.xs,
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.translate('payment_receipt_remove'),
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: const Icon(Icons.close, size: 16, color: AppColors.red500),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _fallback(BuildContext context, Object? error, StackTrace? stack) {
    return const ColoredBox(
      color: AppColors.gray100,
      child: Center(child: Icon(Icons.image_outlined, color: AppColors.gray500)),
    );
  }
}

class _AddTile extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const _AddTile({super.key, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryColor),
            AppSpacing.verticalSpace4,
            Text(
              l.translate('payment_receipt_add'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
