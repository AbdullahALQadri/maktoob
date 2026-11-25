import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/location_model.dart';
import '../invitation_state.dart';

/// Step 1: what the host types and picks, before it is saved.
mixin WizardDetailsEdits on Cubit<InvitationState> {
  /// Update event name
  void updateEventName(String name) {
    emit(state.copyWith(eventName: name));
  }

  /// Update event date
  void updateDate(DateTime date) {
    emit(state.copyWith(eventDate: date));
  }

  /// Update event time
  void updateTime(TimeOfDay time) {
    emit(state.copyWith(eventTime: time));
  }

  /// Several days (business types): the last day, or null for one day.
  void updateEndDate(DateTime? day) =>
      emit(day == null ? state.copyWith(clearEventEndDate: true) : state.copyWith(eventEndDate: day));

  /// Update event end time (optional).
  void updateEndTime(TimeOfDay time) {
    emit(state.copyWith(eventEndTime: time));
  }

  /// Set custom location from Google Maps
  void setCustomLocation(LocationModel location) {
    emit(state.copyWith(
      customLocation: location,
      clearSelectedVenue: true,
    ));
  }

  /// Update partner with guests count
  void updateRsvpDeadline(DateTime? date) {
    emit(date == null
        ? state.copyWith(clearRsvpDeadline: true)
        : state.copyWith(rsvpDeadline: date));
  }

  void updateInvitationMessage(String message) {
    emit(state.copyWith(invitationMessage: message));
  }

  void updatePartnerWithGuests(int? count) {
    if (count == null) {
      emit(state.copyWith(clearPartnerWithGuests: true));
    } else {
      emit(state.copyWith(partnerWithGuests: count));
    }
  }

  /// Set event type form fields from API
  void setEventTypeFormFields(List<EventTypeFormField> fields) {
    emit(state.copyWith(eventTypeFormFields: fields));
  }

  /// Update event type form field value
  void updateEventTypeFormField(String key, dynamic value) {
    final newFormData = Map<String, dynamic>.from(state.eventTypeFormData);
    newFormData[key] = value;
    emit(state.copyWith(eventTypeFormData: newFormData));
  }
}
