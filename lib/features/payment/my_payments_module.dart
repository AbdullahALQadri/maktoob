import 'package:get_it/get_it.dart';

import 'data/datasources/my_payments_remote_data_source.dart';
import 'data/repositories/my_payments_repository_impl.dart';
import 'domain/repositories/my_payments_repository.dart';
import 'domain/usecases/get_my_payments_usecase.dart';
import 'presentation/cubit/my_payments_cubit.dart';

/// "My payments" (My account → My payments): receipts, what is due and the
/// receipts under review, the same list as the portal.
void registerMyPaymentsModule(GetIt sl) {
  sl.registerLazySingleton<MyPaymentsRemoteDataSource>(() => MyPaymentsRemoteDataSourceImpl(apiConsumer: sl()));
  sl.registerLazySingleton<MyPaymentsRepository>(() => MyPaymentsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetMyPaymentsUseCase(sl()));
  sl.registerFactory(() => MyPaymentsCubit(getMyPayments: sl()));
}
