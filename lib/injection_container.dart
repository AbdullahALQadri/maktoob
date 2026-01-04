// import 'package:dio/dio.dart';
// // ✅ Notification Feature Imports
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get_it/get_it.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'core/api/api_consumer.dart';
// import 'core/api/app_interceptors.dart';
// import 'core/api/dio_consumer.dart';
// import 'core/network/network_info.dart';
// import 'features/bot_chat/data/datasources/local_bot_chat_data_source.dart';
// import 'features/bot_chat/data/repositories/bot_chat_repository_impl.dart';
// import 'features/bot_chat/domain/repositories/bot_chat_repository.dart';
// import 'features/bot_chat/domain/usecases/send_predefined_message.dart';
// import 'features/bot_chat/presentation/cubit/bot_chat_cubit.dart';
// import 'features/chat/data/datasources/local_chat_data_source.dart';
// import 'features/chat/data/repositories/chat_repository_impl.dart';
// import 'features/chat/domain/repositories/chat_repository.dart';
// import 'features/chat/domain/usecases/get_messages.dart';
// import 'features/chat/domain/usecases/send_message.dart';
// import 'features/chat/presentation/cubit/chat_cubit.dart';
// import 'features/localizations/data/datasources/lang_locale_data_source.dart';
// import 'features/localizations/data/repositories/lang_repository_impl.dart';
// import 'features/localizations/domain/repositories/lang_repository.dart';
// import 'features/localizations/domain/usecases/change_lang.dart';
// import 'features/localizations/domain/usecases/get_saved_lang.dart';
// import 'features/localizations/presentation/cubit/locale_cubit.dart';
// import 'features/notification/data/datasources/firebase_notification_data_source.dart';
// import 'features/notification/data/repositories/notification_repository_impl.dart';
// import 'features/notification/domain/repositories/notification_repository.dart';
// import 'features/notification/domain/usecases/get_fcm_token.dart';
// import 'features/notification/presentation/cubit/notification_cubit.dart';
// import 'features/stripe_payment/data/datasources/stripe_remote_data_source.dart';
// import 'features/stripe_payment/data/repositories/stripe_payment_repository_impl.dart';
// import 'features/stripe_payment/domain/repositories/stripe_payment_repository.dart';
// import 'features/stripe_payment/domain/usecases/confirm_payment_usecase.dart';
// import 'features/stripe_payment/domain/usecases/setup_payment_usecase.dart';
// import 'features/stripe_payment/presentation/cubit/stripe_payment_cubit.dart';
// import 'features/theme/data/datasources/theme_local_data_source.dart';
// import 'features/theme/data/repositories/theme_repository_impl.dart';
// import 'features/theme/domain/repositories/theme_repository.dart';
// import 'features/theme/domain/usecases/get_theme_mode.dart';
// import 'features/theme/domain/usecases/set_theme_mode.dart';
// import 'features/theme/presentation/cubit/theme_cubit.dart';
//
// final GetIt sl = GetIt.instance;
//
// Future<void> init() async {
//   //! External (register external dependencies first)
//   final sharedPreferences = await SharedPreferences.getInstance();
//   sl.registerLazySingleton(() => sharedPreferences);
//
//   sl.registerLazySingleton<InternetConnectionChecker>(
//     () => InternetConnectionChecker.instance,
//   );
//   sl.registerLazySingleton(() => Dio());
//
//   sl.registerLazySingleton(() => AppIntercepters());
//   sl.registerLazySingleton(
//     () => LogInterceptor(
//       request: true,
//       requestBody: true,
//       requestHeader: true,
//       responseBody: true,
//       responseHeader: true,
//       error: true,
//     ),
//   );
//
//   //! Core (register core utilities)
//   sl.registerLazySingleton<NetworkInfo>(
//     () => NetworkInfoImpl(connectionChecker: sl()),
//   );
//
//   sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(client: sl()));
//
//   // TODO: //! Data Source (register data sources)
//   sl.registerLazySingleton<ThemeLocalDataSource>(
//     () => ThemeLocalDataSourceImpl(sl()),
//   );
//
//   sl.registerLazySingleton<LangLocaleDataSource>(
//     () => LangLocaleDataSourceImpl(sharedPreferences: sl()),
//   );
//
//   sl.registerLazySingleton<ChatLocalDataSource>(
//     () => ChatLocalDataSourceImpl(),
//   );
//
//   sl.registerLazySingleton<BotChatLocalDataSource>(
//     () => BotChatLocalDataSourceImpl(),
//   );
//
//   sl.registerLazySingleton<StripeRemoteDataSource>(
//     () => StripeRemoteDataSourceImpl(sl()),
//   );
//
//   sl.registerLazySingleton<FirebaseNotificationDataSource>(
//     () => FirebaseNotificationDataSourceImpl(sl()),
//   );
//
//   // TODO: //! Repository (register repositories)
//   sl.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl(sl()));
//
//   sl.registerLazySingleton<LangRepository>(
//     () => LangRepositoryImpl(langLocaleDataSource: sl()),
//   );
//
//   sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
//   sl.registerLazySingleton<BotChatRepository>(
//     () => BotChatRepositoryImpl(sl()),
//   );
//
//   sl.registerLazySingleton<StripePaymentRepository>(
//     () => StripePaymentRepositoryImpl(remoteDataSource: sl()),
//   );
//
//   sl.registerLazySingleton<NotificationRepository>(
//     () => NotificationRepositoryImpl(sl()),
//   );
//
//   // TODO: //! UseCases (register use cases)
//   sl.registerLazySingleton(() => GetThemeMode(sl()));
//   sl.registerLazySingleton(() => SetThemeMode(sl()));
//
//   sl.registerLazySingleton<GetSavedLangUseCase>(
//     () => GetSavedLangUseCase(langRepository: sl()),
//   );
//   sl.registerLazySingleton<ChangeLangUseCase>(
//     () => ChangeLangUseCase(langRepository: sl()),
//   );
//
//   sl.registerLazySingleton(() => GetMessages(sl()));
//   sl.registerLazySingleton(() => SendMessage(sl()));
//
//   sl.registerLazySingleton(() => SendPredefinedMessage(sl()));
//
//   sl.registerLazySingleton(() => SetupPaymentUseCase(sl()));
//   sl.registerLazySingleton(() => ConfirmPaymentUseCase(sl()));
//
//   sl.registerLazySingleton(() => GetFcmToken(sl()));
//
//   // TODO: //! Blocs / Cubits (register cubits or blocs)
//   sl.registerFactory(() => ThemeCubit(getThemeMode: sl(), setThemeMode: sl()));
//
//   sl.registerFactory<LocaleCubit>(
//     () => LocaleCubit(changeLangUseCase: sl(), getSavedLangUseCase: sl()),
//   );
//
//   sl.registerFactory(() => ChatCubit(getMessages: sl(), sendMessage: sl()));
//
//   sl.registerFactory(() => BotChatCubit(sendPredefinedMessage: sl()));
//
//   sl.registerFactory(
//     () => StripePaymentCubit(
//       setupPaymentUseCase: sl(),
//       confirmPaymentUseCase: sl(),
//     ),
//   );
//
//   sl.registerFactory(() => NotificationCubit());
//
//   // ✅ Firebase Messaging Singleton
//   sl.registerLazySingleton(() => FirebaseMessaging.instance);
// }
