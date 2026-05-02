import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
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

  // Track which sections are expanded
  bool _eventTypeExpanded = true;
  bool _detailsExpanded = false;
  bool _previewExpanded = false;

  // Tracks the last event type that triggered auto-expand so it fires only once
  int? _lastAutoExpandedForEventTypeId;

  // AI Design â€” image URL returned from AiDesignPage
  String? _aiImageUrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<InvitationCubit>().state;
    _nameController.text        = state.eventName ?? '';
    _descriptionController.text = state.eventDescription ?? '';
    // Restore preview if user had already generated an image
    _aiImageUrl = state.generatedImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _openAiDesign(BuildContext ctx, InvitationState state) async {
    final l = AppLocalizations.of(ctx);

    // Event type must be selected and have a valid ID
    final eventTypeId = state.selectedEventType?.id;
    if (eventTypeId == null || eventTypeId == 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(l?.translate('invitation_select_event_type_first') ??
            'اختر نوع المناسبة أولاً'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    int? eventId = state.draftEventId;

    // If no draft event yet, create one now before opening AI Design
    if (eventId == null) {
      final cubit = ctx.read<InvitationCubit>();

      // Sync name from controller if filled
      if (_nameController.text.isNotEmpty) {
        cubit.updateEventName(_nameController.text);
      }

      await cubit.initializeWizardIfNeeded();

      if (!mounted) return;
      // BLoC emit() is synchronous — cubit.state is updated as soon as
      // initializeWizardIfNeeded() completes, so this read is safe.
      eventId = cubit.state.draftEventId;

      if (eventId == null) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(l?.translate('invitation_fill_details_first') ??
              'أدخل اسم المناسبة أولاً'),
          backgroundColor: Colors.orange,
        ));
        return;
      }
    }

    final result = await Navigator.of(ctx).pushNamed(
      Routes.aiDesign,
      arguments: {'eventId': eventId, 'eventTypeId': eventTypeId},
    );

    if (result is String && result.isNotEmpty && mounted) {
      // Register with the wizard cubit so canProceedFromEventType becomes true.
      ctx.read<InvitationCubit>().setAiGeneratedImage(result);
      setState(() {
        _aiImageUrl      = result;
        _previewExpanded = true;
      });
    }
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
          final l = AppLocalizations.of(context);
          final msg = l?.translate(state.errorMessage!) ?? state.errorMessage!;
          AppSnackBar.showError(context, message: msg);
          context.read<InvitationCubit>().clearError();
        }
      },
      builder: (context, state) {
        // Auto-expand details section once when event type is selected
        final currentTypeId = state.selectedEventType?.id;
        if (currentTypeId != null &&
            currentTypeId != _lastAutoExpandedForEventTypeId) {
          _lastAutoExpandedForEventTypeId = currentTypeId;
          if (!_detailsExpanded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _detailsExpanded = true);
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

                      // Section 3: AI Design Studio
                      _CollapsibleSection(
                        title: l?.translate('ai_design_title') ??
                            'ØªØµÙ…ÙŠÙ… Ø§Ù„Ø¯Ø¹ÙˆØ© Ø¨Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ',
                        subtitle: _aiImageUrl != null
                            ? (l?.translate('invitation_image_ready') ??
                                'Image ready')
                            : null,
                        icon: Icons.auto_awesome_rounded,
                        isExpanded: _previewExpanded,
                        isComplete: _aiImageUrl != null,
                        onToggle: () => setState(
                            () => _previewExpanded = !_previewExpanded),
                        child: _AiDesignStudioSection(
                          imageUrl: _aiImageUrl,
                          onOpenDesign: () => _openAiDesign(context, state),
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
      ],
    );
  }
}

// =============================================================================
// AI DESIGN STUDIO SECTION
// =============================================================================

