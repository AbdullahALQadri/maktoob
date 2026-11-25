import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/locale/l10n_context.dart';
import '../../../../../core/core.dart';
import '../../../data/models/location_model.dart';
import '../../../domain/utils/event_setup_rules.dart';
import '../../cubit/invitation_cubit.dart';
import '../../cubit/invitation_state.dart';
import '../../widgets/details/event_date_time_card.dart';
import '../../widgets/details/event_title_and_pin.dart';
import '../../widgets/details/event_type_trigger.dart';
import '../../widgets/details/wizard_inputs.dart';
import '../../widgets/widgets.dart';

/// Step 1: the occasion and its details (title, date, place, a few words).
class DetailsStep extends StatefulWidget {
  const DetailsStep({super.key});

  @override
  State<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<DetailsStep> {
  final _name = TextEditingController();
  final _place = TextEditingController();
  final _description = TextEditingController();

  /// Turns on the inline "required" messages once the host tries to go on.
  bool _showFieldErrors = false;

  @override
  void initState() {
    super.initState();
    _fill(context.read<InvitationCubit>().state);
  }

  void _fill(InvitationState state) {
    _name.text = state.eventName ?? '';
    _place.text = state.customLocation?.placeName ?? '';
    _description.text = state.eventDescription ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _place.dispose();
    _description.dispose();
    super.dispose();
  }

  void _placeTyped(InvitationState state, String text) {
    // The typed line is the whole place; a map pin, if any, is kept.
    final pin = state.customLocation;
    context.read<InvitationCubit>().setCustomLocation(
          LocationModel(
            placeName: text,
            address: pin?.address ?? '',
            latitude: pin?.latitude ?? 0,
            longitude: pin?.longitude ?? 0,
          ),
        );
  }

  Future<void> _openMap(InvitationState state) async {
    final cubit = context.read<InvitationCubit>();
    final current = state.customLocation;
    final inGaza = current != null && EventSetupRules.isInGaza(current.latitude, current.longitude);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (page) => GoogleMapsPickerWidget(
          initialLocation: inGaza ? current : null,
          onLocationSelected: (picked) {
            if (!EventSetupRules.isInGaza(picked.latitude, picked.longitude)) {
              AppSnackBar.showError(page, message: page.tr('map_gaza_only'));
              return;
            }
            final typed = _place.text.trim();
            cubit.setCustomLocation(
              LocationModel(
                latitude: picked.latitude,
                longitude: picked.longitude,
                address: picked.address,
                placeName: typed.isNotEmpty ? typed : picked.address,
              ),
            );
            if (typed.isEmpty) _place.text = picked.address;
            Navigator.of(page).pop();
          },
        ),
      ),
    );
  }

  void _continue(InvitationState state) {
    if (state.isLoadingFormFields) return;
    if (state.missingRequiredFormFields.isNotEmpty) {
      setState(() => _showFieldErrors = true);
      return;
    }
    // An empty title is fine: the backend writes the suggested one.
    context.read<InvitationCubit>()
      ..updateEventName(_name.text.trim())
      ..updateEventDescription(_description.text.trim())
      ..createDraftAndSaveDetails();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InvitationCubit>();
    return BlocConsumer<InvitationCubit, InvitationState>(
      listenWhen: (before, now) =>
          (before.errorMessage != now.errorMessage && now.errorMessage != null) ||
          before.draftEventId != now.draftEventId,
      listener: (context, state) {
        // A draft was just loaded: show what it holds.
        if (_name.text.isEmpty && _place.text.isEmpty && _description.text.isEmpty) _fill(state);
        showWizardError(context, state);
      },
      builder: (context, state) {
        final ready = state.canProceedFromEventType && state.canProceedFromEventDetails;
        return WizardStepFrame(
          step: InvitationStep.details,
          actionLabel: context.tr('wizard_save_and_continue'),
          isBusy: state.isLoading,
          onAction: ready ? () => _continue(state) : null,
          children: [
            WizardLabeledInput(
              label: context.tr('wizard_event_type_label'),
              child: EventTypeTrigger(state: state),
            ),
            if (state.isLoadingFormFields || state.eventTypeFormFields.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              EventTypeFieldsSection(
                typeKey: state.selectedEventType?.id,
                fields: state.eventTypeFormFields,
                values: state.eventTypeFormData,
                isLoading: state.isLoadingFormFields,
                showErrors: _showFieldErrors,
                onChanged: cubit.updateEventTypeFormField,
              ),
            ],
            const SizedBox(height: 20),
            EventTitleInput(controller: _name, state: state, onChanged: cubit.updateEventName),
            const SizedBox(height: 20),
            EventDateTimeCard(state: state),
            const SizedBox(height: 20),
            WizardLabeledInput(
              label: context.tr('wizard_event_location_label'),
              child: WizardTextField(
                controller: _place,
                hintText: context.tr('wizard_event_location_hint'),
                prefixIcon: Icons.location_on_outlined,
                onChanged: (text) => _placeTyped(state, text),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            MapPinButton(state: state, onPick: () => _openMap(state)),
            const SizedBox(height: 20),
            WizardLabeledInput(
              label: context.tr('wizard_description_label'),
              child: WizardTextField(
                controller: _description,
                hintText: context.tr('wizard_description_hint'),
                maxLines: 3,
              ),
            ),
          ],
        );
      },
    );
  }
}
