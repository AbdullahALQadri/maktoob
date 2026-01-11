import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../data/models/event_models.dart';
import '../../../domain/entities/guest_entity.dart';

enum CreateEventStatus { initial, loading, success, failure }

enum CreateEventStep {
  package,
  venue,
  eventType,
  template,
  eventDetails,
  guests,
  summary,
}

class CreateEventState extends Equatable {
  final CreateEventStatus status;
  final CreateEventStep currentStep;
  final String? errorMessage;
  final String? createdEventId;

  // Step 1: Package
  final String? selectedPackageId;

  // Step 2: Venue
  final String? selectedVenueId;
  final bool showCustomVenue;
  final CustomVenue customVenue;

  // Step 3: Event Type
  final String? selectedEventTypeId;
  final bool showCustomEventType;
  final String customEventType;

  // Step 4: Template
  final String? selectedTemplateId;
  final bool requestCustomTemplate;

  // Step 5: Event Details
  final EventDetails eventDetails;

  // Step 6: Guests
  final GuestMethod? guestMethod;
  final List<GuestInfo> manualGuests;
  final GuestInfo currentGuest;
  final File? excelFile;

  const CreateEventState({
    this.status = CreateEventStatus.initial,
    this.currentStep = CreateEventStep.package,
    this.errorMessage,
    this.createdEventId,
    // Step 1
    this.selectedPackageId,
    // Step 2
    this.selectedVenueId,
    this.showCustomVenue = false,
    this.customVenue = const CustomVenue(),
    // Step 3
    this.selectedEventTypeId,
    this.showCustomEventType = false,
    this.customEventType = '',
    // Step 4
    this.selectedTemplateId,
    this.requestCustomTemplate = false,
    // Step 5
    this.eventDetails = const EventDetails(),
    // Step 6
    this.guestMethod,
    this.manualGuests = const [],
    this.currentGuest = const GuestInfo(),
    this.excelFile,
  });

  int get currentStepNumber => currentStep.index + 1;
  int get totalSteps => CreateEventStep.values.length;
  bool get isFirstStep => currentStep == CreateEventStep.package;
  bool get isLastStep => currentStep == CreateEventStep.summary;
  bool get isLoading => status == CreateEventStatus.loading;
  bool get isSuccess => status == CreateEventStatus.success;
  bool get isFailure => status == CreateEventStatus.failure;

  bool get canProceedStep1 => selectedPackageId != null;
  bool get canProceedStep2 => selectedVenueId != null || (showCustomVenue && customVenue.isValid);
  bool get canProceedStep3 => selectedEventTypeId != null || (showCustomEventType && customEventType.isNotEmpty);
  bool get canProceedStep4 => selectedTemplateId != null || requestCustomTemplate;
  bool get canProceedStep5 => eventDetails.isValid;
  bool get canProceedStep6 => guestMethod != null;
  bool get canProceedStep7 => true;

  bool get canProceed {
    switch (currentStep) {
      case CreateEventStep.package:
        return canProceedStep1;
      case CreateEventStep.venue:
        return canProceedStep2;
      case CreateEventStep.eventType:
        return canProceedStep3;
      case CreateEventStep.template:
        return canProceedStep4;
      case CreateEventStep.eventDetails:
        return canProceedStep5;
      case CreateEventStep.guests:
        return canProceedStep6;
      case CreateEventStep.summary:
        return canProceedStep7;
    }
  }

