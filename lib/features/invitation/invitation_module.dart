import 'package:get_it/get_it.dart';

import '../../core/api/event_wizard_api_service.dart';
import 'data/repositories/event_wizard_repository_impl.dart';
import 'data/services/excel_parser_service.dart';
import 'data/services/whatsapp_service.dart';
import 'domain/repositories/event_wizard_repository.dart';
import 'presentation/cubit/invitation_cubit.dart';

/// Registers the event wizard: API service -> repository -> cubit, with the
/// helpers it uses (Excel import, WhatsApp hand-off).
void registerInvitationModule(GetIt sl) {
  sl
    ..registerLazySingleton(() => EventWizardApiService(apiConsumer: sl()))
    ..registerLazySingleton<EventWizardRepository>(() => EventWizardRepositoryImpl(sl()))
    ..registerLazySingleton(() => ExcelParserService())
    ..registerLazySingleton(() => WhatsAppService())
    ..registerFactory(
      () => InvitationCubit(
        repository: sl(),
        excelParserService: sl(),
        whatsAppService: sl(),
      ),
    );
}
