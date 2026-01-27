import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class UploadAreaWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final bool isUploading;
  final bool uploadSuccess;
  final double uploadProgress;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final Widget? successWidget;
  final Widget? uploadingWidget;

  const UploadAreaWidget({
    super.key,
    this.selectedFile,
    this.isUploading = false,
    this.uploadSuccess = false,
    this.uploadProgress = 0.0,
    required this.onPickFile,
    required this.onRemoveFile,
    this.successWidget,
    this.uploadingWidget,
  });

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: uploadSuccess
              ? AppColors.green600.withValues(alpha: 0.5)
              : selectedFile != null
                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                  : AppColors.gray200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: uploadSuccess
          ? (successWidget ?? _buildSuccessState())
          : isUploading
              ? (uploadingWidget ?? _buildUploadingState())
              : selectedFile != null
                  ? _buildFileSelectedState()
                  : _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: onPickFile,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blue500.withValues(alpha: 0.1),
                    AppColors.purple500.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Click to select',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'or drag and drop your file here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'PDF, PNG, JPG up to 10MB',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectedState() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purple500, AppColors.pink500],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.insert_drive_file,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedFile?.name ?? 'Unknown file',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(selectedFile?.size ?? 0),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemoveFile,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.red500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.close,
                  color: AppColors.red500,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: onPickFile,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: AppColors.gray600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Choose different file',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingState() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blue500, AppColors.purple500],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedFile?.name ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${(uploadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Modern gradient progress bar
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: uploadProgress.clamp(0.0, 1.0),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.tertiaryColor],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Upload status text
        Text(
          'Please wait while we upload your file...',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.green100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 48,
            color: AppColors.green600,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Upload Successful!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your payment receipt has been uploaded',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.green50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.green600.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                color: AppColors.green600,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  selectedFile?.name ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.green600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
