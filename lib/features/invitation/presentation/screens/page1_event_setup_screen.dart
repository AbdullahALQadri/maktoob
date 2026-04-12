import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../../../config/locale/app_localizations.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 1 (of 3): Event Setup
/// Combines event type + template selection, event details, and preview.
class Page1EventSetupScreen extends StatefulWidget {
  const Page1EventSetupScreen({super.key});

  @override
  State<Page1EventSetupScreen> createState() => _Page1EventSetupScreenState();
}

class _Page1EventSetupScreenState extends State<Page1EventSetupScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _promptController = TextEditingController();

  // Track which sections are expanded
  bool _eventTypeExpanded = true;
  bool _detailsExpanded = false;
  bool _previewExpanded = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<InvitationCubit>().state;
    _nameController.text = state.eventName ?? '';
    _descriptionController.text = state.eventDescription ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<InvitationCubit>().clearError();
        }
      },
      builder: (context, state) {
        // Auto-expand details section when event type is selected
        if (state.selectedEventType != null &&
            (state.selectedTemplate != null ||
                state.uploadedTemplateFile != null ||
                (state.uploadedTemplateDescription?.isNotEmpty ?? false))) {
          if (!_detailsExpanded && _eventTypeExpanded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _detailsExpanded = true;
                });
              }
            });
          }
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              _ModernStepHeader(
                stepNumber: 1,
                title: l?.translate('wizard_step1_setup_title') ??
                    'Event Setup',
                subtitle: l?.translate('wizard_step1_setup_subtitle') ??
                    'Choose your event type and fill in the details',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dynamicWidth(0.04),
                    vertical: context.dynamicHeight(0.02),
                  ),
                  child: Column(
                    children: [
                      // Section 1: Event Type & Template
                      _CollapsibleSection(
                        title: l?.translate('invitation_event_type') ??
                            'Event Type',
                        subtitle: state.selectedEventType != null
                            ? (state.selectedEventType!.isCustom
                                ? (state.customEventTypeName ?? 'Custom')
                                : state.selectedEventType!.name)
                            : null,
                        icon: Icons.celebration_rounded,
                        isExpanded: _eventTypeExpanded,
                        isComplete: state.canProceedFromEventType,
                        onToggle: () => setState(
                            () => _eventTypeExpanded = !_eventTypeExpanded),
                        child: _EventTypeSection(state: state),
                      ),
                      SizedBox(height: context.dynamicHeight(0.015)),

                      // Section 2: Event Details
                      _CollapsibleSection(
                        title: l?.translate('invitation_event_details') ??
                            'Event Details',
                        subtitle: state.eventName,
                        icon: Icons.edit_note_rounded,
                        isExpanded: _detailsExpanded,
                        isComplete: state.canProceedFromEventDetails,
                        onToggle: () => setState(
                            () => _detailsExpanded = !_detailsExpanded),
                        child: _EventDetailsSection(
                          state: state,
                          nameController: _nameController,
                          descriptionController: _descriptionController,
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.015)),

                      // Section 3: AI Preview & Generate
                      _CollapsibleSection(
                        title: l?.translate('invitation_ai_preview') ??
                            'Invitation Preview',
                        subtitle: state.generatedImageUrl != null
                            ? (l?.translate('invitation_image_ready') ??
                                'Image ready')
                            : null,
                        icon: Icons.auto_awesome_rounded,
                        isExpanded: _previewExpanded,
                        isComplete: state.generatedImageUrl != null ||
                            state.previewImageUrl != null ||
                            state.uploadedTemplateFile != null,
                        onToggle: () => setState(
                            () => _previewExpanded = !_previewExpanded),
                        child: _PreviewSection(
                          state: state,
                          promptController: _promptController,
                        ),
                      ),
                      SizedBox(height: context.dynamicHeight(0.1)),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                state: state,
                nameController: _nameController,
                descriptionController: _descriptionController,
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// MODERN STEP HEADER
// =============================================================================

class _ModernStepHeader extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String? subtitle;

  const _ModernStepHeader({
    required this.stepNumber,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: context.dynamicWidth(0.05),
        right: context.dynamicWidth(0.05),
        top: context.dynamicHeight(0.02),
        bottom: context.dynamicHeight(0.025),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.tertiaryColor,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (stepNumber == 1) {
                      Navigator.of(context).pop();
                    } else {
                      context.read<InvitationCubit>().previousStep();
                    }
                  },
                  child: Container(
                    width: context.dynamicWidth(0.09),
                    height: context.dynamicWidth(0.09),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: context.dynamicWidth(0.05),
                    ),
                  ),
                ),
                SizedBox(width: context.dynamicWidth(0.04)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.dynamicWidth(0.055),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: context.dynamicHeight(0.003)),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: context.dynamicWidth(0.032),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.dynamicHeight(0.02)),
            // Step dots indicator
            _StepDotsIndicator(currentStep: stepNumber),
          ],
        ),
      ),
    );
  }
}

