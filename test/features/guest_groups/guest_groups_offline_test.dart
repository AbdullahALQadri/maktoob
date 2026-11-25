import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/exceptions.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/guest_groups/data/datasources/guest_groups_remote_data_source.dart';
import 'package:maktoob/features/guest_groups/data/repositories/guest_groups_repository_impl.dart';
import 'package:maktoob/features/guest_groups/domain/entities/guest_group.dart';
import 'package:maktoob/features/guest_groups/domain/usecases/guest_group_usecases.dart';
import 'package:maktoob/features/guest_groups/presentation/cubit/guest_group_cubit.dart';

/// A server that can be reached, or not.
class _Remote implements GuestGroupsRemoteDataSource {
  bool offline = false;
  final calls = <String>[];

  static const _group = GuestGroup(
    id: 3,
    name: 'العائلة',
    guestsCount: 1,
    guests: [GroupGuest(id: 1, name: 'سارة', phone: '0599123456')],
  );

  Future<T> _answer<T>(String call, T value) async {
    if (offline) throw const NoInternetConnectionException();
    calls.add(call);
    return value;
  }

  @override
  Future<GuestGroupsOverview> groups() => _answer('groups', const GuestGroupsOverview(groups: [_group]));

  @override
  Future<GuestGroup> group(int id) => _answer('group', _group);

  @override
  Future<GuestGroup> create(String name, List<GroupGuest> guests) => _answer('create', _group);

  @override
  Future<GuestGroup> rename(int id, String name) => _answer('rename', _group);

  @override
  Future<GuestGroup> addGuests(int id, List<GroupGuest> guests) => _answer('add', _group);

  @override
  Future<GuestGroup> removeGuest(int id, int guestId) => _answer('remove', _group);

  @override
  Future<void> delete(int id) => _answer('delete', null);
}

void main() {
  test('without a queue, a change with no connection is a plain network failure', () async {
    final repo = GuestGroupsRepositoryImpl(remoteDataSource: _Remote()..offline = true);
    final result = await repo.rename(3, 'الأهل');
    expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
    expect(result.fold((f) => f is QueuedOfflineFailure, (_) => false), isFalse);
  });

  test('a change the phone queued shows at once on the open group', () async {
    final remote = _Remote();
    // Stands in for the repository with its queue: answers "queued" offline.
    final repo = _QueuedWhenOffline(remote);
    final cubit = GuestGroupCubit(
      getGroup: GetGuestGroupUseCase(repo),
      changeGroup: ChangeGuestGroupUseCase(repo),
      deleteGroup: DeleteGuestGroupUseCase(repo),
      groupId: 3,
    );
    await cubit.load();
    remote.offline = true;

    expect(await cubit.addGuest('منى', '0599000111'), isTrue);
    expect(cubit.state.group?.guests.map((g) => g.name), ['سارة', 'منى']);
    expect(cubit.state.message, 'event_queued_offline');

    await cubit.removeGuest(1);
    expect(cubit.state.group?.guests.single.name, 'منى');

    await cubit.rename('الأهل');
    expect(cubit.state.group?.name, 'الأهل');

    await cubit.delete();
    expect(cubit.state.deleted, isTrue);
    expect(repo.queued, ['add', 'remove', 'rename', 'delete']);
    await cubit.close();
  });
}

class _QueuedWhenOffline extends GuestGroupsRepositoryImpl {
  _QueuedWhenOffline(_Remote remote) : super(remoteDataSource: remote);

  final queued = <String>[];

  @override
  Future<dartz.Either<Failure, GuestGroup>> rename(int id, String name) => _queue('rename', () => super.rename(id, name));

  @override
  Future<dartz.Either<Failure, GuestGroup>> addGuests(int id, List<GroupGuest> guests) =>
      _queue('add', () => super.addGuests(id, guests));

  @override
  Future<dartz.Either<Failure, GuestGroup>> removeGuest(int id, int guestId) =>
      _queue('remove', () => super.removeGuest(id, guestId));

  @override
  Future<dartz.Either<Failure, dartz.Unit>> delete(int id) => _queue('delete', () => super.delete(id));

  Future<dartz.Either<Failure, T>> _queue<T>(String name, Future<dartz.Either<Failure, T>> Function() call) async {
    final result = await call();
    if (result.isRight()) return result;
    queued.add(name);
    return const dartz.Left(QueuedOfflineFailure());
  }
}
