import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/api/paginated_fetch.dart';
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
  Future<List<VenueModel>> getVenues() => _fetchAll(const {});

  /// GET /venues returns the raw Laravel paginator (15 per page by default,
  /// at most 100). Walk every page so hosts with many venues see them all.
  Future<List<VenueModel>> _fetchAll(Map<String, dynamic> query) {
    return Pagination.fetchAll(
      apiConsumer,
      Endpoints.venues,
      query: query,
      perPage: 100,
      maxPages: 20,
      parse: VenueModel.fromJson,
    );
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
  Future<List<VenueModel>> searchVenues(String query) =>
      _fetchAll({'search': query});

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
