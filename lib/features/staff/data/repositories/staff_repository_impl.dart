import 'package:dartz/dartz.dart';

import '../../../../core/api/end_points.dart';
import '../../../../core/api/staff_end_points.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/staff_entities.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_http.dart';
import '../models/staff_models.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl({required this.http});

  final StaffHttp http;

  @override
  StaffResult<StaffUser> signIn(String email, String password) => guardCall(() async {
        final response = await http.post(
          Endpoints.adminLogin,
          body: {'email': email, 'password': password},
          signedIn: false,
        );
        final data = StaffModels.data(response);
        final token = '${data['token'] ?? ''}';
        if (token.isEmpty) throw const ServerException(message: 'staff_sign_in_failed');
        await http.tokens.write(token);
        return StaffModels.user(data['user']);
      });

  @override
  StaffResult<StaffUser?> restore() => guardCall(() async {
        final token = await http.tokens.read();
        if (token == null || token.isEmpty) return null;
        try {
          final data = StaffModels.data(await http.get(Endpoints.adminProfile));
          return StaffModels.user(data['user'] ?? data);
        } on UnauthorizedException {
          // The sign-in ended (password changed, signed in elsewhere).
          await http.tokens.clear();
          return null;
        }
      });

  @override
  Future<void> signOut() async {
    try {
      await http.post(Endpoints.adminLogout);
    } catch (_) {
      // Offline or already ended: the phone forgets the sign-in either way.
    }
    await http.tokens.clear();
  }

  @override
  StaffResult<StaffToday> today() =>
      guardCall(() async => StaffModels.today(StaffModels.data(await http.get(StaffEndpoints.adminToday))));

  @override
  StaffResult<List<StaffPaymentRequest>> paymentRequests({String status = 'pending'}) => guardCall(() async {
        final response = await http.get(StaffEndpoints.adminPaymentRequests, query: {'status': status, 'per_page': 50});
        return StaffModels.rows(response, StaffModels.paymentRequest);
      });

  @override
  StaffResult<StaffPaymentRequest> paymentRequest(int id) => guardCall(() async {
        final data = StaffModels.data(await http.get(StaffEndpoints.adminPaymentRequest(id)));
        return StaffModels.paymentRequest(data['request'], imageUrls: data['image_urls']);
      });

  @override
  StaffResult<Unit> approve(int id, {String? notes}) => guardCall(() async {
        await http.post(StaffEndpoints.adminPaymentRequestApprove(id), body: {'notes': ?notes, 'notify_firebase': true});
        return unit;
      });

  @override
  StaffResult<Unit> reject(int id, String reason) => guardCall(() async {
        await http.post(StaffEndpoints.adminPaymentRequestReject(id), body: {'reason': reason, 'notify_firebase': true});
        return unit;
      });

  @override
  StaffResult<List<StaffClientRow>> clients({String search = ''}) => guardCall(() async {
        final response = await http.get(
          StaffEndpoints.adminClients,
          query: {'per_page': 50, if (search.isNotEmpty) 'search': search},
        );
        return StaffModels.rows(response, StaffModels.client);
      });

  @override
  StaffResult<List<StaffEventRow>> events({String search = ''}) => guardCall(() async {
        final response = await http.get(
          StaffEndpoints.adminEvents,
          query: {'per_page': 50, if (search.isNotEmpty) 'search': search},
        );
        return StaffModels.rows(response, StaffModels.event);
      });
}
