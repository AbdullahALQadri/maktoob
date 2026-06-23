import 'package:equatable/equatable.dart';

import '../../data/scanner_assignment.dart';

class ScannerAuthState extends Equatable {
  final bool isLoading;
  final bool isAuthenticated;
  final List<ScannerAssignment> assignments;
  final String? errorMessage;

  const ScannerAuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.assignments = const [],
    this.errorMessage,
  });

  ScannerAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    List<ScannerAssignment>? assignments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScannerAuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      assignments: assignments ?? this.assignments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isAuthenticated, assignments, errorMessage];
}
