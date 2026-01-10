import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/network_info.dart';

// Home Feature
import 'features/home/data/datasources/home_local_data_source.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_recent_events_usecase.dart';
import 'features/home/domain/usecases/get_stats_usecase.dart';
import 'features/home/presentation/cubit/home_cubit.dart';

// Events Feature
import 'features/events/data/datasources/events_local_data_source.dart';
import 'features/events/data/datasources/events_remote_data_source.dart';
import 'features/events/data/repositories/events_repository_impl.dart';
import 'features/events/domain/repositories/events_repository.dart';
import 'features/events/domain/usecases/create_event_usecase.dart';
import 'features/events/domain/usecases/filter_events_usecase.dart';
import 'features/events/domain/usecases/get_event_details_usecase.dart';
import 'features/events/domain/usecases/get_events_usecase.dart';
import 'features/events/presentation/cubit/events_list/events_list_cubit.dart';
import 'features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'features/events/presentation/cubit/create_event/create_event_cubit.dart';

// Venues Feature
import 'features/venues/data/datasources/venues_local_data_source.dart';
import 'features/venues/data/datasources/venues_remote_data_source.dart';
import 'features/venues/data/repositories/venues_repository_impl.dart';
import 'features/venues/domain/repositories/venues_repository.dart';
import 'features/venues/domain/usecases/add_venue_usecase.dart';
import 'features/venues/domain/usecases/get_venues_usecase.dart';
import 'features/venues/domain/usecases/search_venues_usecase.dart';
import 'features/venues/presentation/cubit/venues_cubit.dart';

// Scanner Feature
import 'features/scanner/data/datasources/scanner_remote_data_source.dart';
import 'features/scanner/data/repositories/scanner_repository_impl.dart';
import 'features/scanner/domain/repositories/scanner_repository.dart';
import 'features/scanner/domain/usecases/check_in_guest_usecase.dart';
import 'features/scanner/domain/usecases/get_guest_list_usecase.dart';
import 'features/scanner/domain/usecases/scan_qr_code_usecase.dart';
import 'features/scanner/presentation/cubit/scanner_cubit.dart';

// Payment Feature
import 'features/payment/data/datasources/payment_remote_data_source.dart';
import 'features/payment/data/repositories/payment_repository_impl.dart';
import 'features/payment/domain/repositories/payment_repository.dart';
import 'features/payment/domain/usecases/get_bank_details_usecase.dart';
import 'features/payment/domain/usecases/upload_invoice_usecase.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  //! ========== External Dependencies ==========
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.instance,
  );

  //! ========== Core ==========
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl()),
  );

  //! ========== HOME FEATURE ==========
  // Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentEventsUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => HomeCubit(
      getStatsUseCase: sl(),
      getRecentEventsUseCase: sl(),
    ),
  );

  //! ========== EVENTS FEATURE ==========
  // Data Sources
  sl.registerLazySingleton<EventsRemoteDataSource>(
    () => EventsRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<EventsLocalDataSource>(
    () => EventsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetEventsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventDetailsUseCase(sl()));
  sl.registerLazySingleton(() => CreateEventUseCase(sl()));
  sl.registerLazySingleton(() => FilterEventsUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => EventsListCubit(
      getEventsUseCase: sl(),
      filterEventsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => EventDetailsCubit(
      getEventDetailsUseCase: sl(),
      eventsRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => CreateEventCubit(
      createEventUseCase: sl(),
    ),
  );

  //! ========== VENUES FEATURE ==========
  // Data Sources
  sl.registerLazySingleton<VenuesRemoteDataSource>(
    () => VenuesRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<VenuesLocalDataSource>(
    () => VenuesLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<VenuesRepository>(
    () => VenuesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetVenuesUseCase(sl()));
  sl.registerLazySingleton(() => AddVenueUseCase(sl()));
  sl.registerLazySingleton(() => SearchVenuesUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => VenuesCubit(
      getVenuesUseCase: sl(),
      addVenueUseCase: sl(),
      searchVenuesUseCase: sl(),
    ),
  );

  //! ========== SCANNER FEATURE ==========
  // Data Sources
  sl.registerLazySingleton<ScannerRemoteDataSource>(
    () => ScannerRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<ScannerRepository>(
    () => ScannerRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => ScanQrCodeUseCase(sl()));
  sl.registerLazySingleton(() => CheckInGuestUseCase(sl()));
  sl.registerLazySingleton(() => GetGuestListUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => ScannerCubit(
      scanQrCodeUseCase: sl(),
      checkInGuestUseCase: sl(),
      getGuestListUseCase: sl(),
    ),
  );

  //! ========== PAYMENT FEATURE ==========
  // Data Sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => UploadInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => GetBankDetailsUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => PaymentCubit(
      uploadInvoiceUseCase: sl(),
      getBankDetailsUseCase: sl(),
    ),
  );
}