  CreateEventState copyWith({
    CreateEventStatus? status,
    CreateEventStep? currentStep,
    String? errorMessage,
    String? createdEventId,
    // Step 1
    String? selectedPackageId,
    bool clearPackage = false,
    // Step 2
    String? selectedVenueId,
    bool? showCustomVenue,
    CustomVenue? customVenue,
    bool clearVenue = false,
    // Step 3
    String? selectedEventTypeId,
    bool? showCustomEventType,
    String? customEventType,
    bool clearEventType = false,
    // Step 4
    String? selectedTemplateId,
    bool? requestCustomTemplate,
    bool clearTemplate = false,
    // Step 5
    EventDetails? eventDetails,
    // Step 6
    GuestMethod? guestMethod,
    List<GuestInfo>? manualGuests,
    GuestInfo? currentGuest,
    File? excelFile,
    bool clearExcelFile = false,
  }) {
    return CreateEventState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      errorMessage: errorMessage ?? this.errorMessage,
      createdEventId: createdEventId ?? this.createdEventId,
      // Step 1
      selectedPackageId: clearPackage ? null : (selectedPackageId ?? this.selectedPackageId),
      // Step 2
      selectedVenueId: clearVenue ? null : (selectedVenueId ?? this.selectedVenueId),
      showCustomVenue: showCustomVenue ?? this.showCustomVenue,
      customVenue: customVenue ?? this.customVenue,
      // Step 3
      selectedEventTypeId: clearEventType ? null : (selectedEventTypeId ?? this.selectedEventTypeId),
      showCustomEventType: showCustomEventType ?? this.showCustomEventType,
      customEventType: customEventType ?? this.customEventType,
      // Step 4
      selectedTemplateId: clearTemplate ? null : (selectedTemplateId ?? this.selectedTemplateId),
      requestCustomTemplate: requestCustomTemplate ?? this.requestCustomTemplate,
      // Step 5
      eventDetails: eventDetails ?? this.eventDetails,
      // Step 6
      guestMethod: guestMethod ?? this.guestMethod,
      manualGuests: manualGuests ?? this.manualGuests,
      currentGuest: currentGuest ?? this.currentGuest,
      excelFile: clearExcelFile ? null : (excelFile ?? this.excelFile),
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentStep,
        errorMessage,
        createdEventId,
        selectedPackageId,
        selectedVenueId,
        showCustomVenue,
        customVenue,
        selectedEventTypeId,
        showCustomEventType,
        customEventType,
        selectedTemplateId,
        requestCustomTemplate,
        eventDetails,
        guestMethod,
        manualGuests,
        currentGuest,
        excelFile,
      ];
}

// Immutable versions of the models for state management
class CustomVenue extends Equatable {
  final String name;
  final String address;
  final String capacity;

  const CustomVenue({
    this.name = '',
    this.address = '',
    this.capacity = '',
  });

  bool get isValid => name.isNotEmpty && address.isNotEmpty;

  CustomVenue copyWith({
    String? name,
    String? address,
    String? capacity,
  }) {
    return CustomVenue(
      name: name ?? this.name,
      address: address ?? this.address,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  List<Object?> get props => [name, address, capacity];
}

class EventDetails extends Equatable {
  final String name;
  final DateTime? date;
  final DateTime? time;
  final DateTime? responseDeadline;
  final int maxCompanions;
  final bool allowCompanions;

  const EventDetails({
    this.name = '',
    this.date,
    this.time,
    this.responseDeadline,
    this.maxCompanions = 2,
    this.allowCompanions = true,
  });

  bool get isValid => name.isNotEmpty && date != null && time != null;

  EventDetails copyWith({
    String? name,
    DateTime? date,
    DateTime? time,
    DateTime? responseDeadline,
    int? maxCompanions,
    bool? allowCompanions,
    bool clearDate = false,
    bool clearTime = false,
    bool clearDeadline = false,
  }) {
    return EventDetails(
      name: name ?? this.name,
      date: clearDate ? null : (date ?? this.date),
      time: clearTime ? null : (time ?? this.time),
      responseDeadline: clearDeadline ? null : (responseDeadline ?? this.responseDeadline),
      maxCompanions: maxCompanions ?? this.maxCompanions,
      allowCompanions: allowCompanions ?? this.allowCompanions,
    );
  }

  @override
  List<Object?> get props => [name, date, time, responseDeadline, maxCompanions, allowCompanions];
}

class GuestInfo extends Equatable {
  final String name;
  final String email;
  final String phone;

  const GuestInfo({
    this.name = '',
    this.email = '',
    this.phone = '',
  });

  bool get isValid => name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty;

  GuestInfo copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return GuestInfo(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  GuestEntity toEntity(String id) {
    return GuestEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      status: GuestStatus.pending,
    );
  }

  @override
  List<Object?> get props => [name, email, phone];
}
