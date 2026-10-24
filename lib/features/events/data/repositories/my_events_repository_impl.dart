import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_page.dart';
import '../../domain/repositories/my_events_repository.dart';
import '../datasources/my_events_remote_data_source.dart';

class MyEventsRepositoryImpl implements MyEventsRepository {
  const MyEventsRepositoryImpl({required this.remoteDataSource});

  final MyEventsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, EventPage>> getPage({EventStatus? status, String query = '', int page = 1}) =>
      guardCall(() => remoteDataSource.getPage(status: status, query: query, page: page));
}
