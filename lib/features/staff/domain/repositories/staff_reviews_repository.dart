import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../entities/staff_review_entities.dart';
import 'staff_repository.dart';

/// Identity and institution reviews of the staff mode.
abstract class StaffReviewsRepository {
  StaffResult<List<StaffIdentity>> identities();
  StaffResult<StaffIdentity> identity(int id);

  /// One photo of the document (`front` / `back`). The server records who
  /// opened it; the phone keeps it in memory only.
  StaffResult<Uint8List> identityPhoto(int id, String side);
  StaffResult<Unit> approveIdentity(int id, {String? notes});
  StaffResult<Unit> rejectIdentity(int id, String reason);

  StaffResult<List<StaffInstitution>> institutions();
  StaffResult<StaffInstitution> institution(int id);
  StaffResult<Uint8List> institutionDocument(int id, int documentId);
  StaffResult<Unit> approveInstitution(int id, {String? notes});
  StaffResult<Unit> rejectInstitution(int id, String reason);
}
