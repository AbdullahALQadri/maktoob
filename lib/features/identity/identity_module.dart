import 'package:get_it/get_it.dart';

import 'data/datasources/identity_remote_data_source.dart';
import 'data/repositories/identity_repository_impl.dart';
import 'domain/repositories/identity_repository.dart';
import 'domain/usecases/get_identity_usecase.dart';
import 'domain/usecases/submit_identity_usecase.dart';
import 'presentation/cubit/identity_cubit.dart';

/// Identity verification (KYC): data source -> repository -> use cases -> cubit.
void registerIdentityModule(GetIt sl) {
  sl
    ..registerLazySingleton<IdentityRemoteDataSource>(() => IdentityRemoteDataSourceImpl(apiConsumer: sl()))
    ..registerLazySingleton<IdentityRepository>(() => IdentityRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()))
    ..registerLazySingleton(() => GetIdentityUseCase(sl()))
    ..registerLazySingleton(() => SubmitIdentityUseCase(sl()))
    ..registerFactory(() => IdentityCubit(getIdentity: sl(), submitIdentity: sl()));
}
