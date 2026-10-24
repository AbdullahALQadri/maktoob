import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_summary.dart';
import '../repositories/home_repository.dart';

class GetHomeUseCase {
  const GetHomeUseCase(this.repository);

  final HomeRepository repository;

  Future<Either<Failure, HomeSummary>> call() => repository.getHome();
}
