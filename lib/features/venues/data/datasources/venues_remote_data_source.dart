import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/venue_model.dart';

/// Abstract interface for remote data source
abstract class VenuesRemoteDataSource {
  Future<List<VenueModel>> getVenues();
  Future<VenueModel> addVenue(VenueModel venue);
  Future<List<VenueModel>> searchVenues(String query);
  Future<VenueModel> getVenueById(String id);
  Future<VenueModel> updateVenue(VenueModel venue);
  Future<void> deleteVenue(String id);
}

class VenuesRemoteDataSourceImpl implements VenuesRemoteDataSource {
  final ApiConsumer apiConsumer;

  VenuesRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<List<VenueModel>> getVenues() async {
    final response = await apiConsumer.get(Endpoints.venues);
    final data = response['data'] as List? ?? [];
    return data.map((v) => VenueModel.fromJson(v)).toList();
  }

  @override
  Future<VenueModel> addVenue(VenueModel venue) async {
    final response = await apiConsumer.post(
      Endpoints.venues,
      body: venue.toJson(),
    );
    return VenueModel.fromJson(response['data']);
  }

  @override
  Future<List<VenueModel>> searchVenues(String query) async {
    final response = await apiConsumer.get(
      Endpoints.venues,
      queryParameters: {'search': query},
    );
    final data = response['data'] as List? ?? [];
    return data.map((v) => VenueModel.fromJson(v)).toList();
  }

  @override
  Future<VenueModel> getVenueById(String id) async {
    final response = await apiConsumer.get(Endpoints.venue(int.parse(id)));
    return VenueModel.fromJson(response['data'] ?? response);
  }

  @override
  Future<VenueModel> updateVenue(VenueModel venue) async {
    final response = await apiConsumer.put(
      Endpoints.venue(int.parse(venue.id)),
      body: venue.toJson(),
    );
    return VenueModel.fromJson(response['data']);
  }

  @override
  Future<void> deleteVenue(String id) async {
    await apiConsumer.delete(Endpoints.venue(int.parse(id)));
  }
}
