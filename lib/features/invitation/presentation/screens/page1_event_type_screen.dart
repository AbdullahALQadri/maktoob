import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';
import '../../../../core/services/permissions/permission_service.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/wizard_step_header.dart';

/// Page 1: Event Type and Template Selection
class Page1EventTypeScreen extends StatefulWidget {
  const Page1EventTypeScreen({super.key});

  @override
  State<Page1EventTypeScreen> createState() => _Page1EventTypeScreenState();
}

class _Page1EventTypeScreenState extends State<Page1EventTypeScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: Column(
            children: [
              // Step Header
              WizardStepHeader(
                currentStep: 1,
                totalSteps: 7,
                title: l?.translate('invitation_step1_title') ?? 'Choose Event Type',
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 19.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // Section: Event Type Dropdown
                      _buildSectionTitle(context, l?.translate('invitation_event_type') ?? 'Event Type'),
                      SizedBox(height: 12.h),
                      _buildEventTypeDropdown(context, state, l),

                      // Custom event type name field (if custom selected)
                      if (state.selectedEventType?.isCustom == true) ...[
                        SizedBox(height: 16.h),
                        _buildCustomEventNameField(context, state, l),
                      ],

                      // Section: Templates (shown when event type is selected)
                      if (state.selectedEventType != null) ...[
                        SizedBox(height: 24.h),
                        _buildSectionTitle(context, l?.translate('invitation_choose_template') ?? 'Choose Template'),
                        SizedBox(height: 12.h),
                        _buildTemplatesSection(context, state, l),
                      ],

                      SizedBox(height: 97.h),
                    ],
                  ),
                ),
              ),

              // Bottom Button
              _buildBottomBar(context, state, l),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.gray800,
      ),
    );
  }

  Widget _buildEventTypeDropdown(BuildContext context, InvitationState state, AppLocalizations? l) {
    // Custom event type constant used for dropdown matching
    const customEventType = EventTypeModel(
      id: null,
      name: 'Custom',
      nameAr: 'مخصص',
      emoji: '➕',
    );

    // Build dropdown items
    final List<DropdownMenuItem<EventTypeModel>> items = [];
    final isEnglish = l?.isEnLocale ?? false;

    // Add custom option first
    items.add(
      DropdownMenuItem<EventTypeModel>(
        value: customEventType,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '➕',
              style: TextStyle(fontSize: 23.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                l?.translate('invitation_custom') ?? 'Custom',
                style: TextStyle(
                  fontSize: 17.sp,
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    // Add other event types
    for (final eventType in state.availableEventTypes) {
      items.add(
        DropdownMenuItem<EventTypeModel>(
          value: eventType,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                eventType.emoji ?? '📅',
                style: TextStyle(fontSize: 23.sp),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  isEnglish ? eventType.name : eventType.nameAr,
                  style: TextStyle(
                    fontSize: 17.sp,
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Determine the dropdown value:
    // If the selected event type is custom (id == null), use our constant customEventType
    // Otherwise, find the matching item from availableEventTypes
    EventTypeModel? dropdownValue;
    if (state.selectedEventType != null) {
      if (state.selectedEventType!.isCustom) {
        // Use the constant custom event type for matching
        dropdownValue = customEventType;
      } else {
        // Find the matching event type from available types
        dropdownValue = state.availableEventTypes.firstWhere(
          (e) => e.id == state.selectedEventType!.id,
          orElse: () => state.selectedEventType!,
        );
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 4.h,
      ),
      constraints: BoxConstraints(
        minHeight: 53.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11.w),
        border: Border.all(color: AppColors.gray300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EventTypeModel>(
          value: dropdownValue,
          hint: Text(
            l?.translate('invitation_select_event_type') ?? 'Select event type',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 15.sp,
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray500, size: 23.w),
          iconSize: 23.w,
          itemHeight: math.max(56.0, 65.h),
          menuMaxHeight: math.max(300.0, 406.h),
          borderRadius: BorderRadius.circular(11.w),
          dropdownColor: Colors.white,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.gray700,
          ),
          items: items,
          onChanged: (eventType) {
            if (eventType != null) {
              context.read<InvitationCubit>().selectEventType(eventType);
              // Load templates for this event type
              if (!eventType.isCustom) {
                context
                    .read<InvitationCubit>()
                    .loadTemplatesForEventType(eventType.id!);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildCustomEventNameField(
      BuildContext context, InvitationState state, AppLocalizations? l) {
    return AppTextField(
      hintText: l?.translate('invitation_enter_event_type_name') ?? 'Enter event type name',
      prefixIcon: Icons.edit,
      initialValue: state.customEventTypeName,
      onChanged: (value) {
        context.read<InvitationCubit>().setCustomEventTypeName(value);
      },
    );
  }

  Widget _buildTemplatesSection(BuildContext context, InvitationState state, AppLocalizations? l) {
    // For custom event type, only show custom upload option
    if (state.isCustomEventType) {
      return _CustomTemplateUploadCard(
        uploadedFile: state.uploadedTemplateFile,
        description: state.uploadedTemplateDescription,
      );
    }

    // For regular event types, show templates + custom option
    return _buildTemplatesGrid(context, state, l);
  }

  Widget _buildTemplatesGrid(BuildContext context, InvitationState state, AppLocalizations? l) {
    // Add custom template as first option
    final templates = [
      TemplateModel.customPlaceholder(),
      ...state.availableTemplates,
    ];
    final isEnglish = l?.isEnLocale ?? false;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 11.w,
        mainAxisSpacing: 11.w,
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isCustomSelected = state.uploadedTemplateFile != null ||
            (state.uploadedTemplateDescription?.isNotEmpty ?? false);
        final isSelected = template.isCustom
            ? isCustomSelected
            : state.selectedTemplate?.id == template.id;

        return _TemplateCard(
          template: template,
          isSelected: isSelected,
          uploadedFile: template.isCustom ? state.uploadedTemplateFile : null,
          isEnglish: isEnglish,
          onTap: () {
            if (template.isCustom) {
              _showCustomTemplateBottomSheet(context);
            } else {
              // Clear custom template when selecting a regular template
              context.read<InvitationCubit>().clearCustomTemplate();
              context.read<InvitationCubit>().selectTemplate(template);
            }
          },
        );
      },
    );
  }

  void _showCustomTemplateBottomSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    AppBottomSheet.show(
      context,
      title: l?.translate('invitation_custom_template') ?? 'Custom Template',
      subtitle: l?.translate('invitation_upload_or_describe') ?? 'Upload an image or describe your design',
      icon: Icons.design_services_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      child: BlocProvider.value(
        value: context.read<InvitationCubit>(),
        child: const _CustomTemplateBottomSheetContent(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, InvitationState state, AppLocalizations? l) {
    final canProceed = state.canProceedFromEventType;

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 9.w,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          text: l?.translate('common_next') ?? 'Next',
          onPressed: canProceed
              ? () => context.read<InvitationCubit>().nextStep()
              : null,
        ),
      ),
    );
  }
}

/// Template Card Widget
class _TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final bool isSelected;
  final File? uploadedFile;
  final bool isEnglish;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    this.uploadedFile,
    this.isEnglish = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(11.w),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Template preview or placeholder
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.w),
                child: template.isCustom
                    ? _buildCustomPlaceholder(context)
                    : _buildTemplatePreview(context),
              ),
            ),

            // Name overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(11.w),
                    bottomRight: Radius.circular(11.w),
                  ),
                ),
                child: Text(
                  template.isCustom
                      ? (isEnglish ? 'Custom Template' : 'قالب مخصص')
                      : (isEnglish ? template.name : template.nameAr),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Extra fee indicator for custom
            if (template.hasExtraFee)
              Positioned(
                top: 8.w,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber500,
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money, color: Colors.white, size: 11.w),
                      Text(
                        'رسوم',
                        style: TextStyle(color: Colors.white, fontSize: 9.sp),
                      ),
                    ],
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 13.w,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPlaceholder(BuildContext context) {
    if (uploadedFile != null) {
      return Image.file(uploadedFile!, fit: BoxFit.cover);
    }

    return Container(
      color: AppColors.gray100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 30.w, color: AppColors.gray400),
          SizedBox(height: 8.h),
          Text(
            isEnglish ? 'Upload your design' : 'ارفع تصميمك',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 11.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatePreview(BuildContext context) {
    if (template.previewUrl != null) {
      return Image.network(
        template.previewUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: Icon(Icons.image, size: 38.w, color: AppColors.gray300),
      ),
    );
  }
}

/// Custom Template Upload Card (for custom event types)
class _CustomTemplateUploadCard extends StatelessWidget {
  final File? uploadedFile;
  final String? description;

  const _CustomTemplateUploadCard({
    this.uploadedFile,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent =
        uploadedFile != null || (description?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: () => _showCustomTemplateBottomSheet(context),
      child: Container(
        height: 203.h,
        decoration: BoxDecoration(
          color: hasContent
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : AppColors.gray50,
          borderRadius: BorderRadius.circular(11.w),
          border: Border.all(
            color: hasContent ? AppColors.primaryColor : AppColors.gray300,
            width: hasContent ? 2 : 1,
          ),
        ),
        child: hasContent
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
            borderRadius: BorderRadius.circular(11.w),
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
                Icon(Icons.description, size: 45.w, color: AppColors.primaryColor),
                SizedBox(height: 8.h),
                Text(
                  l?.translate('invitation_custom_description') ?? 'Custom description',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          top: 8.w,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 15.w,
            ),
          ),
        ),
        if (description != null && description!.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(11.w),
                  bottomRight: Radius.circular(11.w),
                ),
              ),
              child: Text(
                description!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        // Edit button
        Positioned(
          bottom: description != null ? 49.h : 8.w,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4.w,
                ),
              ],
            ),
            child: Icon(
              Icons.edit,
              size: 15.w,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.upload_file,
            size: 38.w,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          l?.translate('invitation_upload_custom_template') ?? 'Upload your custom template',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 13.w, color: AppColors.amber600),
            SizedBox(width: 4.w),
            Text(
              l?.translate('invitation_extra_fees_may_apply') ?? 'Extra fees may apply',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.amber600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomTemplateBottomSheet(BuildContext context) {
    final l = AppLocalizations.of(context);
    AppBottomSheet.show(
      context,
      title: l?.translate('invitation_custom_template') ?? 'Custom Template',
      subtitle: l?.translate('invitation_upload_or_describe') ?? 'Upload an image or describe your design',
      icon: Icons.design_services_rounded,
      iconColor: AppColors.primaryColor,
      iconBackgroundColor: AppColors.purple50,
      child: BlocProvider.value(
        value: context.read<InvitationCubit>(),
        child: const _CustomTemplateBottomSheetContent(),
      ),
    );
  }
}

/// Custom Template Bottom Sheet Content
class _CustomTemplateBottomSheetContent extends StatefulWidget {
  const _CustomTemplateBottomSheetContent();

  @override
  State<_CustomTemplateBottomSheetContent> createState() =>
      _CustomTemplateBottomSheetContentState();
}

class _CustomTemplateBottomSheetContentState
    extends State<_CustomTemplateBottomSheetContent> {
  File? _selectedFile;
  final _descriptionController = TextEditingController();
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    // Load existing data if any
    final state = context.read<InvitationCubit>().state;
    _selectedFile = state.uploadedTemplateFile;
    _descriptionController.text = state.uploadedTemplateDescription ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      // Check and request photos permission
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
                message: l?.translate('invitation_allow_photos_access') ?? 'Please allow access to photos',
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
        setState(() {
          _selectedFile = File(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        final l = AppLocalizations.of(context);
        AppSnackBar.showError(
          context,
          message: '${l?.translate('invitation_failed_pick_image') ?? 'Failed to pick image'}: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l?.translate('invitation_photos_permission_required') ?? 'Photos Permission Required'),
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
            child: Text(l?.translate('invitation_open_settings') ?? 'Open Settings'),
          ),
        ],
      ),
    );
  }

  bool get _canConfirm =>
      _selectedFile != null || _descriptionController.text.trim().isNotEmpty;

  String _getButtonText(AppLocalizations? l) {
    if (_selectedFile != null) {
      return l?.translate('invitation_upload') ?? 'Upload';
    } else if (_descriptionController.text.trim().isNotEmpty) {
      return l?.translate('invitation_add_description') ?? 'Add Description';
    }
    return l?.translate('invitation_confirm') ?? 'Confirm';
  }

  void _onConfirm() {
    final cubit = context.read<InvitationCubit>();

    // Clear selected regular template when using custom template
    cubit.clearSelectedTemplate();

    if (_selectedFile != null) {
      cubit.uploadCustomTemplate(_selectedFile!);
    } else {
      // Clear any previous file if only description
      cubit.clearUploadedTemplateFile();
    }

    if (_descriptionController.text.trim().isNotEmpty) {
      cubit.setCustomTemplateDescription(_descriptionController.text.trim());
    } else {
      cubit.clearCustomTemplateDescription();
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload Area
        GestureDetector(
          onTap: _isPickingImage ? null : _pickImage,
          child: Container(
            height: 179.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(11.w),
              border: Border.all(
                color: _selectedFile != null
                    ? AppColors.primaryColor
                    : AppColors.gray300,
                width: _selectedFile != null ? 2 : 1,
              ),
            ),
            child: _isPickingImage
                ? const Center(child: CircularProgressIndicator())
                : _selectedFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(11.w),
                            child: Image.file(
                              _selectedFile!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8.w,
                            right: 8.w,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFile = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 15.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              size: 45.w, color: AppColors.gray400),
                          SizedBox(height: 12.h),
                          Text(
                            l?.translate('invitation_tap_to_upload') ?? 'Tap to upload image',
                            style: TextStyle(
                              color: AppColors.gray600,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l?.translate('invitation_image_format') ?? 'PNG, JPG (max 1920x1920)',
                            style: TextStyle(
                              color: AppColors.gray400,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
          ),
        ),

        SizedBox(height: 20.h),

        // Description
        Text(
          l?.translate('invitation_description_optional') ?? 'Description (optional)',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: l?.translate('invitation_describe_design') ?? 'Describe what you want in the design...',
            hintStyle: TextStyle(color: AppColors.gray400, fontSize: 13.sp),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11.w),
              borderSide: BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11.w),
              borderSide: BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11.w),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),

        // Fee notice
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            color: AppColors.amber50,
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(color: AppColors.amber200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.amber600, size: 19.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l?.translate('invitation_design_fee_notice') ?? 'Design description may incur additional fees.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.amber700,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Confirm Button - text changes based on what user is doing
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: _getButtonText(l),
            onPressed: _canConfirm ? _onConfirm : null,
          ),
        ),

        if (!_canConfirm) ...[
          SizedBox(height: 8.h),
          Center(
            child: Text(
              l?.translate('invitation_please_upload_or_describe') ?? 'Please upload an image or enter a description',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.gray500,
              ),
            ),
          ),
        ],

        SizedBox(height: 16.h),
      ],
    );
  }
}
