import 'package:get_it/get_it.dart';

import 'data/datasources/staff_http.dart';
import 'data/datasources/staff_token_store.dart';
import 'data/repositories/staff_repository_impl.dart';
import 'data/repositories/staff_reviews_repository_impl.dart';
import 'domain/repositories/staff_repository.dart';
import 'domain/repositories/staff_reviews_repository.dart';
import 'domain/usecases/staff_review_usecases.dart';
import 'domain/usecases/staff_usecases.dart';
import 'presentation/cubit/staff_session_cubit.dart';

/// The staff mode (the Maktoob team): its own sign-in and HTTP client, then
/// repository -> use cases -> cubits.
void registerStaffModule(GetIt sl) {
  sl
    ..registerLazySingleton<StaffTokenStore>(() => const SecureStaffTokenStore())
    ..registerLazySingleton(() => StaffHttp(tokens: sl()))
    ..registerLazySingleton<StaffRepository>(() => StaffRepositoryImpl(http: sl()))
    ..registerLazySingleton(() => SignInStaffUseCase(sl()))
    ..registerLazySingleton(() => RestoreStaffUseCase(sl()))
    ..registerLazySingleton(() => SignOutStaffUseCase(sl()))
    ..registerLazySingleton(() => GetStaffTodayUseCase(sl()))
    ..registerLazySingleton(() => GetStaffPaymentRequestsUseCase(sl()))
    ..registerLazySingleton(() => GetStaffPaymentRequestUseCase(sl()))
    ..registerLazySingleton(() => ReviewStaffPaymentRequestUseCase(sl()))
    ..registerLazySingleton(() => GetStaffClientsUseCase(sl()))
    ..registerLazySingleton(() => GetStaffEventsUseCase(sl()))
    ..registerLazySingleton<StaffReviewsRepository>(() => StaffReviewsRepositoryImpl(http: sl()))
    ..registerLazySingleton(() => GetStaffIdentitiesUseCase(sl()))
    ..registerLazySingleton(() => GetStaffIdentityUseCase(sl()))
    ..registerLazySingleton(() => ReviewStaffIdentityUseCase(sl()))
    ..registerLazySingleton(() => GetStaffInstitutionsUseCase(sl()))
    ..registerLazySingleton(() => GetStaffInstitutionUseCase(sl()))
    ..registerLazySingleton(() => ReviewStaffInstitutionUseCase(sl()))
    ..registerLazySingleton(() => OpenStaffFileUseCase(sl()))
    ..registerFactory(() => StaffSessionCubit(signIn: sl(), restore: sl(), signOut: sl()));
}
