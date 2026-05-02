import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/core.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Page 2: Event Details (name, date, time, location, form fields)
class Page2EventDetailsScreen extends StatefulWidget {
  const Page2EventDetailsScreen({super.key});

  @override
  State<Page2EventDetailsScreen> createState() =>
      _Page2EventDetailsScreenState();
}

class _Page2EventDetailsScreenState extends State<Page2EventDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _aiImageUrl; // set when user selects an AI-generated cover

  @override
  void initState() {
    super.initState();
    final state = context.read<InvitationCubit>().state;
    _nameController.text = state.eventName ?? '';
    _descriptionController.text = state.eventDescription ?? '';
  }

  Future<void> _openAiDesign(BuildContext ctx, InvitationState state) async {
    final eventId     = state.draftEventId;
    final eventTypeId = state.selectedEventType?.id;
    if (eventId == null || eventTypeId == null) return;

    final result = await Navigator.of(ctx).pushNamed(
      Routes.aiDesign,
      arguments: {'eventId': eventId, 'eventTypeId': eventTypeId},
    );

    if (result is String && result.isNotEmpty && mounted) {
      setState(() => _aiImageUrl = result);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BlocBuilder<InvitationCubit, InvitationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              WizardStepHeader(
                currentStep: 2,
                totalSteps: 7,
                title:
                    l?.translate('invitation_step2_title') ?? 'Event Details',
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.051)),
                    child: _Page2Content(
                      state: state,
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      aiImageUrl: _aiImageUrl,
                      onOpenAiDesign: () => _openAiDesign(context, state),
                    ),
                  ),
                ),
              ),
              WizardBottomBar(
                canProceed: state.canProceedFromEventDetails && !state.isLoading,
                onNext: () {
                  // Ensure event name is saved from controller before proceeding
                  final cubit = context.read<InvitationCubit>();
                  if (_nameController.text.isNotEmpty) {
                    cubit.updateEventName(_nameController.text);
                  }
                  if (_descriptionController.text.isNotEmpty) {
                    cubit.updateEventDescription(_descriptionController.text);
                  }
                  cubit.saveDetailsAndProceed();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Page2Content extends StatelessWidget {
  final InvitationState state;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String? aiImageUrl;
  final VoidCallback onOpenAiDesign;

  const _Page2Content({
    required this.state,
    required this.nameController,
    required this.descriptionController,
    this.aiImageUrl,
    required this.onOpenAiDesign,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.dynamicHeight(0.025)),
        _SectionTitle(
            text: l?.translate('invitation_event_name_required') ??
                'Event Name *'),
        SizedBox(height: context.dynamicHeight(0.01)),
        AppTextField(
          controller: nameController,
          hintText:
              l?.translate('invitation_enter_event_name') ?? 'Enter event name',
          prefixIcon: Icons.event,
          onChanged: (value) {
            context.read<InvitationCubit>().updateEventName(value);
          },
        ),
        if (!state.isCustomEventType &&
            !state.isCustomTemplate &&
            state.eventTypeFormFields.isNotEmpty) ...[
          SizedBox(height: context.dynamicHeight(0.025)),
          _EventTypeFormFields(state: state),
        ],
        SizedBox(height: context.dynamicHeight(0.025)),
        _SectionTitle(
            text: l?.translate('invitation_description_optional_label') ??
                'Description (Optional)'),
        SizedBox(height: context.dynamicHeight(0.01)),
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
        SizedBox(height: context.dynamicHeight(0.025)),
        _SectionTitle(
            text: l?.translate('invitation_date_required') ?? 'Date *'),
        SizedBox(height: context.dynamicHeight(0.01)),
        EventDatePicker(selectedDate: state.eventDate),
        SizedBox(height: context.dynamicHeight(0.025)),
        _SectionTitle(
            text: l?.translate('invitation_time_required') ?? 'Time *'),
        SizedBox(height: context.dynamicHeight(0.01)),
        EventTimePicker(selectedTime: state.eventTime),
        SizedBox(height: context.dynamicHeight(0.025)),
        _SectionTitle(
            text: l?.translate('invitation_location_required') ?? 'Location *'),
        SizedBox(height: context.dynamicHeight(0.01)),
        EventLocationSection(state: state),
        SizedBox(height: context.dynamicHeight(0.025)),
        _AiDesignSection(imageUrl: aiImageUrl, onTap: onOpenAiDesign),
        SizedBox(height: context.dynamicHeight(0.025)),
        CompanionsSection(state: state),
        SizedBox(height: context.dynamicHeight(0.119)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.dynamicWidth(0.035),
        fontWeight: FontWeight.w500,
        color: context.textTertiary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AI Design Section
// ─────────────────────────────────────────────────────────────────

class _AiDesignSection extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const _AiDesignSection({this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(
        text: l?.translate('invitation_cover_image') ?? 'صورة الدعوة',
      ),
      SizedBox(height: context.dynamicHeight(0.012)),

      // If an AI image has been selected → show preview
      if (imageUrl != null && imageUrl!.isNotEmpty) ...[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        ),
        SizedBox(height: context.dynamicHeight(0.012)),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l?.translate('ai_regenerate_image') ?? 'تغيير الصورة'),
          ),
        ),
      ] else ...[
        // No image yet → show invitation card
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.3)),
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.05), primary.withOpacity(0.12)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    l?.translate('ai_design_title') ?? 'تصميم الدعوة بالذكاء الاصطناعي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: context.dynamicWidth(0.038),
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l?.translate('ai_design_subtitle') ??
                        'اختر من التصاميم أو أنشئ تصميماً فريداً',
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
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────

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
        _SectionTitle(text: t.translate('invitation_couple_info')),
        SizedBox(height: context.dynamicHeight(0.01)),
        ...state.eventTypeFormFields.map((field) {
          IconData fieldIcon = Icons.person_outline;
          if (field.key == 'groom_name') {
            fieldIcon = Icons.person;
          } else if (field.key == 'bride_name') {
            fieldIcon = Icons.person_outline;
          }

          final label = isArabic ? field.labelAr : field.label;
          final hint =
              isArabic ? (field.hintAr ?? field.labelAr) : (field.hint ?? field.label);

          return Padding(
            padding: EdgeInsets.only(bottom: context.dynamicHeight(0.02)),
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
