import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/event_models.dart' hide CustomVenue, EventDetails, GuestInfo;
import '../../../domain/entities/guest_entity.dart';
import '../../../domain/usecases/create_event_usecase.dart';
import 'create_event_state.dart';

class CreateEventCubit extends Cubit<CreateEventState> {
  final CreateEventUseCase createEventUseCase;
  final int Function(String packageId)? getPackageLimit;

  CreateEventCubit({
    required this.createEventUseCase,
    this.getPackageLimit,
  }) : super(const CreateEventState());

  // Navigation
  void nextStep() {
    if (!state.canProceed) return;
    if (state.isLastStep) return;

    final nextIndex = state.currentStep.index + 1;
    emit(state.copyWith(currentStep: CreateEventStep.values[nextIndex]));
  }

  void previousStep() {
    if (state.isFirstStep) return;

    final prevIndex = state.currentStep.index - 1;
    emit(state.copyWith(currentStep: CreateEventStep.values[prevIndex]));
  }

  void goToStep(CreateEventStep step) {
    emit(state.copyWith(currentStep: step));
  }

  // Step 1: Package (toggle selection)
  void selectPackage(String packageId) {
    if (state.selectedPackageId == packageId) {
      emit(state.copyWith(clearPackage: true));
    } else {
      emit(state.copyWith(selectedPackageId: packageId));
    }
  }

  // Step 2: Venue (toggle selection)
  void selectVenue(String venueId) {
    if (state.selectedVenueId == venueId) {
      emit(state.copyWith(clearVenue: true));
    } else {
      emit(state.copyWith(
        selectedVenueId: venueId,
        showCustomVenue: false,
      ));
    }
  }

  void toggleCustomVenue() {
    emit(state.copyWith(
      showCustomVenue: !state.showCustomVenue,
      clearVenue: true,
    ));
  }

  void updateCustomVenue(CustomVenue venue) {
    emit(state.copyWith(customVenue: venue));
  }

  void updateCustomVenueName(String name) {
    emit(state.copyWith(
      customVenue: state.customVenue.copyWith(name: name),
    ));
  }

  void updateCustomVenueAddress(String address) {
    emit(state.copyWith(
      customVenue: state.customVenue.copyWith(address: address),
    ));
  }

  void updateCustomVenueCapacity(String capacity) {
    emit(state.copyWith(
      customVenue: state.customVenue.copyWith(capacity: capacity),
    ));
  }

  // Step 3: Event Type (toggle selection)
  void selectEventType(String eventTypeId) {
    if (state.selectedEventTypeId == eventTypeId) {
      emit(state.copyWith(clearEventType: true));
    } else {
      emit(state.copyWith(
        selectedEventTypeId: eventTypeId,
        showCustomEventType: false,
      ));
    }
  }

  void toggleCustomEventType() {
    emit(state.copyWith(
      showCustomEventType: !state.showCustomEventType,
      clearEventType: true,
    ));
  }

  void updateCustomEventType(String eventType) {
    emit(state.copyWith(customEventType: eventType));
  }

  // Step 4: Template (toggle selection)
  void selectTemplate(String templateId) {
    if (state.selectedTemplateId == templateId) {
      emit(state.copyWith(clearTemplate: true));
    } else {
      emit(state.copyWith(
        selectedTemplateId: templateId,
        requestCustomTemplate: false,
      ));
    }
  }

  void toggleCustomTemplate() {
    emit(state.copyWith(
      requestCustomTemplate: !state.requestCustomTemplate,
      clearTemplate: true,
    ));
  }

  // Step 5: Event Details
  void updateEventDetails(EventDetails details) {
    emit(state.copyWith(eventDetails: details));
  }

  void updateEventName(String name) {
    emit(state.copyWith(
      eventDetails: state.eventDetails.copyWith(name: name),
    ));
  }

  void updateEventDate(DateTime date) {
    emit(state.copyWith(
      eventDetails: state.eventDetails.copyWith(date: date),
    ));
  }

  void updateEventTime(DateTime time) {
    emit(state.copyWith(
      eventDetails: state.eventDetails.copyWith(time: time),
    ));
  }

  void updateResponseDeadline(DateTime? deadline) {
    if (deadline == null) {
      emit(state.copyWith(
        eventDetails: state.eventDetails.copyWith(clearDeadline: true),
      ));
    } else {
      emit(state.copyWith(
        eventDetails: state.eventDetails.copyWith(responseDeadline: deadline),
      ));
    }
  }

