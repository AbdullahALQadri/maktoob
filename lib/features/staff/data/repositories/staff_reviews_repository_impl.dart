import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/api/staff_end_points.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/staff_review_entities.dart';
import '../../domain/repositories/staff_repository.dart';
import '../../domain/repositories/staff_reviews_repository.dart';
import '../datasources/staff_http.dart';
import '../models/staff_models.dart';
import '../models/staff_review_models.dart';

class StaffReviewsRepositoryImpl implements StaffReviewsRepository {
  StaffReviewsRepositoryImpl({required this.http});

  final StaffHttp http;

  static const _pending = {'status': 'pending', 'per_page': 50};

  @override
  StaffResult<List<StaffIdentity>> identities() => guardCall(() async {
        final response = await http.get(StaffEndpoints.adminIdentities, query: _pending);
        return StaffModels.rows(response, StaffReviewModels.identity);
      });

  @override
  StaffResult<StaffIdentity> identity(int id) => guardCall(() async {
        return StaffReviewModels.identity(StaffModels.data(await http.get(StaffEndpoints.adminIdentity(id))));
      });

  @override
  StaffResult<Uint8List> identityPhoto(int id, String side) =>
      guardCall(() => http.bytes(StaffEndpoints.adminIdentityDocument(id, side)));

  @override
  StaffResult<Unit> approveIdentity(int id, {String? notes}) => _done(
        // The reviewer confirmed on the screen that the photo matches.
        StaffEndpoints.adminIdentityApprove(id),
        {'notes': ?notes, 'confirm_match': true},
      );

  @override
  StaffResult<Unit> rejectIdentity(int id, String reason) => _done(StaffEndpoints.adminIdentityReject(id), {'reason': reason});

  @override
  StaffResult<List<StaffInstitution>> institutions() => guardCall(() async {
        final response = await http.get(StaffEndpoints.adminInstitutions, query: _pending);
        return StaffModels.rows(response, StaffReviewModels.institution);
      });

  @override
  StaffResult<StaffInstitution> institution(int id) => guardCall(() async {
        return StaffReviewModels.institution(StaffModels.data(await http.get(StaffEndpoints.adminInstitution(id))));
      });

  @override
  StaffResult<Uint8List> institutionDocument(int id, int documentId) =>
      guardCall(() => http.bytes(StaffEndpoints.adminInstitutionDocument(id, documentId)));

  @override
  StaffResult<Unit> approveInstitution(int id, {String? notes}) =>
      _done(StaffEndpoints.adminInstitutionApprove(id), {'notes': ?notes});

  @override
  StaffResult<Unit> rejectInstitution(int id, String reason) =>
      _done(StaffEndpoints.adminInstitutionReject(id), {'reason': reason});

  StaffResult<Unit> _done(String path, Map<String, dynamic> body) => guardCall(() async {
        await http.post(path, body: body);
        return unit;
      });
}
