import 'package:equatable/equatable.dart';
import '../../domain/entities/venue_entity.dart';

/// Base class for all venue states
abstract class VenuesState extends Equatable {
  const VenuesState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the cubit is created
class VenuesInitial extends VenuesState {
  const VenuesInitial();
}

/// State when venues are being loaded
class VenuesLoading extends VenuesState {
  const VenuesLoading();
}

/// State when venues have been successfully loaded
class VenuesLoaded extends VenuesState {
  final List<VenueEntity> venues;
  final List<VenueEntity> filteredVenues;
  final String searchQuery;
  final bool showAddForm;
  final AddVenueFormState formState;

  const VenuesLoaded({
    required this.venues,
    required this.filteredVenues,
    this.searchQuery = '',
    this.showAddForm = false,
    this.formState = const AddVenueFormState(),
  });

  VenuesLoaded copyWith({
    List<VenueEntity>? venues,
    List<VenueEntity>? filteredVenues,
    String? searchQuery,
    bool? showAddForm,
    AddVenueFormState? formState,
  }) {
    return VenuesLoaded(
      venues: venues ?? this.venues,
      filteredVenues: filteredVenues ?? this.filteredVenues,
      searchQuery: searchQuery ?? this.searchQuery,
      showAddForm: showAddForm ?? this.showAddForm,
      formState: formState ?? this.formState,
    );
  }

  @override
  List<Object?> get props => [
        venues,
        filteredVenues,
        searchQuery,
        showAddForm,
        formState,
      ];
}

/// State when there is an error loading venues
class VenuesError extends VenuesState {
  final String message;

  const VenuesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a venue is being added
class VenueAdding extends VenuesState {
  final List<VenueEntity> venues;
  final List<VenueEntity> filteredVenues;
  final String searchQuery;
  final AddVenueFormState formState;

  const VenueAdding({
    required this.venues,
    required this.filteredVenues,
    this.searchQuery = '',
    required this.formState,
  });

  @override
  List<Object?> get props => [venues, filteredVenues, searchQuery, formState];
}

/// State when a venue has been successfully added
class VenueAdded extends VenuesState {
  final VenueEntity venue;
  final List<VenueEntity> venues;
  final List<VenueEntity> filteredVenues;
  final String searchQuery;

  const VenueAdded({
    required this.venue,
    required this.venues,
    required this.filteredVenues,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [venue, venues, filteredVenues, searchQuery];
}

/// Form state for adding a new venue
class AddVenueFormState extends Equatable {
  final String name;
  final String address;
  final String phone;
  final String email;
  final String capacity;
  final bool isValid;

  const AddVenueFormState({
    this.name = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.capacity = '',
    this.isValid = false,
  });

  AddVenueFormState copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? capacity,
    bool? isValid,
  }) {
    final newName = name ?? this.name;
    final newAddress = address ?? this.address;
    final newPhone = phone ?? this.phone;
    final newEmail = email ?? this.email;
    final newCapacity = capacity ?? this.capacity;

    return AddVenueFormState(
      name: newName,
      address: newAddress,
      phone: newPhone,
      email: newEmail,
      capacity: newCapacity,
      isValid: newName.isNotEmpty &&
          newAddress.isNotEmpty &&
          newPhone.isNotEmpty &&
          newEmail.isNotEmpty &&
          newCapacity.isNotEmpty,
    );
  }

  AddVenueFormState clear() {
    return const AddVenueFormState();
  }

  @override
  List<Object?> get props => [name, address, phone, email, capacity, isValid];
}
