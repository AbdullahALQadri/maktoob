import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Abstract base class for all use cases in the application.
///
/// Use cases represent a single unit of business logic that can be executed.
/// They follow the Single Responsibility Principle by encapsulating one action.
///
/// [Type] is the return type of the use case.
/// [Params] is the parameter type required by the use case.
///
/// Example usage:
/// ```dart
/// class GetUser extends UseCase<User, GetUserParams> {
///   final UserRepository repository;
///
///   GetUser(this.repository);
///
///   @override
///   Future<Either<Failure, User>> call(GetUserParams params) async {
///     return await repository.getUser(params.userId);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  ///
  /// Returns an [Either] containing:
  /// - [Failure] on the left side if the operation fails
  /// - [Type] on the right side if the operation succeeds
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when a use case does not require any parameters.
///
/// Example usage:
/// ```dart
/// class GetAllUsers extends UseCase<List<User>, NoParams> {
///   @override
///   Future<Either<Failure, List<User>>> call(NoParams params) async {
///     return await repository.getAllUsers();
///   }
/// }
///
/// // Calling the use case
/// final result = await getAllUsers(const NoParams());
/// ```
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Base class for use case parameters that extends Equatable.
///
/// Extend this class to create custom parameter classes for your use cases.
///
/// Example usage:
/// ```dart
/// class GetUserParams extends UseCaseParams {
///   final String userId;
///
///   const GetUserParams({required this.userId});
///
///   @override
///   List<Object?> get props => [userId];
/// }
/// ```
abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}
