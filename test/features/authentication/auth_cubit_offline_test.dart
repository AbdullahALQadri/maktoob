import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/authentication/domain/entities/user_entity.dart';
import 'package:maktoob/features/authentication/domain/repositories/auth_repository.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_state.dart';

class _Repo implements AuthRepository {
  _Repo(this.profile);
  final Either<Failure, UserEntity> profile;

  @override
  Future<bool> isLoggedIn() async => true;

  @override
  Future<Either<Failure, UserEntity>> getProfile() async => profile;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('network failure on cold start keeps the user signed in', () async {
    final cubit = AuthCubit(
      authRepository: _Repo(const Left(NetworkFailure(message: 'offline'))),
    );
    await cubit.checkAuthStatus();
    expect(cubit.state, isA<AuthAuthenticated>());
    await cubit.close();
  });

  test('server error on cold start keeps the user signed in', () async {
    final cubit = AuthCubit(
      authRepository: _Repo(const Left(ServerFailure(message: '500'))),
    );
    await cubit.checkAuthStatus();
    expect(cubit.state, isA<AuthAuthenticated>());
    await cubit.close();
  });

  test('authentication failure logs the user out', () async {
    final cubit = AuthCubit(
      authRepository: _Repo(const Left(AuthenticationFailure(message: '401'))),
    );
    await cubit.checkAuthStatus();
    expect(cubit.state, isA<AuthUnauthenticated>());
    await cubit.close();
  });
}
