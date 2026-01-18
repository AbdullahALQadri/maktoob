import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/invitation_draft_model.dart';
import 'invitation_state.dart';

/// Cubit for managing the Golden Scenario invitation flow
class InvitationCubit extends Cubit<InvitationState> {
  InvitationCubit() : super(InvitationState.initial());

  // ============ Navigation ============

  /// Navigate to the next step
  void nextStep() {
    final nextStepMap = {
      InvitationStep.landing: InvitationStep.eventType,
      InvitationStep.eventType: InvitationStep.creation,
      InvitationStep.creation: InvitationStep.guests,
      InvitationStep.guests: InvitationStep.share,
      InvitationStep.share: InvitationStep.package,
      InvitationStep.package: InvitationStep.payment,
      InvitationStep.payment: InvitationStep.confirmation,
      InvitationStep.confirmation: InvitationStep.confirmation,
    };

    final next = nextStepMap[state.currentStep];
    if (next != null) {
      emit(state.copyWith(currentStep: next));
    }
  }

  /// Navigate to the previous step
  void previousStep() {
    final prevStepMap = {
      InvitationStep.landing: InvitationStep.landing,
      InvitationStep.eventType: InvitationStep.landing,
      InvitationStep.creation: InvitationStep.eventType,
      InvitationStep.guests: InvitationStep.creation,
      InvitationStep.share: InvitationStep.guests,
      InvitationStep.package: InvitationStep.share,
      InvitationStep.payment: InvitationStep.package,
      InvitationStep.confirmation: InvitationStep.payment,
    };

    final prev = prevStepMap[state.currentStep];
    if (prev != null) {
      emit(state.copyWith(currentStep: prev));
    }
  }

  /// Go to a specific step
  void goToStep(InvitationStep step) {
    emit(state.copyWith(currentStep: step));
  }

  /// Skip payment (free plan) and go directly to confirmation
  void skipToConfirmation() {
    emit(state.copyWith(currentStep: InvitationStep.confirmation));
  }

  // ============ Event Type ============

  /// Select an event type
  void selectEventType(GoldenEventType type) {
    // Initialize names list based on event type
    final nameCount = type.nameFieldCount;
    final names = List.generate(nameCount, (_) => '');

    emit(state.copyWith(
      eventType: type,
      names: names,
      customEventTypeName: null,
    ));
  }

  /// Set custom event type name
  void setCustomEventTypeName(String name) {
    emit(state.copyWith(customEventTypeName: name));
  }

  // ============ Names ============

  /// Update a name field at given index
  void updateName(int index, String value) {
    if (index < 0 || index >= state.names.length) return;

    final newNames = List<String>.from(state.names);
    newNames[index] = value;
    emit(state.copyWith(names: newNames));
  }

  /// Add another name field (for custom events)
  void addNameField() {
    final newNames = List<String>.from(state.names)..add('');
    emit(state.copyWith(names: newNames));
  }

  /// Remove a name field
  void removeNameField(int index) {
    if (state.names.length <= 1) return;

    final newNames = List<String>.from(state.names)..removeAt(index);
    emit(state.copyWith(names: newNames));
  }

  // ============ Event Details ============

  /// Update event date
  void updateDate(DateTime date) {
    emit(state.copyWith(eventDate: date));
  }

  /// Update event time
  void updateTime(TimeOfDay time) {
    emit(state.copyWith(eventTime: time));
  }

  /// Update location name
  void updateLocation(String location) {
    emit(state.copyWith(location: location));
  }

  /// Update location address
  void updateLocationAddress(String address) {
    emit(state.copyWith(locationAddress: address));
  }

  // ============ Template ============

  /// Select a template
  void selectTemplate(String templateId) {
    emit(state.copyWith(
      selectedTemplateId: templateId,
      requestCustomTemplate: false,
    ));
  }

  /// Toggle custom template request
  void toggleCustomTemplate(bool value) {
    emit(state.copyWith(
      requestCustomTemplate: value,
      selectedTemplateId: value ? null : state.selectedTemplateId,
    ));
  }

