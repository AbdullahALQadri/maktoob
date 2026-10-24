import 'package:equatable/equatable.dart';

import '../../domain/entities/identity_entities.dart';

abstract class IdentityState extends Equatable {
  const IdentityState();

  @override
  List<Object?> get props => [];
}

class IdentityInitial extends IdentityState {
  const IdentityInitial();
}

class IdentityLoading extends IdentityState {
  const IdentityLoading();
}

class IdentityLoaded extends IdentityState {
  final IdentityOverviewEntity overview;
  final bool isSubmitting;

  /// One-shot: a submission was just accepted (the screen refreshes the profile).
  final bool justSubmitted;

  /// One-shot message: a translation key or server text.
  final String? message;
  final bool messageIsError;

  /// Server 422 per field (first message each).
  final Map<String, String> fieldErrors;

  const IdentityLoaded(
    this.overview, {
    this.isSubmitting = false,
    this.justSubmitted = false,
    this.message,
    this.messageIsError = false,
    this.fieldErrors = const {},
  });

  IdentityLoaded copyWith({
    IdentityOverviewEntity? overview,
    bool? isSubmitting,
    bool justSubmitted = false,
    String? message,
    bool messageIsError = false,
    Map<String, String>? fieldErrors,
  }) =>
      IdentityLoaded(
        overview ?? this.overview,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        justSubmitted: justSubmitted,
        message: message,
        messageIsError: messageIsError,
        fieldErrors: fieldErrors ?? this.fieldErrors,
      );

  @override
  List<Object?> get props => [overview, isSubmitting, justSubmitted, message, messageIsError, fieldErrors];
}

class IdentityError extends IdentityState {
  final String message;

  const IdentityError(this.message);

  @override
  List<Object?> get props => [message];
}
