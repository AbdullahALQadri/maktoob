import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/usecases/add_venue_usecase.dart';
import '../../domain/usecases/get_venues_usecase.dart';
import '../../domain/usecases/search_venues_usecase.dart';
import 'venues_state.dart';

/// Cubit for managing venues state
class VenuesCubit extends Cubit<VenuesState> {
  final GetVenuesUseCase getVenuesUseCase;
  final AddVenueUseCase addVenueUseCase;
  final SearchVenuesUseCase searchVenuesUseCase;

  VenuesCubit({
    required this.getVenuesUseCase,
    required this.addVenueUseCase,
    required this.searchVenuesUseCase,
  }) : super(const VenuesInitial());

  /// Loads all venues
  Future<void> loadVenues() async {
    emit(const VenuesLoading());

    final result = await getVenuesUseCase(const NoParams());

    result.fold(
      (failure) => emit(VenuesError(message: failure.message ?? 'Failed to load venues')),
      (venues) => emit(VenuesLoaded(
        venues: venues,
        filteredVenues: venues,
      )),
    );
  }

  /// Searches venues by query
  void searchVenues(String query) {
    final currentState = state;
    if (currentState is VenuesLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredVenues: currentState.venues,
          searchQuery: '',
        ));
      } else {
        final lowerQuery = query.toLowerCase();
        final filtered = currentState.venues.where((venue) {
          return venue.name.toLowerCase().contains(lowerQuery) ||
              venue.address.toLowerCase().contains(lowerQuery) ||
              venue.email.toLowerCase().contains(lowerQuery);
        }).toList();

        emit(currentState.copyWith(
          filteredVenues: filtered,
          searchQuery: query,
        ));
      }
    }
  }

  /// Toggles the add venue form visibility
  void toggleAddVenueForm() {
    final currentState = state;
    if (currentState is VenuesLoaded) {
      emit(currentState.copyWith(
        showAddForm: !currentState.showAddForm,
        formState: currentState.showAddForm ? const AddVenueFormState() : currentState.formState,
      ));
    }
  }

  /// Updates the add venue form state
  void updateFormField({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? capacity,
  }) {
    final currentState = state;
    if (currentState is VenuesLoaded) {
      emit(currentState.copyWith(
        formState: currentState.formState.copyWith(
          name: name,
          address: address,
          phone: phone,
          email: email,
          capacity: capacity,
        ),
      ));
    }
  }

  /// Clears the add venue form
  void clearForm() {
    final currentState = state;
    if (currentState is VenuesLoaded) {
      emit(currentState.copyWith(
        formState: const AddVenueFormState(),
      ));
    }
  }

  /// Adds a new venue
  Future<void> addVenue({
    required List<Color> gradient,
    required IconData icon,
  }) async {
    final currentState = state;
    if (currentState is VenuesLoaded) {
      final formState = currentState.formState;

      if (!formState.isValid) {
        return;
      }

      emit(VenueAdding(
        venues: currentState.venues,
        filteredVenues: currentState.filteredVenues,
        searchQuery: currentState.searchQuery,
        formState: formState,
      ));

      final params = AddVenueParams(
        name: formState.name,
        address: formState.address,
        phone: formState.phone,
        email: formState.email,
        capacity: int.tryParse(formState.capacity) ?? 0,
        gradient: gradient,
        icon: icon,
      );

      final result = await addVenueUseCase(params);

      result.fold(
        (failure) => emit(VenuesError(message: failure.message ?? 'Failed to add venue')),
        (venue) {
          final updatedVenues = [...currentState.venues, venue];
          final filteredVenues = currentState.searchQuery.isEmpty
              ? updatedVenues
              : _filterVenues(updatedVenues, currentState.searchQuery);

          emit(VenueAdded(
            venue: venue,
            venues: updatedVenues,
            filteredVenues: filteredVenues,
            searchQuery: currentState.searchQuery,
          ));

          // After showing success, return to loaded state
          Future.delayed(const Duration(milliseconds: 100), () {
            emit(VenuesLoaded(
              venues: updatedVenues,
              filteredVenues: filteredVenues,
              searchQuery: currentState.searchQuery,
              showAddForm: false,
              formState: const AddVenueFormState(),
            ));
          });
        },
      );
    }
  }

  /// Helper method to filter venues by query
  List<VenueEntity> _filterVenues(List<VenueEntity> venues, String query) {
    if (query.isEmpty) return venues;
    final lowerQuery = query.toLowerCase();
    return venues.where((venue) {
      return venue.name.toLowerCase().contains(lowerQuery) ||
          venue.address.toLowerCase().contains(lowerQuery) ||
          venue.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