class _StepDotsIndicator extends StatelessWidget {
  final int currentStep;

  const _StepDotsIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final step = index + 1;
        final isActive = step <= currentStep;
        final isCurrent = step == currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: context.dynamicWidth(0.01)),
            height: context.dynamicHeight(0.005),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.01)),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.4),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

// =============================================================================
// COLLAPSIBLE SECTION
// =============================================================================

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isExpanded;
  final bool isComplete;
  final VoidCallback onToggle;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.isExpanded,
    required this.isComplete,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
        border: Border.all(
          color: isComplete
              ? AppColors.primaryColor.withValues(alpha: 0.3)
              : context.borderColor,
          width: isComplete ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.dynamicWidth(0.04)),
              bottom: isExpanded
                  ? Radius.zero
                  : Radius.circular(context.dynamicWidth(0.04)),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.dynamicWidth(0.04)),
              child: Row(
                children: [
                  Container(
                    width: context.dynamicWidth(0.1),
                    height: context.dynamicWidth(0.1),
                    decoration: BoxDecoration(
                      color: isComplete
                          ? AppColors.primaryColor.withValues(alpha: 0.1)
                          : context.inputFill,
                      borderRadius: BorderRadius.circular(
                          context.dynamicWidth(0.03)),
                    ),
                    child: Icon(
                      isComplete ? Icons.check_circle_rounded : icon,
                      color: isComplete
                          ? AppColors.primaryColor
                          : context.iconSecondary,
                      size: context.dynamicWidth(0.055),
                    ),
                  ),
                  SizedBox(width: context.dynamicWidth(0.035)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: context.dynamicWidth(0.04),
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        if (subtitle != null && !isExpanded) ...[
                          SizedBox(height: context.dynamicHeight(0.003)),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.032),
                              color: context.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.iconSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(
                left: context.dynamicWidth(0.04),
                right: context.dynamicWidth(0.04),
                bottom: context.dynamicWidth(0.04),
              ),
              child: child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// EVENT TYPE SECTION (from old Page 1)
// =============================================================================

class _EventTypeSection extends StatelessWidget {
  final InvitationState state;

  const _EventTypeSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: context.borderColor),
        SizedBox(height: context.dynamicHeight(0.01)),
        EventTypeDropdown(state: state),
        if (state.selectedEventType?.isCustom == true) ...[
          SizedBox(height: context.dynamicHeight(0.015)),
          AppTextField(
            hintText: l?.translate('invitation_enter_event_type_name') ??
                'Enter event type name',
            prefixIcon: Icons.edit,
            initialValue: state.customEventTypeName,
            onChanged: (value) {
              context.read<InvitationCubit>().setCustomEventTypeName(value);
            },
          ),
        ],
        if (state.selectedEventType != null) ...[
          SizedBox(height: context.dynamicHeight(0.02)),
          _SectionLabel(
            text: l?.translate('invitation_choose_template') ??
                'Choose Template',
          ),
          SizedBox(height: context.dynamicHeight(0.01)),
          if (state.isCustomEventType)
            CustomTemplateUploadCard(
              uploadedFile: state.uploadedTemplateFile,
              description: state.uploadedTemplateDescription,
            )
          else
            _TemplatesGrid(state: state),
        ],
      ],
    );
  }
}

