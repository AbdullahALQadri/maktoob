import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/template_preview_entity.dart';
import '../repositories/explore_repository.dart';

class GetPublicTemplatesUseCase {
  final ExploreRepository repository;

  GetPublicTemplatesUseCase(this.repository);

  Future<Either<Failure, List<TemplatePreviewEntity>>> call({
    int? eventTypeId,
  }) =>
      repository.getTemplates(eventTypeId: eventTypeId);
}
