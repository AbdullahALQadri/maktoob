import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication/domain/entities/user_entity.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  UserEntity? _currentUser;

  /// Load user profile - using mock data for testing
  Future<void> loadProfile() async {
    emit(ProfileLoading());

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock user data for testing the design
    final user = UserEntity(
      id: 1,
      name: 'محمد أحمد',
      email: 'mohammed.ahmed@example.com',
      phone: '+966 50 123 4567',
      avatar: null,
      companyName: 'شركة التقنية المتقدمة',
      isVerified: true,
      locale: 'ar',
      userType: UserType.user,
    );
    _currentUser = user;
    emit(ProfileLoaded(user: user));
  }

  /// Update user profile - mock implementation
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? companyName,
  }) async {
    if (_currentUser == null) return;

    emit(ProfileUpdating(user: _currentUser!));

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final updatedUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      phone: phone ?? _currentUser!.phone,
      companyName: companyName ?? _currentUser!.companyName,
    );
    _currentUser = updatedUser;
    emit(ProfileUpdated(
      user: updatedUser,
      message: 'Profile updated successfully',
    ));
  }

  /// Request to change user type - mock implementation
  Future<void> changeUserType(UserType newType, {String? reason}) async {
    if (_currentUser == null) return;

    emit(ProfileUpdating(user: _currentUser!));

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Log the reason for conversion (can be sent to API in production)
    if (reason != null && reason.isNotEmpty) {
      // ignore: avoid_print
      print('Conversion reason: $reason');
    }

    final updatedUser = _currentUser!.copyWith(
      userType: newType,
      companyName: newType == UserType.institution
          ? _currentUser!.companyName ?? 'شركة التقنية المتقدمة'
          : _currentUser!.companyName,
    );
    _currentUser = updatedUser;
    emit(UserTypeChanged(
      user: updatedUser,
      message: 'User type changed successfully',
    ));
  }

  /// Reset to loaded state with current user
  void resetToLoaded() {
    if (_currentUser != null) {
      emit(ProfileLoaded(user: _currentUser!));
    }
  }
}