class _TemplatesGrid extends StatelessWidget {
  final InvitationState state;

  const _TemplatesGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
        crossAxisSpacing: context.dynamicWidth(0.025),
        mainAxisSpacing: context.dynamicWidth(0.025),
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

        return TemplateCard(
          template: template,
          isSelected: isSelected,
          uploadedFile: template.isCustom ? state.uploadedTemplateFile : null,
          isEnglish: isEnglish,
          onTap: () => _onTemplateTap(context, template),
        );
      },
    );
  }

  void _onTemplateTap(BuildContext context, TemplateModel template) {
    if (template.isCustom) {
      _showCustomTemplateBottomSheet(context);
    } else {
      context.read<InvitationCubit>().clearCustomTemplate();
      context.read<InvitationCubit>().selectTemplate(template);
    }
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
      final storageStatus = await ph.Permission.storage.request();
      debugPrint('Storage permission status: $storageStatus');

      if (!storageStatus.isGranted) {
        final photosStatus = await ph.Permission.photos.request();
        debugPrint('Photos permission status: $photosStatus');
      }

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

// =============================================================================
// EVENT DETAILS SECTION (from old Page 2)
// =============================================================================

class _EventDetailsSection extends StatelessWidget {
  final InvitationState state;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const _EventDetailsSection({
    required this.state,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: context.borderColor),
        SizedBox(height: context.dynamicHeight(0.01)),

        // Event Name
        _SectionLabel(
          text: l?.translate('invitation_event_name_required') ??
              'Event Name *',
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        AppTextField(
          controller: nameController,
          hintText: l?.translate('invitation_enter_event_name') ??
              'Enter event name',
          prefixIcon: Icons.event,
          onChanged: (value) {
            context.read<InvitationCubit>().updateEventName(value);
          },
        ),

        // Dynamic form fields (e.g., groom/bride names for weddings)
        if (!state.isCustomEventType &&
            !state.isCustomTemplate &&
            state.eventTypeFormFields.isNotEmpty) ...[
          SizedBox(height: context.dynamicHeight(0.02)),
          _EventTypeFormFields(state: state),
        ],

        // Description
        SizedBox(height: context.dynamicHeight(0.02)),
        _SectionLabel(
          text: l?.translate('invitation_description_optional_label') ??
              'Description (Optional)',
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        AppTextField(
          controller: descriptionController,
          hintText: l?.translate('invitation_add_event_description') ??
              'Add a description for your event...',
          prefixIcon: Icons.description_outlined,
          maxLines: 3,
          onChanged: (value) {
            context
                .read<InvitationCubit>()
                .updateEventDescription(value.isEmpty ? null : value);
          },
        ),

        // Date & Time row
        SizedBox(height: context.dynamicHeight(0.02)),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    text: l?.translate('invitation_date_required') ?? 'Date *',
                  ),
                  SizedBox(height: context.dynamicHeight(0.008)),
                  EventDatePicker(selectedDate: state.eventDate),
                ],
              ),
            ),
            SizedBox(width: context.dynamicWidth(0.03)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    text: l?.translate('invitation_time_required') ?? 'Time *',
                  ),
                  SizedBox(height: context.dynamicHeight(0.008)),
                  EventTimePicker(selectedTime: state.eventTime),
                ],
              ),
            ),
          ],
        ),

        // Location
        SizedBox(height: context.dynamicHeight(0.02)),
        _SectionLabel(
          text: l?.translate('invitation_location_required') ?? 'Location',
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        EventLocationSection(state: state),

        // Companions
        SizedBox(height: context.dynamicHeight(0.02)),
        CompanionsSection(state: state),
      ],
    );
  }
}

class _EventTypeFormFields extends StatelessWidget {
  final InvitationState state;

