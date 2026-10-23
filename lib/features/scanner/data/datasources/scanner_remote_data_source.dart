import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/check_in_guest_model.dart';

abstract class ScannerRemoteDataSource {
  /// Validates a scanned QR code against one of the host's events and returns the invitation.
  Future<CheckInGuestModel> scanQrCode(String qrCode, int eventId);

  /// Confirms check-in for an invitation.
  Future<CheckInGuestModel> checkInGuest(
    String invitationId,
    int eventId, {
    int? actualCompanions,
    String? notes,
  });

  /// The event's full invitee roster with check-in status.
  Future<List<CheckInGuestModel>> getGuestList(int eventId, {String? searchQuery});
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final ApiConsumer apiConsumer;

  ScannerRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<CheckInGuestModel> scanQrCode(String qrCode, int eventId) async {
    final response = await apiConsumer.post(
      Endpoints.eventCheckInScan(eventId),
      body: {'qr_code': qrCode},
    );
    final data = response['data'] ?? response;
    final invitation = (data is Map ? data['invitation'] : null) ?? data;
    return CheckInGuestModel.fromInvitationJson(
      Map<String, dynamic>.from(invitation as Map),
      qrCode: qrCode,
    );
  }

  @override
  Future<CheckInGuestModel> checkInGuest(
    String invitationId,
    int eventId, {
    int? actualCompanions,
    String? notes,
  }) async {
    final response = await apiConsumer.post(
      Endpoints.invitationCheckIn(int.parse(invitationId)),
      body: {
        if (actualCompanions != null) 'actual_companions': actualCompanions,
        if (notes != null) 'notes': notes,
      },
    );
    // 422 {message, code: event_not_active|too_many_companions} and
    // 409 (already checked in) surface as exceptions from ApiConsumer.
    return CheckInGuestModel.fromCheckInResponse(
      response,
      invitationId: invitationId,
      requestedCompanions: actualCompanions,
    );
  }

  @override
  Future<List<CheckInGuestModel>> getGuestList(int eventId, {String? searchQuery}) async {
    final queryParams = <String, dynamic>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }
    final response = await apiConsumer.get(
      Endpoints.eventCheckInList(eventId),
      queryParameters: queryParams,
    );
    final data = response['data'] ?? response;
    final list = (data is Map ? data['guests'] : data) as List? ?? [];
    return list
        .map((g) => CheckInGuestModel.fromRosterJson(Map<String, dynamic>.from(g as Map)))
        .toList();
  }
}
