import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/invitation_draft_model.dart';

/// Steps in the Golden Scenario invitation flow
enum InvitationStep {
  landing,
  eventType,
  creation,
  guests,
  share,
  package,
  payment,
  confirmation,
}

/// Status of invitation operations
enum InvitationStatus {
  initial,
  loading,
  success,
  failure,
}

/// Main state for the invitation feature
class InvitationState extends Equatable {
  final InvitationStep currentStep;
  final InvitationStatus status;

  // Event Type
  final GoldenEventType? eventType;
  final String? customEventTypeName;

  // Names (dynamic based on event type)
  final List<String> names;

  // Event Details
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final String? location;
  final String? locationAddress;

  // Template
  final String? selectedTemplateId;
  final bool requestCustomTemplate;

  // Guests
  final List<GuestInfoModel> guests;
  final GuestInfoModel currentGuestInput;

  // Package
  final String? selectedPackageId;

  // Results
  final String? shareLink;
  final String? invitationId;
  final String? errorMessage;

  const InvitationState({
    this.currentStep = InvitationStep.landing,
    this.status = InvitationStatus.initial,
    this.eventType,
    this.customEventTypeName,
    this.names = const [],
    this.eventDate,
    this.eventTime,
    this.location,
    this.locationAddress,
    this.selectedTemplateId,
    this.requestCustomTemplate = false,
    this.guests = const [],
    this.currentGuestInput = const GuestInfoModel(name: ''),
    this.selectedPackageId,
    this.shareLink,
    this.invitationId,
    this.errorMessage,
  });

  /// Initial state
  factory InvitationState.initial() => const InvitationState();

  /// Copy with method for immutable state updates
  InvitationState copyWith({
    InvitationStep? currentStep,
    InvitationStatus? status,
    GoldenEventType? eventType,
    String? customEventTypeName,
    List<String>? names,
    DateTime? eventDate,
    TimeOfDay? eventTime,
    String? location,
    String? locationAddress,
    String? selectedTemplateId,
    bool? requestCustomTemplate,
    List<GuestInfoModel>? guests,
    GuestInfoModel? currentGuestInput,
    String? selectedPackageId,
    String? shareLink,
    String? invitationId,
    String? errorMessage,
    bool clearEventType = false,
    bool clearError = false,
  }) {
    return InvitationState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      eventType: clearEventType ? null : (eventType ?? this.eventType),
      customEventTypeName: customEventTypeName ?? this.customEventTypeName,
      names: names ?? this.names,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      location: location ?? this.location,
      locationAddress: locationAddress ?? this.locationAddress,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      requestCustomTemplate:
          requestCustomTemplate ?? this.requestCustomTemplate,
      guests: guests ?? this.guests,
      currentGuestInput: currentGuestInput ?? this.currentGuestInput,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
      shareLink: shareLink ?? this.shareLink,
      invitationId: invitationId ?? this.invitationId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // Validation helpers

  /// Check if event type step is complete
  bool get canProceedFromEventType => eventType != null;

  /// Check if creation step is complete
  bool get canProceedFromCreation {
    if (eventType == null) return false;

    // Check if all required name fields are filled
    final requiredNames = eventType!.nameFieldCount;
    if (names.length < requiredNames) return false;
    if (names.any((name) => name.trim().isEmpty)) return false;

    // Check date and time
    if (eventDate == null || eventTime == null) return false;

    // Check template
    if (selectedTemplateId == null && !requestCustomTemplate) return false;

    return true;
  }

  /// Check if guests step is complete (at least one guest)
  bool get canProceedFromGuests => guests.isNotEmpty;

  /// Check if package step is complete
  bool get canProceedFromPackage => selectedPackageId != null;

  /// Get progress percentage (0.0 - 1.0)
  double get progressPercentage {
    switch (currentStep) {
      case InvitationStep.landing:
        return 0.0;
      case InvitationStep.eventType:
        return 0.14;
      case InvitationStep.creation:
        return 0.28;
      case InvitationStep.guests:
        return 0.42;
      case InvitationStep.share:
        return 0.57;
      case InvitationStep.package:
        return 0.71;
      case InvitationStep.payment:
        return 0.85;
      case InvitationStep.confirmation:
        return 1.0;
    }
  }

  /// Get step number (1-8)
  int get stepNumber {
    switch (currentStep) {
      case InvitationStep.landing:
        return 1;
      case InvitationStep.eventType:
        return 2;
      case InvitationStep.creation:
        return 3;
      case InvitationStep.guests:
        return 4;
      case InvitationStep.share:
        return 5;
      case InvitationStep.package:
        return 6;
      case InvitationStep.payment:
        return 7;
      case InvitationStep.confirmation:
        return 8;
    }
  }

  /// Guest statistics
  int get totalGuests => guests.length;
  int get confirmedGuests =>
      guests.where((g) => g.status == GuestStatus.confirmed).length;
  int get declinedGuests =>
      guests.where((g) => g.status == GuestStatus.declined).length;
  int get pendingGuests =>
      guests.where((g) => g.status == GuestStatus.pending).length;

  /// Check if selected package is free
  bool get isFreePlanSelected => selectedPackageId == 'basic';

  @override
  List<Object?> get props => [
        currentStep,
        status,
        eventType,
        customEventTypeName,
        names,
        eventDate,
        eventTime,
        location,
        locationAddress,
        selectedTemplateId,
        requestCustomTemplate,
        guests,
        currentGuestInput,
        selectedPackageId,
        shareLink,
        invitationId,
        errorMessage,
      ];
}