  const _EventTypeFormFields({required this.state});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: t.translate('invitation_couple_info')),
        SizedBox(height: context.dynamicHeight(0.008)),
        ...state.eventTypeFormFields.map((field) {
          IconData fieldIcon = Icons.person_outline;
          if (field.key == 'groom_name') {
            fieldIcon = Icons.person;
          } else if (field.key == 'bride_name') {
            fieldIcon = Icons.person_outline;
          }

          final label = isArabic ? field.labelAr : field.label;
          final hint = isArabic
              ? (field.hintAr ?? field.labelAr)
              : (field.hint ?? field.label);

          return Padding(
            padding: EdgeInsets.only(bottom: context.dynamicHeight(0.015)),
            child: AppTextField(
              labelText: label,
              hintText: hint,
              prefixIcon: fieldIcon,
              initialValue: state.eventTypeFormData[field.key]?.toString(),
              onChanged: (value) {
                context
                    .read<InvitationCubit>()
                    .updateEventTypeFormField(field.key, value);
              },
            ),
          );
        }),
      ],
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.033),
        fontWeight: FontWeight.w500,
        color: context.textTertiary,
      ),
    );
  }
}

// =============================================================================
// PREVIEW & AI GENERATION SECTION
// =============================================================================

class _PreviewSection extends StatelessWidget {
  final InvitationState state;
  final TextEditingController promptController;

