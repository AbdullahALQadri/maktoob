import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Login with email/phone and password
  Future<Either<Failure, UserEntity>> login({
    required String login,
    required String password,
  });

  /// Register a new user
  /// Normal user: name, phone, password
  /// Institution: name, email, phone, governorate, location, password
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    String? governorate,
    String? location,
  });

  /// Get current user profile
  Future<Either<Failure, UserEntity>> getProfile();

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Verify OTP code
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String login,
    required String otp,
  });

  /// Send forgot password request (triggers OTP)
  Future<Either<Failure, void>> forgotPassword({required String login});

  /// Resend OTP code
  Future<Either<Failure, void>> resendOtp({
    required String login,
    String? purpose,
  });

  /// Reset password with OTP code
  Future<Either<Failure, void>> resetPassword({
    required String login,
    required String code,
    required String newPassword,
  });

  /// Change password (authenticated)
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? companyName,
  });

  /// Update FCM token for push notifications
  Future<Either<Failure, void>> updateFcmToken(String fcmToken);

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}
