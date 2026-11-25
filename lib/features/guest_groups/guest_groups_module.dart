import 'package:get_it/get_it.dart';

import 'data/datasources/guest_groups_remote_data_source.dart';
import 'data/repositories/guest_groups_repository_impl.dart';
import 'domain/repositories/guest_groups_repository.dart';
import 'domain/usecases/guest_group_usecases.dart';
import 'presentation/cubit/guest_groups_cubit.dart';

/// "Guest groups" (My account): data source -> repository -> use cases -> cubit.
void registerGuestGroupsModule(GetIt sl) {
  sl
    ..registerLazySingleton<GuestGroupsRemoteDataSource>(() => GuestGroupsRemoteDataSourceImpl(apiConsumer: sl()))
    ..registerLazySingleton<GuestGroupsRepository>(
      () => GuestGroupsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl(), pendingActions: sl()),
    )
    ..registerLazySingleton(() => GetGuestGroupsUseCase(sl()))
    ..registerLazySingleton(() => GetGuestGroupUseCase(sl()))
    ..registerLazySingleton(() => CreateGuestGroupUseCase(sl()))
    ..registerLazySingleton(() => ChangeGuestGroupUseCase(sl()))
    ..registerLazySingleton(() => DeleteGuestGroupUseCase(sl()))
    ..registerFactory(() => GuestGroupsCubit(getGroups: sl(), createGroup: sl()));
}
