import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
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
                  padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.05)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.dynamicHeight(0.025)),

                      // Section: Event Type Dropdown
                      _buildSectionTitle(context, l?.translate('invitation_event_type') ?? 'Event Type'),
                      SizedBox(height: context.dynamicHeight(0.015)),
                      _buildEventTypeDropdown(context, state, l),

                      // Custom event type name field (if custom selected)
                      if (state.selectedEventType?.isCustom == true) ...[
                        SizedBox(height: context.dynamicHeight(0.02)),
                        _buildCustomEventNameField(context, state, l),
                      ],

                      // Section: Templates (shown when event type is selected)
                      if (state.selectedEventType != null) ...[
                        SizedBox(height: context.dynamicHeight(0.03)),
                        _buildSectionTitle(context, l?.translate('invitation_choose_template') ?? 'Choose Template'),
                        SizedBox(height: context.dynamicHeight(0.015)),
                        _buildTemplatesSection(context, state, l),
                      ],

                      SizedBox(height: context.dynamicHeight(0.12)),
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
        fontSize: context.dynamicWidth(0.045),
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
              style: TextStyle(fontSize: context.dynamicWidth(0.06)),
            ),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Text(
                l?.translate('invitation_custom') ?? 'Custom',
                style: TextStyle(
                  fontSize: context.dynamicWidth(0.045),
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
                style: TextStyle(fontSize: context.dynamicWidth(0.06)),
              ),
              SizedBox(width: context.dynamicWidth(0.04)),
              Expanded(
                child: Text(
                  isEnglish ? eventType.name : eventType.nameAr,
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.045),
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
        horizontal: context.dynamicWidth(0.04),
        vertical: context.dynamicHeight(0.005),
      ),
      constraints: BoxConstraints(
        minHeight: context.dynamicHeight(0.065),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        border: Border.all(color: AppColors.gray300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EventTypeModel>(
          value: dropdownValue,
          hint: Text(
            l?.translate('invitation_select_event_type') ?? 'Select event type',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: context.dynamicWidth(0.04),
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray500, size: context.dynamicWidth(0.06)),
          iconSize: context.dynamicWidth(0.06),
          itemHeight: math.max(56.0, context.dynamicHeight(0.08)),
          menuMaxHeight: math.max(300.0, context.dynamicHeight(0.5)),
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
          dropdownColor: Colors.white,
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
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
        crossAxisSpacing: context.dynamicWidth(0.03),
        mainAxisSpacing: context.dynamicWidth(0.03),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.dynamicWidth(0.05))),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: BlocProvider.value(
          value: context.read<InvitationCubit>(),
          child: const _CustomTemplateBottomSheetContent(),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, InvitationState state, AppLocalizations? l) {
    final canProceed = state.canProceedFromEventType;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.dynamicWidth(0.025),
            offset: Offset(0, -context.dynamicHeight(0.005)),
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
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
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
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.028)),
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
                  horizontal: context.dynamicWidth(0.02),
                  vertical: context.dynamicHeight(0.008),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(context.dynamicWidth(0.028)),
                    bottomRight: Radius.circular(context.dynamicWidth(0.028)),
                  ),
                ),
                child: Text(
                  template.isCustom
                      ? (isEnglish ? 'Custom Template' : 'قالب مخصص')
                      : (isEnglish ? template.name : template.nameAr),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.dynamicWidth(0.03),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Extra fee indicator for custom
            if (template.hasExtraFee)
              Positioned(
                top: context.dynamicWidth(0.02),
                left: context.dynamicWidth(0.02),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.015),
                    vertical: context.dynamicHeight(0.003),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber500,
                    borderRadius: BorderRadius.circular(context.dynamicWidth(0.01)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money, color: Colors.white, size: context.dynamicWidth(0.03)),
                      Text(
                        'رسوم',
                        style: TextStyle(color: Colors.white, fontSize: context.dynamicWidth(0.025)),
                      ),
                    ],
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: context.dynamicWidth(0.02),
                right: context.dynamicWidth(0.02),
                child: Container(
                  padding: EdgeInsets.all(context.dynamicWidth(0.005)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: context.dynamicWidth(0.035),
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
          Icon(Icons.upload_file, size: context.dynamicWidth(0.08), color: AppColors.gray400),
          SizedBox(height: context.dynamicHeight(0.01)),
          Text(
            isEnglish ? 'Upload your design' : 'ارفع تصميمك',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: context.dynamicWidth(0.03),
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
        child: Icon(Icons.image, size: context.dynamicWidth(0.1), color: AppColors.gray300),
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
        height: context.dynamicHeight(0.25),
        decoration: BoxDecoration(
          color: hasContent
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : AppColors.gray50,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
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
            borderRadius: BorderRadius.circular(context.dynamicWidth(0.028)),
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
                Icon(Icons.description, size: context.dynamicWidth(0.12), color: AppColors.primaryColor),
                SizedBox(height: context.dynamicHeight(0.01)),
                Text(
                  l?.translate('invitation_custom_description') ?? 'Custom description',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.04),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        Positioned(
          top: context.dynamicWidth(0.02),
          right: context.dynamicWidth(0.02),
          child: Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.01)),
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
        ),
        if (description != null && description!.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.02)),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.dynamicWidth(0.028)),
                  bottomRight: Radius.circular(context.dynamicWidth(0.028)),
                ),
              ),
              child: Text(
                description!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.dynamicWidth(0.03),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        // Edit button
        Positioned(
          bottom: description != null ? context.dynamicHeight(0.06) : context.dynamicWidth(0.02),
          right: context.dynamicWidth(0.02),
          child: Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.02)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: context.dynamicWidth(0.01),
                ),
              ],
            ),
            child: Icon(
              Icons.edit,
              size: context.dynamicWidth(0.04),
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
          padding: EdgeInsets.all(context.dynamicWidth(0.04)),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.upload_file,
            size: context.dynamicWidth(0.1),
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.02)),
        Text(
          l?.translate('invitation_upload_custom_template') ?? 'Upload your custom template',
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
            Icon(Icons.info_outline, size: context.dynamicWidth(0.035), color: AppColors.amber600),
            SizedBox(width: context.dynamicWidth(0.01)),
            Text(
              l?.translate('invitation_extra_fees_may_apply') ?? 'Extra fees may apply',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.03),
                color: AppColors.amber600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomTemplateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.dynamicWidth(0.05))),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: BlocProvider.value(
          value: context.read<InvitationCubit>(),
          child: const _CustomTemplateBottomSheetContent(),
        ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l?.translate('invitation_allow_photos_access') ?? 'Please allow access to photos'),
                  backgroundColor: Colors.orange,
                ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l?.translate('invitation_failed_pick_image') ?? 'Failed to pick image'}: $e'),
            backgroundColor: Colors.red,
          ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.dynamicWidth(0.05)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: context.dynamicWidth(0.1),
                height: context.dynamicHeight(0.005),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.005)),
                ),
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),

            // Title
            Text(
              l?.translate('invitation_custom_template') ?? 'Custom Template',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.05),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.025)),

            // Upload Area
            GestureDetector(
              onTap: _isPickingImage ? null : _pickImage,
              child: Container(
                height: context.dynamicHeight(0.22),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
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
                                borderRadius: BorderRadius.circular(context.dynamicWidth(0.028)),
                                child: Image.file(
                                  _selectedFile!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: context.dynamicWidth(0.02),
                                right: context.dynamicWidth(0.02),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(context.dynamicWidth(0.01)),
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
                          )
                        : Column(
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
                                  fontSize: context.dynamicWidth(0.03),
                                ),
                              ),
                            ],
                          ),
              ),
            ),

            SizedBox(height: context.dynamicHeight(0.025)),

            // Description
            Text(
              l?.translate('invitation_description_optional') ?? 'Description (optional)',
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
                hintText: l?.translate('invitation_describe_design') ?? 'Describe what you want in the design...',
                hintStyle: TextStyle(color: AppColors.gray400, fontSize: context.dynamicWidth(0.035)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                  borderSide: BorderSide(color: AppColors.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                  borderSide: BorderSide(color: AppColors.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            // Fee notice
            SizedBox(height: context.dynamicHeight(0.02)),
            Container(
              padding: EdgeInsets.all(context.dynamicWidth(0.03)),
              decoration: BoxDecoration(
                color: AppColors.amber50,
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.02)),
                border: Border.all(color: AppColors.amber200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.amber600, size: context.dynamicWidth(0.05)),
                  SizedBox(width: context.dynamicWidth(0.02)),
                  Expanded(
                    child: Text(
                      l?.translate('invitation_design_fee_notice') ?? 'Design description may incur additional fees.',
                      style: TextStyle(
                        fontSize: context.dynamicWidth(0.03),
                        color: AppColors.amber700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: context.dynamicHeight(0.03)),

            // Confirm Button - text changes based on what user is doing
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: _getButtonText(l),
                onPressed: _canConfirm ? _onConfirm : null,
              ),
            ),

            if (!_canConfirm) ...[
              SizedBox(height: context.dynamicHeight(0.01)),
              Center(
                child: Text(
                  l?.translate('invitation_please_upload_or_describe') ?? 'Please upload an image or enter a description',
                  style: TextStyle(
                    fontSize: context.dynamicWidth(0.03),
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],

            SizedBox(height: context.dynamicHeight(0.02)),
          ],
        ),
      ),
    );
  }
}
