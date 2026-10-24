import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/identity_entities.dart';
import '../repositories/identity_repository.dart';

class GetIdentityUseCase implements UseCase<IdentityOverviewEntity, GetIdentityParams> {
  final IdentityRepository repository;

  GetIdentityUseCase(this.repository);

  @override
  Future<Either<Failure, IdentityOverviewEntity>> call(GetIdentityParams params) =>
      repository.getOverview(locale: params.locale);
}

class GetIdentityParams extends Equatable {
  /// `ar` | `en`: the language of the option labels (countries, document types).
  final String? locale;

  const GetIdentityParams({this.locale});

  @override
  List<Object?> get props => [locale];
}
