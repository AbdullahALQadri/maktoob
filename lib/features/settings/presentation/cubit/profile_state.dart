import 'package:equatable/equatable.dart';

import '../../../authentication/domain/entities/user_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;

  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  final UserEntity user;

  const ProfileUpdating({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final UserEntity user;
  final String message;

  const ProfileUpdated({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class UserTypeChangeRequested extends ProfileState {
  final UserEntity user;

  const UserTypeChangeRequested({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserTypeChanged extends ProfileState {
  final UserEntity user;
  final String message;

  const UserTypeChanged({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class ProfileError extends ProfileState {
  final String message;
  final UserEntity? user;

  const ProfileError({required this.message, this.user});

  @override
  List<Object?> get props => [message, user];
}
