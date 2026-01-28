import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/widgets.dart';

/// Create Invitation Screen with Live Preview
class CreateInvitationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;

  const CreateInvitationScreen({
    super.key,
    this.onBack,
    this.onContinue,
  });

  @override
  State<CreateInvitationScreen> createState() => _CreateInvitationScreenState();
}

class _CreateInvitationScreenState extends State<CreateInvitationScreen> {
  final List<TextEditingController> _nameControllers = [];
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final state = context.read<InvitationCubit>().state;
    final nameCount = state.eventType?.nameFieldCount ?? 1;

    for (int i = 0; i < nameCount; i++) {
      final controller = TextEditingController(
        text: i < state.names.length ? state.names[i] : '',
      );
      _nameControllers.add(controller);
    }

    _locationController.text = state.location ?? '';
    _addressController.text = state.locationAddress ?? '';
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    _locationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CreateInvitationAppBar(
        onBack: () {
          context.read<InvitationCubit>().previousStep();
          widget.onBack?.call();
        },
      ),
      body: BlocBuilder<InvitationCubit, InvitationState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    InvitationLivePreview(
                      eventType: state.eventType,
                      names: state.names,
                      eventDate: state.eventDate,
                      eventTime: state.eventTime,
                      location: state.location,
                      templateId: state.selectedTemplateId,
                    ),
                    _FormSection(
                      state: state,
                      nameControllers: _nameControllers,
                      locationController: _locationController,
                      addressController: _addressController,
                    ),
                  ],
                ),
              ),
              BackdropActionBar(
                buttonText: 'Continue to Add Guests',
                isEnabled: state.canProceedFromCreation,
                onPressed: () {
                  context.read<InvitationCubit>().nextStep();
                  widget.onContinue?.call();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final InvitationState state;
  final List<TextEditingController> nameControllers;
  final TextEditingController locationController;
  final TextEditingController addressController;

  const _FormSection({
    required this.state,
    required this.nameControllers,
    required this.locationController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.dynamicHeight(0.02)),
          DynamicNameFields(
            eventType: state.eventType,
            controllers: nameControllers,
            onNameChanged: (index, value) {
              context.read<InvitationCubit>().updateName(index, value);
            },
          ),
          SizedBox(height: context.dynamicHeight(0.025)),
          InvitationDateTimePicker(
            selectedDate: state.eventDate,
            selectedTime: state.eventTime,
            onDateTap: () => _selectDate(context),
            onTimeTap: () => _selectTime(context),
          ),
          SizedBox(height: context.dynamicHeight(0.025)),
          InvitationLocationInput(
            locationController: locationController,
            addressController: addressController,
            onLocationChanged: (value) {
              context.read<InvitationCubit>().updateLocation(value);
            },
            onAddressChanged: (value) {
              context.read<InvitationCubit>().updateLocationAddress(value);
            },
          ),
          SizedBox(height: context.dynamicHeight(0.03)),
          InvitationTemplateSection(
            selectedTemplateId: state.selectedTemplateId,
            onTemplateSelected: (templateId) {
              context.read<InvitationCubit>().selectTemplateById(templateId);
            },
          ),
          SizedBox(height: context.dynamicHeight(0.1)),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await InvitationPickerDialogs.pickDate(context);
    if (picked != null && context.mounted) {
      context.read<InvitationCubit>().updateDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await InvitationPickerDialogs.pickTime(context);
    if (picked != null && context.mounted) {
      context.read<InvitationCubit>().updateTime(picked);
    }
  }
}
