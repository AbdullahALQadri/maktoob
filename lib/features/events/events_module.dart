import 'package:get_it/get_it.dart';

import 'data/datasources/event_add_ons_remote_data_source.dart';
import 'data/datasources/events_local_data_source.dart';
import 'data/datasources/events_remote_data_source.dart';
import 'data/repositories/event_add_ons_repository_impl.dart';
import 'data/repositories/events_repository_impl.dart';
import 'domain/repositories/event_add_ons_repository.dart';
import 'domain/repositories/events_repository.dart';
import 'domain/usecases/get_event_add_ons_usecase.dart';
import 'domain/usecases/request_event_add_on_usecase.dart';
import 'domain/usecases/withdraw_event_add_on_usecase.dart';
import 'domain/usecases/filter_events_usecase.dart';
import 'domain/usecases/get_event_details_usecase.dart';
import 'domain/usecases/get_events_usecase.dart';
import 'presentation/cubit/events_list/events_list_cubit.dart';
import 'presentation/cubit/edit_event/edit_event_cubit.dart';
import 'presentation/cubit/event_add_ons/event_add_ons_cubit.dart';
import 'presentation/cubit/event_details/event_details_cubit.dart';
import 'data/datasources/event_follow_up_remote_data_source.dart';
import 'data/datasources/my_events_remote_data_source.dart';
import 'data/repositories/event_follow_up_repository_impl.dart';
import 'domain/repositories/event_follow_up_repository.dart';
import 'domain/usecases/event_follow_up_usecases.dart';
import 'presentation/cubit/event_follow_up/event_follow_up_cubit.dart';
import 'data/repositories/my_events_repository_impl.dart';
import 'domain/repositories/my_events_repository.dart';
import 'domain/usecases/get_my_events_usecase.dart';
import 'presentation/cubit/my_events/my_events_cubit.dart';

/// Registers the events feature: the host's list, an event's page, its
/// edits and add-ons, and "My events" (the portal's list with counts).
void registerEventsModule(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<EventsRemoteDataSource>(() => EventsRemoteDataSourceImpl(apiConsumer: sl()));

  sl.registerLazySingleton<EventsLocalDataSource>(() => EventsLocalDataSourceImpl(sharedPreferences: sl()));

  // Repository
  sl.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl(), pendingActions: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetEventsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventDetailsUseCase(sl()));
  sl.registerLazySingleton(() => FilterEventsUseCase(sl()));

  // Cubits
  sl.registerFactory(() => EventsListCubit(getEventsUseCase: sl(), filterEventsUseCase: sl()));

  sl.registerFactory(() => EventDetailsCubit(getEventDetailsUseCase: sl(), eventsRepository: sl()));

  sl.registerFactory(() => EditEventCubit(eventsRepository: sl()));

  // Extra services on a paid event (request → team review → pay only them)
  sl.registerLazySingleton<EventAddOnsRemoteDataSource>(() => EventAddOnsRemoteDataSourceImpl(apiConsumer: sl()));
  sl.registerLazySingleton<EventAddOnsRepository>(() => EventAddOnsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetEventAddOnsUseCase(sl()));
  sl.registerLazySingleton(() => RequestEventAddOnUseCase(sl()));
  sl.registerLazySingleton(() => WithdrawEventAddOnUseCase(sl()));
  sl.registerFactory(() => EventAddOnsCubit(getAddOns: sl(), requestAddOn: sl(), withdrawAddOn: sl()));

  // My events: the portal's list (status tabs with counts, search)
  sl.registerLazySingleton<MyEventsRemoteDataSource>(() => MyEventsRemoteDataSourceImpl(apiConsumer: sl()));
  sl.registerLazySingleton<MyEventsRepository>(() => MyEventsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetMyEventsUseCase(sl()));
  sl.registerFactory(() => MyEventsCubit(getPage: sl()));

  // Event page follow-up: setup steps, activity, resend failed, fix an unsent guest
  sl.registerLazySingleton<EventFollowUpRemoteDataSource>(() => EventFollowUpRemoteDataSourceImpl(apiConsumer: sl()));
  sl.registerLazySingleton<EventFollowUpRepository>(() => EventFollowUpRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetEventFollowUpUseCase(sl()));
  sl.registerLazySingleton(() => ResendFailedInvitationsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUnsentGuestUseCase(sl()));
  sl.registerFactory(
    () => EventFollowUpCubit(getFollowUp: sl(), resendFailedInvitations: sl(), updateUnsentGuest: sl()),
  );
}