  const _PreviewSection({
    required this.state,
    required this.promptController,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: context.borderColor),
        SizedBox(height: context.dynamicHeight(0.01)),

        // Show current preview image (uploaded, template, or AI-generated)
        _PreviewImage(state: state),

        SizedBox(height: context.dynamicHeight(0.02)),

        // AI Generation input
        _SectionLabel(
          text: l?.translate('invitation_ai_prompt') ??
              'Generate with AI (Optional)',
        ),
        SizedBox(height: context.dynamicHeight(0.008)),
        AppTextField(
          controller: promptController,
          hintText: l?.translate('invitation_ai_prompt_hint') ??
              'Describe the invitation design you want...',
          prefixIcon: Icons.auto_awesome,
          maxLines: 2,
        ),
        SizedBox(height: context.dynamicHeight(0.015)),

        // Generate / Regenerate button
        Row(
          children: [
            Expanded(
              child: _GenerateButton(
                state: state,
                promptController: promptController,
              ),
            ),
            if (state.generatedImageUrl != null) ...[
              SizedBox(width: context.dynamicWidth(0.03)),
              Expanded(
                child: SecondaryButton(
                  text: l?.translate('invitation_regenerate') ?? 'Regenerate',
                  onPressed: state.isGeneratingImage
                      ? null
                      : () {
                          context.read<InvitationCubit>().generateAiImage(
                                prompt: promptController.text.isNotEmpty
                                    ? promptController.text
                                    : null,
                              );
                        },
                ),
              ),
            ],
          ],
        ),

        // Error message
        if (state.generationError != null) ...[
          SizedBox(height: context.dynamicHeight(0.01)),
          Container(
            padding: EdgeInsets.all(context.dynamicWidth(0.025)),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius:
                  BorderRadius.circular(context.dynamicWidth(0.02)),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.red.shade700,
                    size: context.dynamicWidth(0.04)),
                SizedBox(width: context.dynamicWidth(0.02)),
                Expanded(
                  child: Text(
                    state.generationError!,
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.028),
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewImage extends StatelessWidget {
  final InvitationState state;

  const _PreviewImage({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    // Show AI generation loading
    if (state.isGeneratingImage) {
      return Container(
        height: context.dynamicHeight(0.25),
        decoration: BoxDecoration(
          color: context.inputFill,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: context.dynamicWidth(0.1),
                height: context.dynamicWidth(0.1),
                child: const CircularProgressIndicator(strokeWidth: 3),
              ),
              SizedBox(height: context.dynamicHeight(0.015)),
              Text(
                l?.translate('invitation_generating_image') ??
                    'Generating your design...',
                style: TextStyle(
                  color: context.textSecondary,
                  fontSize: context.dynamicWidth(0.035),
                ),
              ),
              SizedBox(height: context.dynamicHeight(0.005)),
              Text(
                l?.translate('invitation_generation_wait') ??
                    'This may take up to 30 seconds',
                style: TextStyle(
                  color: context.iconSecondary,
                  fontSize: context.dynamicWidth(0.03),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show uploaded custom file
    if (state.uploadedTemplateFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        child: Image.file(
          state.uploadedTemplateFile!,
          height: context.dynamicHeight(0.3),
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _placeholder(context, l),
        ),
      );
    }

    // Show generated or preview image from URL
    final imageUrl = state.generatedImageUrl ?? state.previewImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        child: Image.network(
          imageUrl,
          height: context.dynamicHeight(0.3),
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (ctx, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: context.dynamicHeight(0.25),
              decoration: BoxDecoration(
                color: context.inputFill,
                borderRadius:
                    BorderRadius.circular(context.dynamicWidth(0.03)),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => _placeholder(context, l),
        ),
      );
    }

    // Show selected template thumbnail
    if (state.selectedTemplate != null &&
        state.selectedTemplate!.previewUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        child: Image.network(
          state.selectedTemplate!.previewUrl!,
          height: context.dynamicHeight(0.3),
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _placeholder(context, l),
        ),
      );
    }

    return _placeholder(context, l);
  }

  Widget _placeholder(BuildContext context, AppLocalizations? l) {
    return Container(
      height: context.dynamicHeight(0.2),
      decoration: BoxDecoration(
        color: context.inputFill,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        border: Border.all(color: context.borderColor),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: context.dynamicWidth(0.1),
              color: context.iconDefault,
            ),
            SizedBox(height: context.dynamicHeight(0.01)),
            Text(
              l?.translate('invitation_no_preview') ??
                  'No preview yet',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.033),
                color: context.textSecondary,
              ),
            ),
            SizedBox(height: context.dynamicHeight(0.005)),
            Text(
              l?.translate('invitation_generate_hint') ??
                  'Use AI to generate a custom design',
              style: TextStyle(
                fontSize: context.dynamicWidth(0.028),
                color: context.iconSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final InvitationState state;
  final TextEditingController promptController;

  const _GenerateButton({
    required this.state,
    required this.promptController,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasExistingImage = state.generatedImageUrl != null;

    return PrimaryButton(
      text: hasExistingImage
          ? (l?.translate('invitation_regenerate') ?? 'Regenerate')
          : (l?.translate('invitation_generate_ai') ?? 'Generate with AI'),
      icon: Icons.auto_awesome,
      isLoading: state.isGeneratingImage,
      onPressed: state.isGeneratingImage
          ? null
          : () {
              context.read<InvitationCubit>().generateAiImage(
                    prompt: promptController.text.isNotEmpty
                        ? promptController.text
                        : null,
                  );
            },
    );
  }
}

// =============================================================================
// BOTTOM BAR
// =============================================================================

class _BottomBar extends StatelessWidget {
  final InvitationState state;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const _BottomBar({
    required this.state,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final canProceed =
        state.canProceedFromEventType && state.canProceedFromEventDetails;
    final isLoading = state.isLoading;

    return Container(
      padding: EdgeInsets.all(context.dynamicWidth(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          text: l?.translate('wizard_continue_to_guests') ??
              'Continue to Guests',
          icon: Icons.arrow_forward_rounded,
          isLoading: isLoading,
          onPressed: canProceed && !isLoading
              ? () {
                  final cubit = context.read<InvitationCubit>();
                  // Sync text controller values
                  if (nameController.text.isNotEmpty) {
                    cubit.updateEventName(nameController.text);
                  }
                  if (descriptionController.text.isNotEmpty) {
                    cubit.updateEventDescription(descriptionController.text);
                  }
                  // Create draft & save details, then proceed
                  cubit.createDraftAndSaveDetails();
                }
              : null,
        ),
      ),
    );
  }
}
