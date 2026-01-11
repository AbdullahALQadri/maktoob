import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/media_query_values.dart';
import '../../data/models/event_models.dart' hide EventDetails, CustomVenue, GuestInfo;
import '../cubit/create_event/create_event_cubit.dart';
import '../cubit/create_event/create_event_state.dart';
import '../widgets/step_header_widget.dart';
import '../widgets/package_card_widget.dart';
import '../widgets/venue_card_widget.dart';
import '../widgets/event_type_card_widget.dart';
import '../widgets/template_card_widget.dart';
import '../widgets/event_details_widget.dart';
import '../widgets/guest_method_widget.dart';
import '../widgets/summary_widget.dart';

class CreateEventScreen extends StatefulWidget {
  final Function(String eventId)? onComplete;

  const CreateEventScreen({super.key, this.onComplete});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // Data - these should be loaded from a repository in a real app
  final List<PackageModel> _packages = [
    PackageModel(
      id: 'silver',
      name: 'Silver',
      price: '299',
      invitations: 100,
      features: ['Basic Templates', 'WhatsApp Delivery', 'QR Code Check-in', 'Email Support'],
      gradientColors: [AppColors.gray400, AppColors.gray500],
      icon: Icons.auto_awesome,
    ),
    PackageModel(
      id: 'gold',
      name: 'Gold',
      price: '599',
      invitations: 300,
      features: ['Premium Templates', 'WhatsApp + SMS', 'QR Code Check-in', 'Analytics Dashboard', 'Priority Support'],
      gradientColors: [AppColors.yellow400, AppColors.amber500],
      icon: Icons.flash_on,
      recommended: true,
    ),
    PackageModel(
      id: 'platinum',
      name: 'Platinum',
      price: '999',
      invitations: -1,
      features: ['Custom Templates', 'All Channels', 'Advanced Analytics', 'Custom Branding', '24/7 Support', 'API Access'],
      gradientColors: [AppColors.purple500, AppColors.pink500],
      icon: Icons.workspace_premium,
    ),
  ];

  final List<VenueModel> _venues = [
    const VenueModel(id: '1', name: 'Grand Hotel Ballroom', capacity: 300, icon: 'hotel'),
    const VenueModel(id: '2', name: 'Convention Center', capacity: 500, icon: 'business'),
    const VenueModel(id: '3', name: 'Beach Resort', capacity: 150, icon: 'beach'),
    const VenueModel(id: '4', name: 'University Hall', capacity: 400, icon: 'school'),
  ];

  final List<EventTypeModel> _eventTypes = [
    EventTypeModel(id: 'wedding', name: 'Wedding', icon: 'wedding', gradientColors: [AppColors.pink500, AppColors.rose500]),
    EventTypeModel(id: 'corporate', name: 'Corporate', icon: 'business', gradientColors: [AppColors.blue500, AppColors.cyan500]),
    EventTypeModel(id: 'birthday', name: 'Birthday', icon: 'cake', gradientColors: [AppColors.amber500, AppColors.orange500]),
    EventTypeModel(id: 'graduation', name: 'Graduation', icon: 'school', gradientColors: [AppColors.green600, AppColors.emerald500]),
    EventTypeModel(id: 'conference', name: 'Conference', icon: 'mic', gradientColors: [AppColors.purple500, AppColors.indigo500]),
    EventTypeModel(id: 'charity', name: 'Charity', icon: 'heart', gradientColors: [AppColors.red500, AppColors.pink500]),
  ];

  final List<TemplateModel> _templates = [
    TemplateModel(id: 'elegant', name: 'Elegant Gold', preview: 'sparkle', gradientColors: [AppColors.amber600, AppColors.amber600]),
    TemplateModel(id: 'modern', name: 'Modern Minimal', preview: 'square', gradientColors: [AppColors.gray700, AppColors.gray900]),
    TemplateModel(id: 'floral', name: 'Floral Dream', preview: 'flower', gradientColors: [AppColors.pink500, AppColors.rose500]),
    TemplateModel(id: 'classic', name: 'Classic White', preview: 'square', gradientColors: [AppColors.gray100, AppColors.gray300]),
    TemplateModel(id: 'luxury', name: 'Luxury Black', preview: 'square', gradientColors: [AppColors.black, AppColors.gray700]),
    TemplateModel(id: 'colorful', name: 'Colorful Joy', preview: 'palette', gradientColors: [AppColors.purple500, AppColors.pink500]),
  ];

