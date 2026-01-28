import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../../../../core/services/permissions/permission_service.dart';
import '../cubit/invitation_cubit.dart';

/// Bottom sheet content for custom template upload and description.
class CustomTemplateBottomSheetContent extends StatefulWidget {
  const CustomTemplateBottomSheetContent({super.key});

  @override
  State<CustomTemplateBottomSheetContent> createState() =>
      _CustomTemplateBottomSheetContentState();
}

class _CustomTemplateBottomSheetContentState
    extends State<CustomTemplateBottomSheetContent> {
  File? _selectedFile;
  final _descriptionController = TextEditingController();
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<InvitationCubit>().state;
    _selectedFile = state.uploadedTemplateFile;
    _descriptionController.text = state.uploadedTemplateDescription ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canConfirm =>
      _selectedFile != null || _descriptionController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadArea(context, l),
        SizedBox(height: context.dynamicHeight(0.025)),
        _buildDescriptionSection(context, l),
        SizedBox(height: context.dynamicHeight(0.02)),
        _buildFeeNotice(context, l),
        SizedBox(height: context.dynamicHeight(0.03)),
        _buildConfirmButton(context, l),
        if (!_canConfirm) _buildHelpText(context, l),
        SizedBox(height: context.dynamicHeight(0.02)),
      ],
    );
  }

  Widget _buildUploadArea(BuildContext context, AppLocalizations? l) {
    return GestureDetector(
      onTap: _isPickingImage ? null : _pickImage,
      child: Container(
        height: context.dynamicHeight(0.22),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          border: Border.all(
            color:
                _selectedFile != null ? AppColors.primaryColor : AppColors.gray300,
            width: _selectedFile != null ? 2 : 1,
          ),
        ),
        child: _isPickingImage
            ? const Center(child: CircularProgressIndicator())
            : _selectedFile != null
                ? _buildImagePreview(context)
                : _buildUploadPlaceholder(context, l),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
          child: Image.file(
            _selectedFile!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: context.dynamicWidth(0.021),
          right: context.dynamicWidth(0.021),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFile = null),
            child: Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.011)),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: context.dynamicWidth(0.04),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context, AppLocalizations? l) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload,
            size: context.dynamicWidth(0.12), color: AppColors.gray400),
        SizedBox(height: context.dynamicHeight(0.015)),
        Text(
          l?.translate('invitation_tap_to_upload') ?? 'Tap to upload image',
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: context.dynamicWidth(0.04),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.005)),
        Text(
          l?.translate('invitation_image_format') ?? 'PNG, JPG (max 1920x1920)',
          style: TextStyle(
            color: AppColors.gray400,
            fontSize: context.dynamicWidth(0.029),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, AppLocalizations? l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l?.translate('invitation_description_optional') ??
              'Description (optional)',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.035),
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.01)),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(fontSize: context.dynamicWidth(0.04)),
          decoration: InputDecoration(
            hintText: l?.translate('invitation_describe_design') ??
                'Describe what you want in the design...',
            hintStyle: TextStyle(
                color: AppColors.gray400,
                fontSize: context.dynamicWidth(0.035)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.029)),
              borderSide: BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.029)),
              borderSide: BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.029)),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildFeeNotice(BuildContext context, AppLocalizations? l) {
    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.029)),
      decoration: BoxDecoration(
        color: AppColors.amber50,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.021)),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: AppColors.amber600, size: context.dynamicWidth(0.051)),
          SizedBox(width: context.dynamicWidth(0.021)),
          Expanded(
            child: Text(
              l?.translate('invitation_design_fee_notice') ??
                  'Design description may incur additional fees.',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.029),
                color: AppColors.amber700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, AppLocalizations? l) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: _getButtonText(l),
        onPressed: _canConfirm ? _onConfirm : null,
      ),
    );
  }

  Widget _buildHelpText(BuildContext context, AppLocalizations? l) {
    return Column(
      children: [
        SizedBox(height: context.dynamicHeight(0.01)),
        Center(
          child: Text(
            l?.translate('invitation_please_upload_or_describe') ??
                'Please upload an image or enter a description',
            style: TextStyle(
              fontSize: context.dynamicWidth(0.029),
              color: AppColors.gray500,
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonText(AppLocalizations? l) {
    if (_selectedFile != null) {
      return l?.translate('invitation_upload') ?? 'Upload';
    } else if (_descriptionController.text.trim().isNotEmpty) {
      return l?.translate('invitation_add_description') ?? 'Add Description';
    }
    return l?.translate('invitation_confirm') ?? 'Confirm';
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final hasPermission = await PermissionService.instance.hasPermission(
        AppPermission.photos,
      );

      if (!hasPermission) {
        final granted = await PermissionService.instance.requestPermission(
          AppPermission.photos,
        );

        if (!granted) {
          final isPermanentlyDenied = await PermissionService.instance
              .isPermanentlyDenied(AppPermission.photos);

          if (mounted) {
            final l = AppLocalizations.of(context);
            if (isPermanentlyDenied) {
              _showPermissionDeniedDialog();
            } else {
              AppSnackBar.showWarning(
                context,
                message: l?.translate('invitation_allow_photos_access') ??
                    'Please allow access to photos',
              );
            }
          }
          return;
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() => _selectedFile = File(image.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        final l = AppLocalizations.of(context);
        AppSnackBar.showError(
          context,
          message:
              '${l?.translate('invitation_failed_pick_image') ?? 'Failed to pick image'}: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l?.translate('invitation_photos_permission_required') ??
            'Photos Permission Required'),
        content: Text(
          l?.translate('invitation_photos_permission_message') ??
              'The app needs access to photos to upload custom template. Please grant permission from app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l?.translate('common_cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await PermissionService.instance.openAppSettings();
            },
            child:
                Text(l?.translate('invitation_open_settings') ?? 'Open Settings'),
          ),
        ],
      ),
    );
  }

  void _onConfirm() {
    final cubit = context.read<InvitationCubit>();

    cubit.clearSelectedTemplate();

    if (_selectedFile != null) {
      cubit.uploadCustomTemplate(_selectedFile!);
    } else {
      cubit.clearUploadedTemplateFile();
    }

    if (_descriptionController.text.trim().isNotEmpty) {
      cubit.setCustomTemplateDescription(_descriptionController.text.trim());
    } else {
      cubit.clearCustomTemplateDescription();
    }

    Navigator.pop(context);
  }
}