  void updateMaxCompanions(int maxCompanions) {
    emit(state.copyWith(
      eventDetails: state.eventDetails.copyWith(maxCompanions: maxCompanions),
    ));
  }

  void updateAllowCompanions(bool allow) {
    emit(state.copyWith(
      eventDetails: state.eventDetails.copyWith(allowCompanions: allow),
    ));
  }

  // Step 6: Guests
  void selectGuestMethod(GuestMethod method) {
    emit(state.copyWith(guestMethod: method));
  }

  void updateCurrentGuest(GuestInfo guest) {
    emit(state.copyWith(currentGuest: guest));
  }

  void updateCurrentGuestName(String name) {
    emit(state.copyWith(
      currentGuest: state.currentGuest.copyWith(name: name),
    ));
  }

  void updateCurrentGuestEmail(String email) {
    emit(state.copyWith(
      currentGuest: state.currentGuest.copyWith(email: email),
    ));
  }

  void updateCurrentGuestPhone(String phone) {
    emit(state.copyWith(
      currentGuest: state.currentGuest.copyWith(phone: phone),
    ));
  }

  bool addGuest() {
    final packageLimit = getPackageLimit?.call(state.selectedPackageId ?? '') ?? -1;
    final currentGuestCount = state.manualGuests.length;

    if (packageLimit != -1 && currentGuestCount >= packageLimit) {
      emit(state.copyWith(
        errorMessage: 'You have reached your package limit of $packageLimit guests!',
      ));
      return false;
    }

    if (!state.currentGuest.isValid) {
      emit(state.copyWith(
        errorMessage: 'Please fill in all guest fields',
      ));
      return false;
    }

    final updatedGuests = [...state.manualGuests, state.currentGuest];
    emit(state.copyWith(
      manualGuests: updatedGuests,
      currentGuest: const GuestInfo(),
      errorMessage: null,
    ));
    return true;
  }

  void removeGuest(int index) {
    if (index < 0 || index >= state.manualGuests.length) return;

    final updatedGuests = [...state.manualGuests];
    updatedGuests.removeAt(index);
    emit(state.copyWith(manualGuests: updatedGuests));
  }

  void setExcelFile(File? file) {
    if (file == null) {
      emit(state.copyWith(clearExcelFile: true));
    } else {
      emit(state.copyWith(excelFile: file));
    }
  }

  // Submit
  Future<void> saveDraft() async {
    emit(state.copyWith(status: CreateEventStatus.loading));

    // In a real implementation, this would save to local storage or API
    await Future.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(
      status: CreateEventStatus.success,
      createdEventId: 'draft-${DateTime.now().millisecondsSinceEpoch}',
    ));
  }

  Future<void> submitEvent() async {
    emit(state.copyWith(status: CreateEventStatus.loading));

    // Convert guests to entities
    final guests = state.manualGuests.asMap().entries.map((entry) {
      return entry.value.toEntity('guest-${entry.key}');
    }).toList();

    // Combine date and time
    final eventDate = state.eventDetails.date ?? DateTime.now();
    final eventTime = state.eventDetails.time ?? DateTime.now();
    final combinedDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      eventTime.hour,
      eventTime.minute,
    );

    final params = CreateEventUseCaseParams(
      name: state.eventDetails.name,
      type: state.selectedEventTypeId ?? state.customEventType,
      eventTypeId: int.tryParse(state.selectedEventTypeId ?? ''),
      eventDate: combinedDateTime,
      venue: state.selectedVenueId ?? state.customVenue.name,
      venueId: int.tryParse(state.selectedVenueId ?? ''),
      venueAddress: state.showCustomVenue ? state.customVenue.address : null,
      packageId: int.tryParse(state.selectedPackageId ?? ''),
      templateId: int.tryParse(state.selectedTemplateId ?? ''),
      maxCompanions: state.eventDetails.maxCompanions,
      allowCompanions: state.eventDetails.allowCompanions,
      rsvpDeadline: state.eventDetails.responseDeadline,
      guests: guests,
    );

    final result = await createEventUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: CreateEventStatus.failure,
        errorMessage: failure.message,
      )),
      (event) => emit(state.copyWith(
        status: CreateEventStatus.success,
        createdEventId: event.id,
      )),
    );
  }

  // Reset
  void reset() {
    emit(const CreateEventState());
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
