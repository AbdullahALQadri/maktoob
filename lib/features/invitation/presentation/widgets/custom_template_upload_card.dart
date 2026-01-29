import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import 'custom_template_bottom_sheet.dart';

/// Custom template upload card for custom event types.
class CustomTemplateUploadCard extends StatelessWidget {
  final File? uploadedFile;
  final String? description;

  const CustomTemplateUploadCard({
    super.key,
    this.uploadedFile,
    this.description,
  });

  bool get _hasContent =>
      uploadedFile != null || (description?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCustomTemplateBottomSheet(context),
      child: Container(
        height: context.dynamicHeight(0.25),
        decoration: BoxDecoration(
          color: _hasContent
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : AppColors.gray50,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          border: Border.all(
            color: _hasContent ? AppColors.primaryColor : AppColors.gray300,
            width: _hasContent ? 2 : 1,
          ),
        ),
        child: _hasContent
            ? _buildContentPreview(context)
            : _buildUploadPlaceholder(context),
      ),
    );
  }

  Widget _buildContentPreview(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Stack(
      children: [
        if (uploadedFile != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
            child: Image.file(
              uploadedFile!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description,
                    size: context.dynamicWidth(0.12),
                    color: AppColors.primaryColor),
                SizedBox(height: context.dynamicHeight(0.01)),
                Text(
                  l?.translate('invitation_custom_description') ??
                      'Custom description',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        _buildSelectionIndicator(context),
        if (description != null && description!.isNotEmpty)
          _buildDescriptionOverlay(context),
        _buildEditButton(context),
      ],
    );
  }

  Widget _buildSelectionIndicator(BuildContext context) {
    return Positioned(
      top: context.dynamicWidth(0.021),
      right: context.dynamicWidth(0.021),
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.011)),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: context.dynamicWidth(0.04),
        ),
      ),
    );
  }

  Widget _buildDescriptionOverlay(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.021)),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(context.dynamicWidth(0.029)),
            bottomRight: Radius.circular(context.dynamicWidth(0.029)),
          ),
        ),
        child: Text(
          description!,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.dynamicWidth(0.029),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Positioned(
      bottom: description != null
          ? context.dynamicHeight(0.06)
          : context.dynamicWidth(0.021),
      right: context.dynamicWidth(0.021),
      child: Container(
        padding: EdgeInsets.all(context.dynamicWidth(0.021)),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: context.dynamicWidth(0.011),
            ),
          ],
        ),
        child: Icon(
          Icons.edit,
          size: context.dynamicWidth(0.04),
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.upload_file,
            size: context.dynamicWidth(0.101),
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        Text(
          l?.translate('invitation_upload_custom_template') ??
              'Upload your custom template',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: context.dynamicWidth(0.035), color: AppColors.amber600),
            SizedBox(width: context.dynamicWidth(0.011)),
            Text(
              l?.translate('invitation_extra_fees_may_apply') ??
                  'Extra fees may apply',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: AppColors.amber600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showCustomTemplateBottomSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final result = await AppBottomSheet.show<String>(
      context,
      title: l?.translate('invitation_custom_template') ?? 'Custom Template',
      subtitle: l?.translate('invitation_upload_or_describe') ??
          'Upload an image or describe your design',
      icon: Icons.design_services_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      child: BlocProvider.value(
        value: context.read<InvitationCubit>(),
        child: const CustomTemplateBottomSheetContent(),
      ),
    );

    if (result == 'pick_image' && context.mounted) {
      await _pickImageFromGallery(context);
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      // Request storage permission for Android < 13
      // On Android 13+, image_picker uses the system photo picker (no permission needed)
      final storageStatus = await ph.Permission.storage.request();
      debugPrint('Storage permission status: $storageStatus');

      // Also try photos permission for Android 13+
      if (!storageStatus.isGranted) {
        final photosStatus = await ph.Permission.photos.request();
        debugPrint('Photos permission status: $photosStatus');
      }

      // Always try the picker regardless of permission result
      // The system photo picker and ACTION_PICK intent can work without explicit permission
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image != null && context.mounted) {
        final cubit = context.read<InvitationCubit>();
        cubit.clearSelectedTemplate();
        cubit.uploadCustomTemplate(File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l?.translate('error_picking_image') ??
                  'Failed to open gallery. Please check app permissions.',
            ),
            action: SnackBarAction(
              label: l?.translate('open_settings') ?? 'Settings',
              onPressed: () => ph.openAppSettings(),
            ),
          ),
        );
      }
    }
  }
}
