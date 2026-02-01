import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/check_in_guest_model.dart';
import '../models/scan_result_model.dart';

abstract class ScannerRemoteDataSource {
  /// Sends QR code data to server for validation
  Future<ScanResultModel> scanQrCode(String qrData);

  /// Checks in a guest by their ID
  Future<CheckInGuestModel> checkInGuest(String guestId);

  /// Gets the list of all guests with optional search filter
  Future<List<CheckInGuestModel>> getGuestList({String? searchQuery});

  /// Gets a specific guest by ID
  Future<CheckInGuestModel> getGuestById(String guestId);
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final ApiConsumer apiConsumer;

  ScannerRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<ScanResultModel> scanQrCode(String qrData) async {
    final response = await apiConsumer.post(
      Endpoints.scannerScan,
      body: {'qr_data': qrData},
    );
    return ScanResultModel.fromJson(response['data'] ?? response);
  }

  @override
  Future<CheckInGuestModel> checkInGuest(String guestId) async {
    final response = await apiConsumer.post(
      Endpoints.scannerCheckInVerify(int.parse(guestId)),
    );
    return CheckInGuestModel.fromJson(response['data'] ?? response);
  }

  @override
  Future<List<CheckInGuestModel>> getGuestList({String? searchQuery}) async {
    final queryParams = <String, dynamic>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }
    final response = await apiConsumer.get(
      Endpoints.scannerCheckInHistory,
      queryParameters: queryParams,
    );
    final data = response['data'] as List? ?? [];
    return data.map((g) => CheckInGuestModel.fromJson(g)).toList();
  }

  @override
  Future<CheckInGuestModel> getGuestById(String guestId) async {
    final response = await apiConsumer.get(
      Endpoints.scannerCheckInVerify(int.parse(guestId)),
    );
    return CheckInGuestModel.fromJson(response['data'] ?? response);
  }
}