class _AiDesignStudioSection extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onOpenDesign;

  const _AiDesignStudioSection({this.imageUrl, required this.onOpenDesign});

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Divider(color: context.borderColor),
      SizedBox(height: context.dynamicHeight(0.01)),

      if (imageUrl != null && imageUrl!.isNotEmpty) ...[
        // Show selected AI image preview
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            height: context.dynamicHeight(0.3),
            width: double.infinity,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => Container(
              height: context.dynamicHeight(0.2),
              color: context.inputFill,
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.015)),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onOpenDesign,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l?.translate('ai_regenerate_image') ?? 'ØªØºÙŠÙŠØ± Ø§Ù„ØµÙˆØ±Ø©'),
          ),
        ),
      ] else ...[
        // Invite card to open AI Design Studio
        InkWell(
          onTap: onOpenDesign,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.3)),
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.05), primary.withOpacity(0.12)],
              ),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome, color: primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    l?.translate('ai_design_title') ??
                        'ØªØµÙ…ÙŠÙ… Ø§Ù„Ø¯Ø¹ÙˆØ© Ø¨Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: context.dynamicWidth(0.038),
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l?.translate('ai_design_subtitle') ??
                        'Ø§Ø®ØªØ± Ù…Ù† Ø§Ù„ØªØµØ§Ù…ÙŠÙ… Ø£Ùˆ Ø£Ù†Ø´Ø¦ ØªØµÙ…ÙŠÙ…Ø§Ù‹ ÙØ±ÙŠØ¯Ø§Ù‹',
                    style: TextStyle(
                      fontSize: context.dynamicWidth(0.032),
                      color: context.textSecondary,
                    ),
                  ),
                ]),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: primary, size: 18),
            ]),
          ),
        ),
      ],
      SizedBox(height: context.dynamicHeight(0.01)),
    ]);
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

        // Event-specific form fields (bride/groom names etc.) are collected
        // in the AI Design Studio form fields section — not duplicated here.

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
    final missing   = _missingFields(state, l);

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!canProceed && missing.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange.shade800, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l?.translate('wizard_missing_fields') ?? 'الحقول الناقصة'}: ${missing.join('، ')}',
                      style: TextStyle(
                          fontSize: context.dynamicWidth(0.032),
                          color: Colors.orange.shade900),
                    ),
                  ),
                ]),
              ),
            ],
            PrimaryButton(
              text: l?.translate('wizard_continue_to_guests') ??
                  'Continue to Guests',
              icon: Icons.arrow_forward_rounded,
              isLoading: isLoading,
              onPressed: canProceed && !isLoading
                  ? () {
                      final cubit = context.read<InvitationCubit>();
                      if (nameController.text.isNotEmpty) {
                        cubit.updateEventName(nameController.text);
                      }
                      if (descriptionController.text.isNotEmpty) {
                        cubit.updateEventDescription(descriptionController.text);
                      }
                      cubit.createDraftAndSaveDetails();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _missingFields(InvitationState state, AppLocalizations? l) {
    final missing = <String>[];
    if (state.selectedEventType == null) {
      missing.add(l?.translate('invitation_event_type') ?? 'نوع المناسبة');
    } else {
      if (state.selectedEventType!.isCustom &&
          (state.customEventTypeName?.isEmpty ?? true)) {
        missing.add(l?.translate('invitation_custom_event_type_name') ??
            'اسم نوع المناسبة');
      }
      final hasCover = (state.generatedImageUrl?.isNotEmpty ?? false) ||
          state.uploadedTemplateFile != null ||
          (state.uploadedTemplateDescription?.isNotEmpty ?? false);
      if (!hasCover) {
        missing.add(l?.translate('invitation_cover_image') ?? 'صورة الدعوة');
      }
    }
    if (state.eventName == null || state.eventName!.isEmpty) {
      missing.add(l?.translate('invitation_event_name_required')
              ?.replaceAll(' *', '') ?? 'اسم المناسبة');
    }
    if (state.eventDate == null) {
      missing.add(l?.translate('invitation_date_required')
              ?.replaceAll(' *', '') ?? 'التاريخ');
    }
    if (state.eventTime == null) {
      missing.add(l?.translate('invitation_time_required')
              ?.replaceAll(' *', '') ?? 'الوقت');
    }
    return missing;
  }
}
