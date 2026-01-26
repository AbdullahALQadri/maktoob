import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/storage/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPrefController sharedPrefController;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPrefController,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String login,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.clientLogin(login, password);

      if (response.success && response.token != null) {
        // Save token
        await sharedPrefController.save(token: response.token!);

        // Parse user from response data
        final user = _parseUserFromResponse(response);
        return Right(user);
      } else {
        return Left(AuthenticationFailure(message: response.message));
      }
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(message: e.message ?? 'Invalid credentials'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } on NoInternetConnectionException {
      return const Left(NetworkFailure(message: 'No internet connection'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    String? location,
  }) async {
    try {
      final response = await remoteDataSource.clientRegister(
        name: name,
        email: email,
        phone: phone,
        password: password,
        userType: userType,
        location: location,
      );

      if (response.success) {
        // If token is returned, save it (auto-login after register)
        if (response.token != null) {
          await sharedPrefController.save(token: response.token!);
        }

        final user = _parseUserFromResponse(response);
        return Right(user);
      } else {
        return Left(ValidationFailure(message: response.message));
      }
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message ?? 'Validation error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } on NoInternetConnectionException {
      return const Left(NetworkFailure(message: 'No internet connection'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final clientModel = await remoteDataSource.getClientProfile();
      final user = UserEntity(
        id: clientModel.id,
        name: clientModel.name,
        email: clientModel.email ?? '',
        phone: clientModel.phone,
        avatar: clientModel.avatar,
        companyName: clientModel.companyName,
        isVerified: clientModel.isVerified,
        locale: clientModel.locale,
      );
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(message: e.message ?? 'Session expired'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Server error'));
    } on NoInternetConnectionException {
      return const Left(NetworkFailure(message: 'No internet connection'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.clientLogout();
      await sharedPrefController.clear();
      return const Right(null);
    } catch (e) {
      // Even if API fails, clear local data
      await sharedPrefController.clear();
      return const Right(null);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return sharedPrefController.loggedIn && sharedPrefController.token.isNotEmpty;
  }

  @override
  String? getToken() {
    final token = sharedPrefController.token;
    return token.isNotEmpty ? token : null;
  }

  /// Parse user entity from auth response
  UserEntity _parseUserFromResponse(AuthResponseModel response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final client = data['client'] ?? data['user'] ?? data;
      return UserEntity(
        id: client['id'] ?? 0,
        name: client['name'] ?? '',
        email: client['email'] ?? '',
        phone: client['phone'],
        avatar: client['avatar'],
        companyName: client['company_name'],
        isVerified: client['is_verified'] ?? false,
        locale: client['locale'],
      );
    }

    // Return default user if parsing fails
    return const UserEntity(
      id: 0,
      name: 'User',
      email: '',
    );
  }
}