  // ============ Guests ============

  /// Update current guest input
  void updateCurrentGuestName(String name) {
    emit(state.copyWith(
      currentGuestInput: state.currentGuestInput.copyWith(name: name),
    ));
  }

  void updateCurrentGuestPhone(String phone) {
    emit(state.copyWith(
      currentGuestInput: state.currentGuestInput.copyWith(phone: phone),
    ));
  }

  void updateCurrentGuestEmail(String email) {
    emit(state.copyWith(
      currentGuestInput: state.currentGuestInput.copyWith(email: email),
    ));
  }

  /// Add current guest to list and reset input
  void addGuest() {
    if (!state.currentGuestInput.isValid) return;

    final newGuests = List<GuestInfoModel>.from(state.guests)
      ..add(state.currentGuestInput);

    emit(state.copyWith(
      guests: newGuests,
      currentGuestInput: const GuestInfoModel(name: ''),
    ));
  }

  /// Add a guest directly
  void addGuestDirect(GuestInfoModel guest) {
    if (!guest.isValid) return;

    final newGuests = List<GuestInfoModel>.from(state.guests)..add(guest);
    emit(state.copyWith(guests: newGuests));
  }

  /// Remove a guest by index
  void removeGuest(int index) {
    if (index < 0 || index >= state.guests.length) return;

    final newGuests = List<GuestInfoModel>.from(state.guests)..removeAt(index);
    emit(state.copyWith(guests: newGuests));
  }

  /// Update guest status
  void updateGuestStatus(int index, GuestStatus status) {
    if (index < 0 || index >= state.guests.length) return;

    final newGuests = List<GuestInfoModel>.from(state.guests);
    newGuests[index] = newGuests[index].copyWith(status: status);
    emit(state.copyWith(guests: newGuests));
  }

  /// Clear all guests
  void clearGuests() {
    emit(state.copyWith(guests: []));
  }

  // ============ Package ============

  /// Select a package
  void selectPackage(String packageId) {
    emit(state.copyWith(selectedPackageId: packageId));
  }

  // ============ Actions ============

  /// Generate shareable link
  Future<void> generateShareLink() async {
    emit(state.copyWith(status: InvitationStatus.loading));

    try {
      // TODO: Call API to generate share link
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock share link for now
      final shareLink =
          'https://maktoob.app/i/${DateTime.now().millisecondsSinceEpoch}';

      emit(state.copyWith(
        status: InvitationStatus.success,
        shareLink: shareLink,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Submit invitation (after payment or free selection)
  Future<void> submitInvitation() async {
    emit(state.copyWith(status: InvitationStatus.loading));

    try {
      // TODO: Call API to submit invitation
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock invitation ID
      final invitationId = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      final shareLink = 'https://maktoob.app/i/$invitationId';

      emit(state.copyWith(
        status: InvitationStatus.success,
        invitationId: invitationId,
        shareLink: shareLink,
        currentStep: InvitationStep.confirmation,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Save draft locally
  Future<void> saveDraft() async {
    emit(state.copyWith(status: InvitationStatus.loading));

    try {
      // TODO: Save to local storage
      await Future.delayed(const Duration(milliseconds: 300));

      emit(state.copyWith(status: InvitationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: InvitationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Reset state
  void reset() {
    emit(InvitationState.initial());
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  // ============ WhatsApp ============

  /// Generate WhatsApp message for payment
  String generateWhatsAppMessage() {
    final eventName = state.names.isNotEmpty ? state.names.first : 'My Event';
    final packageName = state.selectedPackageId ?? 'Unknown';

    return '''
مرحباً! أريد طلب باقة $packageName.

المناسبة: $eventName
عدد الضيوف: ${state.totalGuests}

سأرسل إيصال الدفع قريباً.
''';
  }

  /// Get WhatsApp URL with pre-filled message
  String getWhatsAppUrl(String phoneNumber) {
    final message = Uri.encodeComponent(generateWhatsAppMessage());
    return 'https://wa.me/$phoneNumber?text=$message';
  }
}
