import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/upgrade_options.dart';

/// Money matters around an event besides the payment itself: more
/// invitations, and a pro-forma invoice for a funder.
abstract class BillingRepository {
  Future<Either<Failure, UpgradeOptions>> upgradeOptions(String eventId);

  /// The price of a number of invitations the host names.
  Future<Either<Failure, UpgradeQuote>> customUpgradeQuote(String eventId, int invitations);

  /// A short-lived link to the pro-forma invoice (before payment only).
  Future<Either<Failure, String>> proformaUrl(String eventId, {String? funder, String? reference});
}
