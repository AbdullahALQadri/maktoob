import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/invitation_draft_model.dart';
import '../invitation_state.dart';
import 'wizard_deps.dart';

/// Step 2: the guest list, merged from contacts, Excel and typed names.
mixin WizardGuestsActions on Cubit<InvitationState>, WizardDeps {
  /// Add guests from mobile contacts
  void addContactGuests(List<GuestInfoModel> contactGuests) {
    emit(state.copyWith(
      contactsGuests: contactGuests,
    ));
    mergeGuests();
  }

  /// Adds the people of a saved group (those with a mobile number) and
  /// returns how many are new to the list.
  int addSavedGuests(List<GuestInfoModel> saved) {
    final before = state.guests.length;
    emit(state.copyWith(
      manualGuests: [
        ...state.manualGuests,
        // No digits = no way to send an invitation: left out. Someone already
        // on the list keeps the name the host gave them.
        for (final g in saved)
          if (g.phone.contains(RegExp(r'\d')) && !state.guests.any((have) => have.normalizedPhone == g.normalizedPhone))
            g.copyWith(source: GuestSource.manual),
      ],
    ));
    mergeGuests();
    return state.guests.length - before;
  }

  /// Add a manual guest
  void addManualGuest(GuestInfoModel guest) {
    final newManualGuests = List<GuestInfoModel>.from(state.manualGuests)
      ..add(guest.copyWith(source: GuestSource.manual));

    emit(state.copyWith(manualGuests: newManualGuests));
    mergeGuests();
  }

  /// Remove a guest by index
  void removeGuest(int index) {
    if (index < 0 || index >= state.guests.length) return;

    final guestToRemove = state.guests[index];
    final phone = guestToRemove.normalizedPhone;

    // Remove from appropriate source list
    switch (guestToRemove.source) {
      case GuestSource.contacts:
        final newContacts = List<GuestInfoModel>.from(state.contactsGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(contactsGuests: newContacts));
        break;
      case GuestSource.excel:
        final newExcel = List<GuestInfoModel>.from(state.excelGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(excelGuests: newExcel));
        break;
      case GuestSource.manual:
        final newManual = List<GuestInfoModel>.from(state.manualGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(manualGuests: newManual));
        break;
    }

    mergeGuests();
  }

  /// Clear all guests
  void clearAllGuests() {
    emit(state.copyWith(
      guests: [],
      contactsGuests: [],
      excelGuests: [],
      manualGuests: [],
      duplicatePhoneNumbers: {},
    ));
  }

  /// Merge guests from all sources and remove duplicates
  /// Priority: manual > excel > contacts
  void mergeGuests() {
    final phoneMap = <String, GuestInfoModel>{};
    final duplicates = <String>{};

    // Add manual guests first (highest priority)
    for (final guest in state.manualGuests) {
      final phone = guest.normalizedPhone;
      if (phone.isNotEmpty) {
        phoneMap[phone] = guest;
      }
    }

    // Add excel guests (medium priority)
    for (final guest in state.excelGuests) {
      final phone = guest.normalizedPhone;
      if (phone.isNotEmpty) {
        if (phoneMap.containsKey(phone)) {
          duplicates.add(phone);
        } else {
          phoneMap[phone] = guest;
        }
      }
    }

    // Add contacts guests (lowest priority)
    for (final guest in state.contactsGuests) {
      final phone = guest.normalizedPhone;
      if (phone.isNotEmpty) {
        if (phoneMap.containsKey(phone)) {
          duplicates.add(phone);
        } else {
          phoneMap[phone] = guest;
        }
      }
    }

    emit(state.copyWith(
      guests: phoneMap.values.toList(),
      duplicatePhoneNumbers: duplicates,
    ));
  }

  /// Import guests from Excel file
  Future<void> importGuestsFromExcel(File file) async {
    emit(state.copyWith(isLoadingExcel: true));

    try {
      if (excelParserService != null) {
        final result = await excelParserService!.parseExcelFile(file);
        emit(state.copyWith(
          isLoadingExcel: false,
          excelGuests: result.guests,
        ));
        mergeGuests();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoadingExcel: false,
        errorMessage: 'invitation_excel_read_error',
      ));
    }
  }

  /// Remove a guest by object reference (alias for removeGuestByModel)
  void removeGuestByModel(GuestInfoModel guest) {
    final phone = guest.normalizedPhone;

    switch (guest.source) {
      case GuestSource.contacts:
        final newContacts = List<GuestInfoModel>.from(state.contactsGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(contactsGuests: newContacts));
        break;
      case GuestSource.excel:
        final newExcel = List<GuestInfoModel>.from(state.excelGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(excelGuests: newExcel));
        break;
      case GuestSource.manual:
        final newManual = List<GuestInfoModel>.from(state.manualGuests)
          ..removeWhere((g) => g.normalizedPhone == phone);
        emit(state.copyWith(manualGuests: newManual));
        break;
    }

    mergeGuests();
  }

  /// Clear duplicate notification
  void clearDuplicateNotification() {
    emit(state.copyWith(duplicatePhoneNumbers: {}));
  }
}
