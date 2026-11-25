import 'package:dartz/dartz.dart';

import '../../../../core/api/end_points.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/offline/pending_actions_queue.dart';
import '../../domain/entities/guest_group.dart';
import '../../domain/repositories/guest_groups_repository.dart';
import '../datasources/guest_groups_remote_data_source.dart';
import '../models/guest_group_model.dart';

/// Reading works offline from the last good answer (the HTTP cache). A
/// change made with no connection is queued and sent when it returns: the
/// caller gets [QueuedOfflineFailure] and shows the change as done.
class GuestGroupsRepositoryImpl implements GuestGroupsRepository {
  GuestGroupsRepositoryImpl({required this.remoteDataSource, this.networkInfo, this.pendingActions});

  final GuestGroupsRemoteDataSource remoteDataSource;
  final NetworkInfo? networkInfo;
  final PendingActionsQueue? pendingActions;

  @override
  Future<Either<Failure, GuestGroupsOverview>> groups() => guardCall(remoteDataSource.groups);

  @override
  Future<Either<Failure, GuestGroup>> group(int id) => guardCall(() => remoteDataSource.group(id));

  @override
  Future<Either<Failure, GuestGroup>> create(String name, {List<GroupGuest> guests = const []}) => _orQueue(
        () => remoteDataSource.create(name, guests),
        label: 'offline_action_group_create',
        method: 'POST',
        path: Endpoints.guestGroups,
        body: {'name': name, if (guests.isNotEmpty) 'guests': GuestGroupModel.guestsToJson(guests)},
      );

  @override
  Future<Either<Failure, GuestGroup>> rename(int id, String name) => _orQueue(
        () => remoteDataSource.rename(id, name),
        label: 'offline_action_group_rename',
        method: 'PUT',
        path: Endpoints.guestGroup(id),
        body: {'name': name},
      );

  @override
  Future<Either<Failure, GuestGroup>> addGuests(int id, List<GroupGuest> guests) => _orQueue(
        () => remoteDataSource.addGuests(id, guests),
        label: 'offline_action_group_add_guest',
        method: 'POST',
        path: Endpoints.guestGroupGuests(id),
        body: {'guests': GuestGroupModel.guestsToJson(guests)},
      );

  @override
  Future<Either<Failure, GuestGroup>> removeGuest(int id, int guestId) => _orQueue(
        () => remoteDataSource.removeGuest(id, guestId),
        label: 'offline_action_group_remove_guest',
        method: 'DELETE',
        path: Endpoints.guestGroupGuest(id, guestId),
      );

  @override
  Future<Either<Failure, Unit>> delete(int id) => _orQueue(
        () async {
          await remoteDataSource.delete(id);
          return unit;
        },
        label: 'offline_action_group_delete',
        method: 'DELETE',
        path: Endpoints.guestGroup(id),
      );

  Future<Either<Failure, T>> _orQueue<T>(
    Future<T> Function() call, {
    required String label,
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final queue = pendingActions;
    Future<Either<Failure, T>> queued() async {
      await queue!.enqueue(label: label, method: method, path: path, body: body);
      return const Left(QueuedOfflineFailure());
    }

    if (queue != null && networkInfo != null && !await networkInfo!.isConnected) return queued();
    try {
      return Right(await call());
    } on NoInternetConnectionException {
      return queue != null ? queued() : const Left(NetworkFailure(message: 'No internet connection'));
    } catch (e) {
      return guardCall(() => throw e);
    }
  }
}
