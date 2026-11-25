import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../domain/entities/guest_group.dart';
import '../models/guest_group_model.dart';

abstract class GuestGroupsRemoteDataSource {
  Future<GuestGroupsOverview> groups();
  Future<GuestGroup> group(int id);
  Future<GuestGroup> create(String name, List<GroupGuest> guests);
  Future<GuestGroup> rename(int id, String name);
  Future<GuestGroup> addGuests(int id, List<GroupGuest> guests);
  Future<GuestGroup> removeGuest(int id, int guestId);
  Future<void> delete(int id);
}

class GuestGroupsRemoteDataSourceImpl implements GuestGroupsRemoteDataSource {
  GuestGroupsRemoteDataSourceImpl({required this.apiConsumer});

  final ApiConsumer apiConsumer;

  @override
  Future<GuestGroupsOverview> groups() async => GuestGroupModel.overview(await apiConsumer.get(Endpoints.guestGroups));

  @override
  Future<GuestGroup> group(int id) async => GuestGroupModel.fromResponse(await apiConsumer.get(Endpoints.guestGroup(id)));

  @override
  Future<GuestGroup> create(String name, List<GroupGuest> guests) async => GuestGroupModel.fromResponse(
        await apiConsumer.post(
          Endpoints.guestGroups,
          body: {'name': name, if (guests.isNotEmpty) 'guests': GuestGroupModel.guestsToJson(guests)},
        ),
      );

  @override
  Future<GuestGroup> rename(int id, String name) async =>
      GuestGroupModel.fromResponse(await apiConsumer.put(Endpoints.guestGroup(id), body: {'name': name}));

  @override
  Future<GuestGroup> addGuests(int id, List<GroupGuest> guests) async => GuestGroupModel.fromResponse(
        await apiConsumer.post(Endpoints.guestGroupGuests(id), body: {'guests': GuestGroupModel.guestsToJson(guests)}),
      );

  @override
  Future<GuestGroup> removeGuest(int id, int guestId) async =>
      GuestGroupModel.fromResponse(await apiConsumer.delete(Endpoints.guestGroupGuest(id, guestId)));

  @override
  Future<void> delete(int id) async => apiConsumer.delete(Endpoints.guestGroup(id));
}
