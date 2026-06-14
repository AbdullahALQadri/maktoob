import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/edit_request_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/guest_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_local_data_source.dart';
import '../datasources/events_remote_data_source.dart';
import '../models/event_model.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remoteDataSource;
  final EventsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  EventsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteEvents = await remoteDataSource.getEvents();
        await localDataSource.cacheEvents(remoteEvents);
        return Right(remoteEvents.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localEvents = await localDataSource.getCachedEvents();
        return Right(localEvents.map((e) => e.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventDetails(String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        final event = await remoteDataSource.getEventDetails(eventId);
        return Right(event.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final event = await localDataSource.getCachedEvent(eventId);
        if (event != null) {
          return Right(event.toEntity());
        } else {
          return const Left(CacheFailure(message: 'Event not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<GuestEntity>>> getEventGuests(
      String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        final guests = await remoteDataSource.getEventGuests(eventId);
        return Right(guests.map((g) => g.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> createEvent(
      CreateEventParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final event = await remoteDataSource.createEvent(params);
        return Right(event.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> updateEvent(
      String eventId, UpdateEventParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final event = await remoteDataSource.updateEvent(eventId, params);
        return Right(event.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteEvent(eventId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> filterEvents({
    String? searchQuery,
    EventStatus? status,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final events = await remoteDataSource.filterEvents(
          searchQuery: searchQuery,
          status: status,
        );
        return Right(events.map((e) => e.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localEvents = await localDataSource.getCachedEvents();
        final filteredEvents = localEvents.where((event) {
          final matchesSearch = searchQuery == null ||
              searchQuery.isEmpty ||
              event.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              event.type.toLowerCase().contains(searchQuery.toLowerCase()) ||
              event.venue.toLowerCase().contains(searchQuery.toLowerCase());

          final matchesStatus = status == null || event.status == status;

          return matchesSearch && matchesStatus;
        }).toList();

        return Right(filteredEvents.map((e) => e.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getCachedEvents() async {
    try {
      final events = await localDataSource.getCachedEvents();
      return Right(events.map((e) => e.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, EditRequestEntity>> submitEditRequest(
      String eventId, UpdateEventParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final request =
            await remoteDataSource.submitEditRequest(eventId, params);
        return Right(request.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<EditRequestEntity>>> getEditRequests(
      String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        final requests = await remoteDataSource.getEditRequests(eventId);
        return Right(requests.map((r) => r.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
