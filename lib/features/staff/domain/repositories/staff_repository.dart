import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/staff_entities.dart';

typedef StaffResult<T> = Future<Either<Failure, T>>;

/// The staff mode: the team's own sign-in and its queues. It never touches
/// the client's session.
abstract class StaffRepository {
  StaffResult<StaffUser> signIn(String email, String password);

  /// The member already signed in on this phone, or null.
  StaffResult<StaffUser?> restore();
  Future<void> signOut();

  StaffResult<StaffToday> today();
  StaffResult<List<StaffPaymentRequest>> paymentRequests({String status = 'pending'});
  StaffResult<StaffPaymentRequest> paymentRequest(int id);

  /// Approving confirms the payment and activates (or enlarges) the event.
  StaffResult<Unit> approve(int id, {String? notes});

  /// The reason is shown to the client.
  StaffResult<Unit> reject(int id, String reason);

  StaffResult<List<StaffClientRow>> clients({String search = ''});
  StaffResult<List<StaffEventRow>> events({String search = ''});
}