  int _getPackageLimit(String packageId) {
    final pkg = _packages.firstWhere(
      (p) => p.id == packageId,
      orElse: () => _packages.first,
    );
    return pkg.invitations;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEventCubit, CreateEventState>(
      listener: (context, state) {
        if (state.isSuccess && state.createdEventId != null) {
          widget.onComplete?.call(state.createdEventId!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully!')),
          );
        }
        if (state.isFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.gray100,
          body: SafeArea(
            child: Column(
              children: [
                StepHeaderWidget(
                  currentStep: state.currentStepNumber,
                  totalSteps: state.totalSteps,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      context.dynamicWidth(0.04),
                      context.dynamicWidth(0.02),
                      context.dynamicWidth(0.04),
                      context.dynamicHeight(0.12),
                    ),
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildStepContent(state),
                        ),
                        SizedBox(height: context.dynamicHeight(0.03)),
                        _buildNavigationButtons(context, state),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(CreateEventState state) {
    switch (state.currentStep) {
      case CreateEventStep.package:
        return PackageSelectionWidget(
          packages: _packages,
          selectedPackage: state.selectedPackageId,
          onPackageSelected: (id) => context.read<CreateEventCubit>().selectPackage(id),
        );
      case CreateEventStep.venue:
        return VenueSelectionWidget(
          venues: _venues,
          selectedVenue: state.selectedVenueId,
          showCustomVenue: state.showCustomVenue,
          customVenue: _convertToMutableCustomVenue(state.customVenue),
          onVenueSelected: (id) => context.read<CreateEventCubit>().selectVenue(id),
          onToggleCustomVenue: () => context.read<CreateEventCubit>().toggleCustomVenue(),
          onCustomVenueChanged: (venue) => context.read<CreateEventCubit>().updateCustomVenue(
            CustomVenue(
              name: venue.name,
              address: venue.address,
              capacity: venue.capacity,
            ),
          ),
        );
      case CreateEventStep.eventType:
        return EventTypeSelectionWidget(
          eventTypes: _eventTypes,
          selectedEventType: state.selectedEventTypeId,
          showCustomEventType: state.showCustomEventType,
          customEventType: state.customEventType,
          onEventTypeSelected: (id) => context.read<CreateEventCubit>().selectEventType(id),
          onToggleCustomEventType: () => context.read<CreateEventCubit>().toggleCustomEventType(),
          onCustomEventTypeChanged: (value) => context.read<CreateEventCubit>().updateCustomEventType(value),
        );
      case CreateEventStep.template:
        return TemplateSelectionWidget(
          templates: _templates,
          selectedTemplate: state.selectedTemplateId,
          requestCustomTemplate: state.requestCustomTemplate,
          onTemplateSelected: (id) => context.read<CreateEventCubit>().selectTemplate(id),
          onToggleCustomTemplate: () => context.read<CreateEventCubit>().toggleCustomTemplate(),
        );
      case CreateEventStep.eventDetails:
        return EventDetailsWidget(
          eventDetails: _convertToMutableEventDetails(state.eventDetails),
          onDetailsChanged: (details) => context.read<CreateEventCubit>().updateEventDetails(
            EventDetails(
              name: details.name,
              date: details.date,
              time: details.time != null
                  ? DateTime(2000, 1, 1, details.time!.hour, details.time!.minute)
                  : null,
              responseDeadline: details.responseDeadline,
              maxCompanions: details.maxCompanions,
              allowCompanions: details.allowCompanions,
            ),
          ),
        );
      case CreateEventStep.guests:
        return GuestMethodWidget(
          packageLimit: _getPackageLimit(state.selectedPackageId ?? ''),
          guestMethod: state.guestMethod,
          manualGuests: state.manualGuests.map((g) => _convertToMutableGuestInfo(g)).toList(),
          currentGuest: _convertToMutableGuestInfo(state.currentGuest),
          excelFile: state.excelFile,
          onGuestMethodSelected: (method) => context.read<CreateEventCubit>().selectGuestMethod(method),
          onAddGuest: () => context.read<CreateEventCubit>().addGuest(),
          onRemoveGuest: (index) => context.read<CreateEventCubit>().removeGuest(index),
          onCurrentGuestChanged: (guest) => context.read<CreateEventCubit>().updateCurrentGuest(
            GuestInfo(name: guest.name, email: guest.email, phone: guest.phone),
          ),
          onExcelFileSelected: (file) => context.read<CreateEventCubit>().setExcelFile(file),
        );
      case CreateEventStep.summary:
        return SummaryWidget(
          selectedPackage: _packages.firstWhere(
            (p) => p.id == state.selectedPackageId,
            orElse: () => _packages.first,
          ),
          selectedVenue: state.selectedVenueId != null
              ? _venues.firstWhere((v) => v.id == state.selectedVenueId)
              : null,
          customVenue: state.showCustomVenue
              ? _convertToMutableCustomVenue(state.customVenue)
              : null,
          selectedEventType: state.selectedEventTypeId != null
              ? _eventTypes.firstWhere((t) => t.id == state.selectedEventTypeId)
              : null,
          customEventType: state.showCustomEventType ? state.customEventType : null,
          selectedTemplate: state.selectedTemplateId != null
              ? _templates.firstWhere((t) => t.id == state.selectedTemplateId)
              : null,
          requestCustomTemplate: state.requestCustomTemplate,
          eventDetails: _convertToMutableEventDetails(state.eventDetails),
          guestMethod: state.guestMethod,
          manualGuests: state.manualGuests.map((g) => _convertToMutableGuestInfo(g)).toList(),
          excelFile: state.excelFile,
        );
    }
  }

  Widget _buildNavigationButtons(BuildContext context, CreateEventState state) {
    if (state.isLastStep) {
      return Row(
        children: [
          Expanded(
            child: _buildButton(
              'Save as Draft',
              onTap: state.isLoading
                  ? null
                  : () => context.read<CreateEventCubit>().saveDraft(),
              isPrimary: false,
            ),
          ),
          SizedBox(width: context.dynamicWidth(0.03)),
          Expanded(
            child: _buildButton(
              'Submit & Pay',
              onTap: state.isLoading
                  ? null
                  : () => context.read<CreateEventCubit>().submitEvent(),
              isPrimary: true,
              isLoading: state.isLoading,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (!state.isFirstStep)
          Container(
            width: context.dynamicHeight(0.06),
            height: context.dynamicHeight(0.06),
            margin: EdgeInsets.only(right: context.dynamicWidth(0.03)),
            child: Material(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
              child: InkWell(
                borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                onTap: () => context.read<CreateEventCubit>().previousStep(),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.gray700,
                  size: context.dynamicWidth(0.05),
                ),
              ),
            ),
          ),
        Expanded(
          child: _buildButton(
            'Continue',
            onTap: state.canProceed
                ? () => context.read<CreateEventCubit>().nextStep()
                : null,
            isPrimary: true,
            trailing: Icons.arrow_forward,
          ),
        ),
      ],
    );
  }

  // Helper methods to convert between immutable state objects and mutable widget objects
  MutableCustomVenue _convertToMutableCustomVenue(CustomVenue venue) {
    return MutableCustomVenue(
      name: venue.name,
      address: venue.address,
      capacity: venue.capacity,
    );
  }

  MutableEventDetails _convertToMutableEventDetails(EventDetails details) {
    return MutableEventDetails(
      name: details.name,
      date: details.date,
      time: details.time != null
          ? TimeOfDay(hour: details.time!.hour, minute: details.time!.minute)
          : null,
      responseDeadline: details.responseDeadline,
      maxCompanions: details.maxCompanions,
      allowCompanions: details.allowCompanions,
    );
  }

  MutableGuestInfo _convertToMutableGuestInfo(GuestInfo guest) {
    return MutableGuestInfo(
      name: guest.name,
      email: guest.email,
      phone: guest.phone,
    );
  }

  Widget _buildButton(
    String text, {
    VoidCallback? onTap,
    bool isPrimary = true,
    IconData? trailing,
    bool isLoading = false,
  }) {
    final enabled = onTap != null;

    return Material(
      color: enabled
          ? (isPrimary ? null : AppColors.gray200)
          : AppColors.gray200,
      borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
        onTap: onTap,
        child: Container(
          height: context.dynamicHeight(0.06),
          decoration: enabled && isPrimary
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(context.dynamicWidth(0.03)),
                  gradient: LinearGradient(
                    colors: [AppColors.purple600, AppColors.pink600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple600.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: context.dynamicWidth(0.05),
                    height: context.dynamicWidth(0.05),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: context.dynamicWidth(0.038),
                        color: enabled
                            ? (isPrimary ? Colors.white : AppColors.gray700)
                            : AppColors.gray400,
                      ),
                    ),
                    if (trailing != null) ...[
                      SizedBox(width: context.dynamicWidth(0.02)),
                      Icon(
                        trailing,
                        color: enabled ? Colors.white : AppColors.gray400,
                        size: context.dynamicWidth(0.045),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// Mutable versions for widget compatibility
class MutableCustomVenue {
  String name;
  String address;
  String capacity;

  MutableCustomVenue({
    this.name = '',
    this.address = '',
    this.capacity = '',
  });

  bool get isValid => name.isNotEmpty && address.isNotEmpty;
}

class MutableEventDetails {
  String name;
  DateTime? date;
  TimeOfDay? time;
  DateTime? responseDeadline;
  int maxCompanions;
  bool allowCompanions;

  MutableEventDetails({
    this.name = '',
    this.date,
    this.time,
    this.responseDeadline,
    this.maxCompanions = 2,
    this.allowCompanions = true,
  });

  bool get isValid => name.isNotEmpty && date != null && time != null;
}

class MutableGuestInfo {
  String name;
  String email;
  String phone;

  MutableGuestInfo({
    this.name = '',
    this.email = '',
    this.phone = '',
  });

  bool get isValid => name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;

  MutableGuestInfo copy() => MutableGuestInfo(name: name, email: email, phone: phone);
}
