// ignore_for_file: deprecated_member_use_from_same_package
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
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> _nameControllers = [];
  final List<FocusNode> _nameFocusNodes = [];
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late FocusNode _locationFocus;
  late FocusNode _addressFocus;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _addressController = TextEditingController();
    _locationFocus = FocusNode();
    _addressFocus = FocusNode();
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
      _nameFocusNodes.add(FocusNode());
    }

    _locationController.text = state.location ?? '';
    _addressController.text = state.locationAddress ?? '';
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final focusNode in _nameFocusNodes) {
      focusNode.dispose();
    }
    _locationController.dispose();
    _addressController.dispose();
    _locationFocus.dispose();
    _addressFocus.dispose();
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
                      formKey: _formKey,
                      state: state,
                      nameControllers: _nameControllers,
                      nameFocusNodes: _nameFocusNodes,
                      locationController: _locationController,
                      addressController: _addressController,
                      locationFocus: _locationFocus,
                      addressFocus: _addressFocus,
                    ),
                  ],
                ),
              ),
              BackdropActionBar(
                buttonText: 'Continue to Add Guests',
                isEnabled: state.canProceedFromEventDetails,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<InvitationCubit>().nextStep();
                    widget.onContinue?.call();
                  }
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
  final GlobalKey<FormState> formKey;
  final InvitationState state;
  final List<TextEditingController> nameControllers;
  final List<FocusNode> nameFocusNodes;
  final TextEditingController locationController;
  final TextEditingController addressController;
  final FocusNode locationFocus;
  final FocusNode addressFocus;

  const _FormSection({
    required this.formKey,
    required this.state,
    required this.nameControllers,
    required this.nameFocusNodes,
    required this.locationController,
    required this.addressController,
    required this.locationFocus,
    required this.addressFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.dynamicHeight(0.02)),
            DynamicNameFields(
              eventType: state.eventType,
              controllers: nameControllers,
              focusNodes: nameFocusNodes,
              nextFocusNode: locationFocus,
              onNameChanged: (index, value) {
                context.read<InvitationCubit>().updateName(index, value);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
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
              locationFocusNode: locationFocus,
              addressFocusNode: addressFocus,
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
