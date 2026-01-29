import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/app_localizations.dart';
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
                    ),
                  ),
                ),
              ),
              WizardBottomBar(canProceed: state.canProceedFromEventDetails),
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

  const _Page2Content({
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
        color: AppColors.gray700,
      ),
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
