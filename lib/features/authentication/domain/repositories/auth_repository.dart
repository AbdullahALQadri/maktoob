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

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get stored token
  String? getToken();
}
