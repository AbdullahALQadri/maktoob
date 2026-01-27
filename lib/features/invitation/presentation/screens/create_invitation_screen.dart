import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../data/models/invitation_draft_model.dart';
import '../cubit/invitation_cubit.dart';
import '../cubit/invitation_state.dart';
import '../widgets/invitation_preview_widget.dart';
import '../widgets/template_selector_widget.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(context.dynamicWidth(0.021)),
          child: GestureDetector(
            onTap: () {
              context.read<InvitationCubit>().previousStep();
              widget.onBack?.call();
            },
            child: Container(
              width: context.dynamicWidth(0.101),
              height: context.dynamicWidth(0.101),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gray200,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.gray800,
                size: context.dynamicWidth(0.056),
              ),
            ),
          ),
        ),
        title: Text(
          'Create Invitation',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
            fontSize: context.dynamicWidth(0.045),
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<InvitationCubit, InvitationState>(
        builder: (context, state) {
          return Column(
            children: [
              // Scrollable content (Preview + Form)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Live Preview
                    Container(
                      height: context.dynamicHeight(0.28),
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: context.dynamicWidth(0.04),
                        vertical: context.dynamicWidth(0.021),
                      ),
                      child: InvitationPreviewWidget(
                        eventType: state.eventType,
                        names: state.names,
                        eventDate: state.eventDate,
                        eventTime: state.eventTime,
                        location: state.location,
                        templateId: state.selectedTemplateId,
                        showMarketingFooter: true,
                      ),
                    ),

                    // Form section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.dynamicWidth(0.061)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: context.dynamicHeight(0.02)),

                          // Name fields (dynamic based on event type)
                          ..._buildNameFields(context, state),

                          SizedBox(height: context.dynamicHeight(0.025)),

                          // Date and Time row
                          Row(
                            children: [
                              // Date picker
                              Expanded(
                                child: _buildDatePicker(context, state),
                              ),
                              SizedBox(width: context.dynamicWidth(0.04)),
                              // Time picker
                              Expanded(
                                child: _buildTimePicker(context, state),
                              ),
                            ],
                          ),

                          SizedBox(height: context.dynamicHeight(0.025)),

                          // Location
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.04),
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray800,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(0.01)),
                          AppTextField(
                            controller: _locationController,
                            hintText: 'Venue name',
                            prefixIcon: Icons.location_on_outlined,
                            onChanged: (value) {
                              context.read<InvitationCubit>().updateLocation(value);
                            },
                          ),
                          SizedBox(height: context.dynamicHeight(0.015)),
                          AppTextField(
                            controller: _addressController,
                            hintText: 'Full address',
                            prefixIcon: Icons.map_outlined,
                            onChanged: (value) {
                              context
                                  .read<InvitationCubit>()
                                  .updateLocationAddress(value);
                            },
                          ),

                          SizedBox(height: context.dynamicHeight(0.03)),

                          // Template selection
                          Text(
                            'Choose Template',
                            style: TextStyle(
                              fontSize: context.dynamicWidth(0.04),
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray800,
                            ),
                          ),
                          SizedBox(height: context.dynamicHeight(0.015)),
                          TemplateSelectorWidget(
                            selectedTemplateId: state.selectedTemplateId,
                            onTemplateSelected: (templateId) {
                              context
                                  .read<InvitationCubit>()
                                  .selectTemplateById(templateId);
                            },
                          ),

                          SizedBox(height: context.dynamicHeight(0.1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom button with BackdropFilter
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.all(context.dynamicWidth(0.04)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.gray200.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'Continue to Add Guests',
                          onPressed: state.canProceedFromCreation
                              ? () {
                                  context.read<InvitationCubit>().nextStep();
                                  widget.onContinue?.call();
                                }
                              : null,
                          isDisabled: !state.canProceedFromCreation,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildNameFields(BuildContext context, InvitationState state) {
    final eventType = state.eventType;
    if (eventType == null) return [];

    final labels = eventType.nameFieldLabels;
    final widgets = <Widget>[];

    for (int i = 0; i < labels.length; i++) {
      if (i >= _nameControllers.length) {
        _nameControllers.add(TextEditingController());
      }

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labels[i],
              style: TextStyle(
                fontSize: context.dynamicWidth(0.04),
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
            SizedBox(height: context.dynamicWidth(0.021)),
            AppTextField(
              controller: _nameControllers[i],
              hintText: 'Enter ${labels[i].toLowerCase()}',
              prefixIcon: Icons.person_outline,
              onChanged: (value) {
                context.read<InvitationCubit>().updateName(i, value);
              },
            ),
            SizedBox(height: context.dynamicWidth(0.04)),
          ],
        ),
      );
    }

    return widgets;
  }

  Widget _buildDatePicker(BuildContext context, InvitationState state) {
    final dateText = state.eventDate != null
        ? '${state.eventDate!.day}/${state.eventDate!.month}/${state.eventDate!.year}'
        : 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        SizedBox(height: context.dynamicWidth(0.021)),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicWidth(0.035),
            ),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.gray500,
                  size: context.dynamicWidth(0.051),
                ),
                SizedBox(width: context.dynamicWidth(0.029)),
                Text(
                  dateText,
                  style: TextStyle(
                    color: state.eventDate != null
                        ? AppColors.gray800
                        : AppColors.gray400,
                    fontSize: context.dynamicWidth(0.037),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context, InvitationState state) {
    final timeText = state.eventTime != null
        ? '${state.eventTime!.hour.toString().padLeft(2, '0')}:${state.eventTime!.minute.toString().padLeft(2, '0')}'
        : 'Select time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyle(
            fontSize: context.dynamicWidth(0.04),
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
        SizedBox(height: context.dynamicWidth(0.021)),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.dynamicWidth(0.04),
              vertical: context.dynamicWidth(0.035),
            ),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: AppColors.gray500,
                  size: context.dynamicWidth(0.051),
                ),
                SizedBox(width: context.dynamicWidth(0.029)),
                Text(
                  timeText,
                  style: TextStyle(
                    color: state.eventTime != null
                        ? AppColors.gray800
                        : AppColors.gray400,
                    fontSize: context.dynamicWidth(0.037),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.primaryColor,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && mounted) {
      context.read<InvitationCubit>().updateDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.gray900,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.04)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontSize: context.dynamicWidth(0.04),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && mounted) {
      context.read<InvitationCubit>().updateTime(picked);
    }
  }
}
