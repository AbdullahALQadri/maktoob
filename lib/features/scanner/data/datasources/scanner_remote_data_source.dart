import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/check_in_guest_model.dart';

abstract class ScannerRemoteDataSource {
  /// Validates a scanned QR code against a venue and returns the invitation.
  Future<CheckInGuestModel> scanQrCode(String qrCode, int venueId);

  /// Confirms check-in for an invitation at a venue.
  Future<CheckInGuestModel> checkInGuest(
    String invitationId,
    int venueId, {
    int? actualCompanions,
    String? notes,
  });

  /// Lists guests already checked in at a venue (attendance).
  Future<List<CheckInGuestModel>> getGuestList(int venueId, {String? searchQuery});
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final ApiConsumer apiConsumer;

  ScannerRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<CheckInGuestModel> scanQrCode(String qrCode, int venueId) async {
    final response = await apiConsumer.post(
      Endpoints.scannerScan,
      body: {'qr_code': qrCode, 'venue_id': venueId},
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
    int venueId, {
    int? actualCompanions,
    String? notes,
  }) async {
    final response = await apiConsumer.post(
      Endpoints.scannerCheckInVerify(int.parse(invitationId)),
      body: {
        'invitation_id': int.parse(invitationId),
        'venue_id': venueId,
        if (actualCompanions != null) 'actual_companions': actualCompanions,
        if (notes != null) 'notes': notes,
      },
    );
    final data = response['data'] ?? response;
    final log = (data is Map ? data['attendance_log'] : null);
    final name = (log is Map ? log['guest_name'] : null) as String? ?? '';
    final companions =
        (log is Map && log['actual_companions'] is int) ? log['actual_companions'] as int : (actualCompanions ?? 0);
    return CheckInGuestModel(
      id: invitationId,
      name: name,
      status: 'checked_in',
      companions: companions,
      checkedIn: true,
      qrCode: '',
    );
  }

  @override
  Future<List<CheckInGuestModel>> getGuestList(int venueId, {String? searchQuery}) async {
    final queryParams = <String, dynamic>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }
    final response = await apiConsumer.get(
      Endpoints.scannerAttendance(venueId),
      queryParameters: queryParams,
    );
    final data = response['data'] ?? response;
    final list = (data is Map ? data['attendance'] : data) as List? ?? [];
    return list
        .map((g) => CheckInGuestModel.fromAttendanceJson(Map<String, dynamic>.from(g as Map)))
        .toList();
  }
}
