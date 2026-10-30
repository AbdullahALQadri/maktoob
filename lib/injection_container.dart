import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/api/api_consumer.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/auth_interceptor.dart';
import 'core/api/dio_consumer.dart';
import 'core/network/network_info.dart';
import 'core/services/security/device_security_service.dart';
import 'core/utils/storage/secure_storage_service.dart';
import 'core/utils/storage/shared_preferences.dart';

// Authentication Feature
import 'features/authentication/data/datasources/auth_remote_data_source.dart';
import 'features/authentication/data/repositories/auth_repository_impl.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';

// Home Feature
import 'features/explore/data/datasources/explore_remote_data_source.dart';
import 'features/explore/data/repositories/explore_repository_impl.dart';
import 'features/explore/domain/repositories/explore_repository.dart';
import 'features/explore/domain/usecases/get_occasion_groups_usecase.dart';
import 'features/explore/domain/usecases/get_public_templates_usecase.dart';
import 'features/explore/presentation/cubit/explore_cubit.dart';
import 'core/services/pending_wizard_intent_service.dart';
import 'features/events/events_module.dart';
import 'features/home/home_module.dart';

// Events Feature


// Scanner Feature (the offline door)
import 'core/offline/android_hub_service.dart';
import 'core/offline/background_sync.dart';
import 'core/offline/offline_database.dart';
import 'core/offline/pending_actions_queue.dart';
import 'features/scanner/data/datasources/door_remote_data_source.dart';
import 'features/scanner/data/datasources/door_store.dart';
import 'features/scanner/data/door_engine.dart';
import 'features/scanner/data/door_session_manager.dart';
import 'features/scanner/data/repositories/door_admin_repository_impl.dart';
import 'features/scanner/data/repositories/scanner_repository_impl.dart';
import 'features/scanner/domain/repositories/door_admin_repository.dart';
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

// Settings Feature
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/profile_cubit.dart';

// AI Design Studio
import 'features/ai_design/data/repositories/ai_design_repository.dart';

// Push Notifications (FCM)
import 'core/services/fcm_service.dart';

// Invitation Feature (Golden Scenario)
import 'core/api/event_wizard_api_service.dart';
import 'features/invitation/data/services/excel_parser_service.dart';
import 'features/invitation/data/services/invoice_generator.dart';
import 'features/invitation/data/services/whatsapp_service.dart';
import 'features/invitation/presentation/cubit/invitation_cubit.dart';
import 'features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'features/notifications/data/repositories/notifications_repository_impl.dart';
import 'features/notifications/domain/repositories/notifications_repository.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/identity/data/datasources/identity_remote_data_source.dart';
import 'features/identity/data/repositories/identity_repository_impl.dart';
import 'features/identity/domain/repositories/identity_repository.dart';
import 'features/identity/domain/usecases/get_identity_usecase.dart';
import 'features/identity/domain/usecases/submit_identity_usecase.dart';
import 'features/identity/presentation/cubit/identity_cubit.dart';
import 'features/institution/data/datasources/institution_remote_data_source.dart';
import 'features/institution/data/repositories/institution_repository_impl.dart';
import 'features/institution/domain/repositories/institution_repository.dart';
import 'features/institution/presentation/cubit/institution_cubit.dart';

final GetIt sl = GetIt.instance;

