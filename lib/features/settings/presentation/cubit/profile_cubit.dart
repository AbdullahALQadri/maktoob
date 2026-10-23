import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository authRepository;

  ProfileCubit({required this.authRepository}) : super(ProfileInitial());

  UserEntity? _currentUser;

  /// Load user profile from API
  Future<void> loadProfile() async {
    emit(ProfileLoading());

    final result = await authRepository.getProfile();

    result.fold(
      (failure) => emit(ProfileError(
          message: failure.message ?? 'Failed to load profile')),
      (user) {
        _currentUser = user;
        emit(ProfileLoaded(user: user));
      },
    );
  }

  /// Update user profile via API
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? companyName,
  }) async {
    if (_currentUser == null) return;

    emit(ProfileUpdating(user: _currentUser!));

    final result = await authRepository.updateProfile(
      name: name,
      email: email,
      phone: phone,
      companyName: companyName,
    );

    result.fold(
      (failure) => emit(ProfileError(
        message: failure.message ?? 'Failed to update profile',
        user: _currentUser,
      )),
      (user) {
        _currentUser = user;
        emit(ProfileUpdated(
          user: user,
          message: 'Profile updated successfully',
        ));
      },
    );
  }

  /// Upload [filePath] as the profile photo.
  Future<void> uploadAvatar(String filePath) =>
      _changeAvatar(() => authRepository.uploadAvatar(filePath));

  /// Remove the profile photo.
  Future<void> removeAvatar() => _changeAvatar(authRepository.removeAvatar);

  Future<void> _changeAvatar(
      Future<Either<Failure, UserEntity>> Function() call) async {
    if (_currentUser == null) return;

    emit(ProfileUpdating(user: _currentUser!));

    final result = await call();

    result.fold(
      (failure) => emit(ProfileError(
        message: failure.message ?? 'Failed to update photo',
        user: _currentUser,
      )),
      (user) {
        _currentUser = user;
        emit(ProfileAvatarChanged(user: user));
      },
    );
  }

  /// Reset to loaded state with current user
  void resetToLoaded() {
    if (_currentUser != null) {
      emit(ProfileLoaded(user: _currentUser!));
    }
  }
}
