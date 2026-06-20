import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/check_in_guest_entity.dart';
import '../repositories/scanner_repository.dart';

class GetGuestListUseCase extends UseCase<List<CheckInGuestEntity>, GetGuestListParams> {
  final ScannerRepository repository;

  GetGuestListUseCase(this.repository);

  @override
  Future<Either<Failure, List<CheckInGuestEntity>>> call(GetGuestListParams params) async {
    return await repository.getGuestList(params.venueId, searchQuery: params.searchQuery);
  }
}

class GetGuestListParams extends Equatable {
  final int venueId;
  final String? searchQuery;

  const GetGuestListParams({required this.venueId, this.searchQuery});

  @override
  List<Object?> get props => [venueId, searchQuery];
}
