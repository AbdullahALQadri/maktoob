import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_summary.dart';

abstract class HomeRepository {
  /// The home screen in one call; offline it is the last saved copy.
  Future<Either<Failure, HomeSummary>> getHome();
}
