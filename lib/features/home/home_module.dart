import 'package:get_it/get_it.dart';

import 'data/datasources/home_remote_data_source.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/get_home_usecase.dart';
import 'presentation/cubit/home_cubit.dart';

/// Registers the home feature: data source → repository → use case → cubit.
void registerHomeModule(GetIt sl) {
  sl
    ..registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(apiConsumer: sl()))
    ..registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: sl()))
    ..registerLazySingleton(() => GetHomeUseCase(sl()))
    ..registerFactory(() => HomeCubit(getHome: sl()));
}
