import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/wizard_step_header.dart';

/// Page 1: Event Type and Template Selection
class Page1EventTypeScreen extends StatelessWidget {
  const Page1EventTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Column(
          children: [
            // Step Header
            const WizardStepHeader(
              currentStep: 1,
              totalSteps: 7,
              title: 'Select Event Type',
              titleAr: 'اختر نوع المناسبة',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Section: Event Types
                    _buildSectionTitle(context, 'Event Type', 'نوع المناسبة'),
                    const SizedBox(height: 12),
                    _buildEventTypesGrid(context, state),

                    // Section: Templates (shown when event type is selected)
                    if (state.selectedEventType != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                          context, 'Choose Template', 'اختر القالب'),
                      const SizedBox(height: 12),
                      _buildTemplatesSection(context, state),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom Button
            _buildBottomBar(context, state),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String title, String titleAr) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.gray800,
      ),
    );
  }

  Widget _buildEventTypesGrid(BuildContext context, InvitationState state) {
    // Custom type at the beginning of the list
    final eventTypes = [
      // Custom type placeholder first
      if (!state.availableEventTypes.any((e) => e.isCustom))
        const EventTypeModel(
          id: null,
          name: 'Custom',
          nameAr: 'مخصص',
          emoji: '➕',
        ),
      ...state.availableEventTypes,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: eventTypes.length,
      itemBuilder: (context, index) {
        final eventType = eventTypes[index];
        final isSelected = state.selectedEventType?.id == eventType.id &&
            state.selectedEventType?.name == eventType.name;

        return _EventTypeCard(
          eventType: eventType,
          isSelected: isSelected,
          onTap: () {
            if (eventType.isCustom) {
              _showCustomEventTypeDialog(context);
            } else {
              context.read<InvitationCubit>().selectEventType(eventType);
              // TODO: Load templates from API for this event type
            }
          },
        );
      },
    );
  }

  Widget _buildTemplatesSection(BuildContext context, InvitationState state) {
    // For custom event type, only show custom upload option
    if (state.isCustomEventType) {
      return _buildCustomTemplateOnlySection(context, state);
    }

    // For regular event types, show templates + custom option
    return _buildTemplatesGrid(context, state);
  }

  Widget _buildCustomTemplateOnlySection(
      BuildContext context, InvitationState state) {
    return _CustomTemplateCard(
      uploadedFile: state.uploadedTemplateFile,
      description: state.uploadedTemplateDescription,
      onTap: () => _showCustomTemplateBottomSheet(context),
    );
  }

  Widget _buildTemplatesGrid(BuildContext context, InvitationState state) {
    // Add custom template as first option
    final templates = [
      TemplateModel.customPlaceholder(),
      ...state.availableTemplates,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = template.isCustom
            ? state.uploadedTemplateFile != null
            : state.selectedTemplate?.id == template.id;

        return _TemplateCard(
          template: template,
          isSelected: isSelected,
          uploadedFile: template.isCustom ? state.uploadedTemplateFile : null,
          onTap: () {
            if (template.isCustom) {
              _showCustomTemplateBottomSheet(context);
            } else {
              context.read<InvitationCubit>().selectTemplate(template);
            }
          },
        );
      },
    );
  }

  void _showCustomEventTypeDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom Event Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the name of your custom event type:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller,
              hintText: 'Event type name',
              prefixIcon: Icons.event,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<InvitationCubit>()
                    .setCustomEventTypeName(controller.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCustomTemplateBottomSheet(BuildContext context) {
    AppBottomSheet.show(
      context,
      title: 'Custom Template',
      child: _CustomTemplateBottomSheetContent(),
    );
  }

  Widget _buildBottomBar(BuildContext context, InvitationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          text: 'Next',
          onPressed: state.canProceedFromEventType
              ? () => context.read<InvitationCubit>().nextStep()
              : null,
        ),
      ),
    );
  }
}

/// Event Type Card Widget
class _EventTypeCard extends StatelessWidget {
  final EventTypeModel eventType;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventTypeCard({
    required this.eventType,
    required this.isSelected,
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
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    eventType.emoji ?? '📅',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eventType.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.gray700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
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
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    this.uploadedFile,
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
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(11),
                child: template.isCustom
                    ? _buildCustomPlaceholder()
                    : _buildTemplatePreview(),
              ),
            ),

            // Name overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: Text(
                  template.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Extra fee indicator for custom
            if (template.hasExtraFee)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.amber500,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money, color: Colors.white, size: 12),
                      Text(
                        'Fee',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPlaceholder() {
    if (uploadedFile != null) {
      return Image.file(uploadedFile!, fit: BoxFit.cover);
    }

    return Container(
      color: AppColors.gray100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 32, color: AppColors.gray400),
          const SizedBox(height: 8),
          Text(
            'Upload your\ndesign',
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatePreview() {
    if (template.previewUrl != null) {
      return Image.network(
        template.previewUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: Icon(Icons.image, size: 40, color: AppColors.gray300),
      ),
    );
  }
}

/// Custom Template Card (for custom event types)
class _CustomTemplateCard extends StatelessWidget {
  final File? uploadedFile;
  final String? description;
  final VoidCallback onTap;

  const _CustomTemplateCard({
    this.uploadedFile,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: uploadedFile != null
                ? AppColors.primaryColor
                : AppColors.gray200,
            width: uploadedFile != null ? 2 : 1,
            style: uploadedFile != null ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: uploadedFile != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      uploadedFile!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  if (description != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                        ),
                        child: Text(
                          description!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.upload_file,
                      size: 40,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Your Custom Template',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: AppColors.amber600),
                      const SizedBox(width: 4),
                      Text(
                        'Additional fees may apply',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.amber600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// Custom Template Bottom Sheet Content
class _CustomTemplateBottomSheetContent extends StatefulWidget {
  @override
  State<_CustomTemplateBottomSheetContent> createState() =>
      _CustomTemplateBottomSheetContentState();
}

class _CustomTemplateBottomSheetContentState
    extends State<_CustomTemplateBottomSheetContent> {
  File? _selectedFile;
  final _descriptionController = TextEditingController();
  bool _hasDescription = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onDescriptionChanged);
  }

  void _onDescriptionChanged() {
    final hasText = _descriptionController.text.trim().isNotEmpty;
    if (hasText != _hasDescription) {
      setState(() {
        _hasDescription = hasText;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionChanged);
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.path != null) {
        setState(() {
          _selectedFile = File(result.files.first.path!);
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Area
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gray300,
                  style: BorderStyle.solid,
                ),
              ),
              child: _selectedFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        _selectedFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload,
                            size: 40, color: AppColors.gray400),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to upload image',
                          style: TextStyle(color: AppColors.gray500),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Description (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _descriptionController,
            hintText: 'Describe what you want in your design...',
            maxLines: 3,
          ),

          // Fee notice
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.amber200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.amber600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A description may result in additional design fees.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.amber700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Button
          PrimaryButton(
            text: 'Confirm',
            onPressed: (_selectedFile != null || _hasDescription)
                ? () {
                    if (_selectedFile != null) {
                      context
                          .read<InvitationCubit>()
                          .uploadCustomTemplate(_selectedFile!);
                    }
                    if (_hasDescription) {
                      context.read<InvitationCubit>().setCustomTemplateDescription(
                          _descriptionController.text.trim());
                    }
                    Navigator.pop(context);
                  }
                : null,
          ),
          if (_selectedFile == null && !_hasDescription) ...[
            const SizedBox(height: 8),
            Text(
              'Please upload an image or enter a description',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
