import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../models/check_in_guest_model.dart';

abstract class ScannerRemoteDataSource {
  /// Validates a scanned QR code and returns the invitation.
  ///
  /// Owner mode passes [eventId] (organizer scanning their own event), scanner
  /// mode passes [venueId] (dedicated scanner role). Exactly one is provided.
  Future<CheckInGuestModel> scanQrCode(
    String qrCode, {
    int? venueId,
    int? eventId,
  });

  /// Confirms check-in for an invitation.
  Future<CheckInGuestModel> checkInGuest(
    String invitationId, {
    int? venueId,
    int? eventId,
    int? actualCompanions,
    String? notes,
  });

  /// Lists the full invitee roster (all invitations + check-in status).
  Future<List<CheckInGuestModel>> getGuestList({
    int? venueId,
    int? eventId,
    String? searchQuery,
  });
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  final ApiConsumer apiConsumer;

  ScannerRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<CheckInGuestModel> scanQrCode(
    String qrCode, {
    int? venueId,
    int? eventId,
  }) async {
    final response = eventId != null
        ? await apiConsumer.post(
            Endpoints.eventCheckInScan(eventId),
            body: {'qr_code': qrCode},
          )
        : await apiConsumer.post(
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
    String invitationId, {
    int? venueId,
    int? eventId,
    int? actualCompanions,
    String? notes,
  }) async {
    // Owner mode: client check-in by invitation id (no venue authorization).
    if (eventId != null) {
      final response = await apiConsumer.post(
        Endpoints.invitationCheckIn(int.parse(invitationId)),
        body: {
          if (actualCompanions != null) 'actual_companions': actualCompanions,
          if (notes != null) 'notes': notes,
        },
      );
      final inv = response['invitation'];
      final name = (inv is Map ? inv['display_name'] : null) as String? ?? '';
      return CheckInGuestModel(
        id: invitationId,
        name: name,
        status: 'checked_in',
        companions: actualCompanions ?? 0,
        checkedIn: true,
        qrCode: '',
      );
    }

    // Scanner mode: venue-authorized verify.
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
  Future<List<CheckInGuestModel>> getGuestList({
    int? venueId,
    int? eventId,
    String? searchQuery,
  }) async {
    final queryParams = <String, dynamic>{};
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }
    final response = await apiConsumer.get(
      eventId != null
          ? Endpoints.eventGuestsCheckInList(eventId)
          : Endpoints.scannerRoster(venueId!),
      queryParameters: queryParams,
    );
    final data = response['data'] ?? response;
    // Both the owner and scanner roster endpoints return `data.guests`.
    final list = (data is Map ? (data['guests'] ?? data['attendance']) : data) as List? ?? [];
    return list
        .map((g) => CheckInGuestModel.fromRosterJson(Map<String, dynamic>.from(g as Map)))
        .toList();
  }
}
