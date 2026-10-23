import 'package:equatable/equatable.dart';

import '../../domain/entities/institution_entity.dart';

/// Institution profile + pending invites (`GET /institution`).
abstract class InstitutionState extends Equatable {
  const InstitutionState();

  @override
  List<Object?> get props => [];
}

class InstitutionInitial extends InstitutionState {
  const InstitutionInitial();
}

class InstitutionLoading extends InstitutionState {
  const InstitutionLoading();
}

class InstitutionLoaded extends InstitutionState {
  final InstitutionOverviewEntity overview;

  /// A save / accept / decline is in flight.
  final bool isBusy;

  /// One-shot feedback after an action: a translation key or a server message.
  final String? message;
  final bool messageIsError;

  const InstitutionLoaded(
    this.overview, {
    this.isBusy = false,
    this.message,
    this.messageIsError = false,
  });

  InstitutionLoaded copyWith({
    InstitutionOverviewEntity? overview,
    bool? isBusy,
    String? message,
    bool messageIsError = false,
  }) =>
      InstitutionLoaded(
        overview ?? this.overview,
        isBusy: isBusy ?? this.isBusy,
        message: message,
        messageIsError: messageIsError,
      );

  @override
  List<Object?> get props => [overview, isBusy, message, messageIsError];
}

class InstitutionError extends InstitutionState {
  final String message;

  const InstitutionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Team management (owner only).
abstract class InstitutionTeamState extends Equatable {
  const InstitutionTeamState();

  @override
  List<Object?> get props => [];
}

class InstitutionTeamInitial extends InstitutionTeamState {
  const InstitutionTeamInitial();
}

class InstitutionTeamLoading extends InstitutionTeamState {
  const InstitutionTeamLoading();
}

class InstitutionTeamLoaded extends InstitutionTeamState {
  final List<InstitutionMemberEntity> members;
  final bool isBusy;
  final String? message;
  final bool messageIsError;

  const InstitutionTeamLoaded(
    this.members, {
    this.isBusy = false,
    this.message,
    this.messageIsError = false,
  });

  @override
  List<Object?> get props => [members, isBusy, message, messageIsError];
}

class InstitutionTeamError extends InstitutionTeamState {
  final String message;

  const InstitutionTeamError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Prepaid invitation credits (owner only).
abstract class InstitutionCreditsState extends Equatable {
  const InstitutionCreditsState();

  @override
  List<Object?> get props => [];
}

class InstitutionCreditsInitial extends InstitutionCreditsState {
  const InstitutionCreditsInitial();
}

class InstitutionCreditsLoading extends InstitutionCreditsState {
  const InstitutionCreditsLoading();
}

class InstitutionCreditsLoaded extends InstitutionCreditsState {
  final InstitutionCreditsEntity credits;

  const InstitutionCreditsLoaded(this.credits);

  @override
  List<Object?> get props => [credits];
}

class InstitutionCreditsError extends InstitutionCreditsState {
  final String message;

  const InstitutionCreditsError(this.message);

  @override
  List<Object?> get props => [message];
}