/// [pushAvailable] is false when Firebase failed to start (see main.dart).
Future<void> init({bool pushAvailable = true}) async {
  //! ========== External Dependencies ==========
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton<InternetConnection>(InternetConnection.new);

  //! ========== Core ==========
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl()),
  );

  // Secure Storage (encrypted tokens & Hive cache) — must init before Dio
  final secureStorage = SecureStorageService();
  await secureStorage.init();
  sl.registerLazySingleton(() => secureStorage);

  // SharedPref Controller (non-sensitive flags only)
  await SharedPrefController().initPreferences();

  // Dio & API Consumer
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => AppIntercepters());
  sl.registerLazySingleton(() => AuthInterceptor(
        secureStorage: sl(),
        onUnauthenticated: () => sl<AuthCubit>().forceLogout(),
      ));
  sl.registerLazySingleton(() => LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
        error: true,
      ));
  sl.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(client: sl()),
  );

  // Device Security Service (root/jailbreak detection)
  sl.registerLazySingleton(() => DeviceSecurityService());

  //! ========== AUTHENTICATION FEATURE ==========
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiConsumer: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      sharedPrefController: SharedPrefController(),
    ),
  );

  // Cubit — singleton so AuthInterceptor.forceLogout() reaches the same
  // instance the UI is observing (factory would create a throw-away cubit
  // per resolution and silently drop logout signals).
  sl.registerLazySingleton(
    () => AuthCubit(authRepository: sl(), fcmService: sl<FcmService>()),
  );

  //! ========== HOME FEATURE ==========
  registerHomeModule(sl);

  //! ========== NOTIFICATIONS (client in-app inbox) ==========
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(apiConsumer: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerFactory(
    () => NotificationsCubit(getNotifications: sl(), markReadUseCase: sl()),
  );

  //! ========== EXPLORE (browse without account) ==========
  sl.registerLazySingleton<ExploreRemoteDataSource>(
    () => ExploreRemoteDataSourceImpl(apiConsumer: sl()),
  );
  sl.registerLazySingleton<ExploreRepository>(
    () => ExploreRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetOccasionGroupsUseCase(sl()));
  sl.registerLazySingleton(() => GetPublicTemplatesUseCase(sl()));
  // Explore → sign-up → wizard hand-off (in memory, consumed once).
  sl.registerLazySingleton(() => PendingWizardIntentService());
  sl.registerFactory(
    () => ExploreCubit(
      getOccasionGroupsUseCase: sl(),
      getPublicTemplatesUseCase: sl(),
    ),
  );

  //! ========== EVENTS FEATURE ==========
  registerEventsModule(sl);

  //! ========== SCANNER FEATURE (offline door) ==========
  // One SQLite file for door packs, door check-ins and queued writes; the
  // background sync task opens the same file from its own isolate.
  final offlineDb = await OfflineDatabase.shared();
  sl.registerLazySingleton<DoorStore>(() => SqliteDoorStore(offlineDb));

  // Door calls carry the client token, or a paired phone's / scanner
  // account's own token; never the app's AuthInterceptor (no forced logout).
  sl.registerLazySingleton<DoorRemoteDataSource>(
    () => DoorRemoteDataSource(DoorHttp(tokenFor: (s) => DoorSessionManager.tokenFor(secureStorage, s))),
  );
  sl.registerLazySingleton<DoorSessionManager>(
    () => DoorSessionManager(store: sl(), remote: sl(), secure: secureStorage),
  );
  sl.registerLazySingleton<DoorEngine>(
    () => DoorEngine(
      store: sl(),
      remote: sl(),
      connectivity: sl<InternetConnection>()
          .onStatusChange
          .map((s) => s == InternetStatus.connected),
      onQueued: BackgroundSync.scheduleSoon,
      keepAlive: AndroidHubService(),
    ),
  );

  // Writes made offline elsewhere in the app (sent when the connection returns).
  sl.registerLazySingleton<PendingActionsQueue>(
    () => PendingActionsQueue(database: OfflineDatabase.shared, token: secureStorage.getToken)
      ..onQueued = BackgroundSync.scheduleSoon,
  );

  // Repositories
  sl.registerLazySingleton<ScannerRepository>(
    () => ScannerRepositoryImpl(engine: sl()),
  );
  sl.registerLazySingleton<DoorAdminRepository>(
    () => DoorAdminRepositoryImpl(remote: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => ScanQrCodeUseCase(sl()));
  sl.registerLazySingleton(() => CheckInGuestUseCase(sl()));
  sl.registerLazySingleton(() => GetGuestListUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => ScannerCubit(
      repository: sl(),
      scanQrCodeUseCase: sl(),
      checkInGuestUseCase: sl(),
      getGuestListUseCase: sl(),
    ),
  );

  //! ========== INSTITUTION FEATURE ==========
  sl.registerLazySingleton<InstitutionRemoteDataSource>(
    () => InstitutionRemoteDataSourceImpl(apiConsumer: sl()),
  );
  sl.registerLazySingleton<InstitutionRepository>(
    () => InstitutionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => InstitutionCubit(repository: sl()));
  sl.registerFactory(() => InstitutionTeamCubit(repository: sl()));
  sl.registerFactory(() => InstitutionCreditsCubit(repository: sl()));

  //! ========== IDENTITY FEATURE (KYC) ==========
  sl.registerLazySingleton<IdentityRemoteDataSource>(
    () => IdentityRemoteDataSourceImpl(apiConsumer: sl()),
  );
  sl.registerLazySingleton<IdentityRepository>(
    () => IdentityRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetIdentityUseCase(sl()));
  sl.registerLazySingleton(() => SubmitIdentityUseCase(sl()));
  sl.registerFactory(() => IdentityCubit(getIdentity: sl(), submitIdentity: sl()));

  //! ========== PAYMENT FEATURE ==========
  // Data Sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(apiConsumer: sl(), dio: sl()),
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

  //! ========== SETTINGS FEATURE ==========
  // Cubit (no data/domain layer - simple local settings)
  sl.registerFactory(() => SettingsCubit());

  // Profile Cubit
  sl.registerFactory(
    () => ProfileCubit(authRepository: sl()),
  );

  //! ========== PUSH NOTIFICATIONS (FCM) ==========
  // Singleton — initialize() is called from main.dart after Firebase.initializeApp
  sl.registerLazySingleton<FcmService>(
    () => FcmService(available: pushAvailable),
  );

  //! ========== AI DESIGN STUDIO ==========
  sl.registerLazySingleton<AiDesignRepository>(
    () => AiDesignRepository(sl<EventWizardApiService>()),
  );
  // AiDesignCubit is registered per-page (needs eventId + eventTypeId at runtime)
  // — instantiated directly in AppRoutes with GetIt.I<AiDesignRepository>()

  //! ========== INVITATION FEATURE (Golden Scenario) ==========
  // API Service
  sl.registerLazySingleton(
    () => EventWizardApiService(apiConsumer: sl()),
  );

  // Services
  sl.registerLazySingleton(() => ExcelParserService());
  sl.registerLazySingleton(() => WhatsAppService());
  sl.registerLazySingleton(() => InvoiceGenerator());

  // Cubit - manages the entire event creation wizard
  sl.registerFactory(
    () => InvitationCubit(
      apiService: sl(),
      excelParserService: sl(),
      whatsAppService: sl(),
      invoiceGenerator: sl(),
    ),
  );
}
