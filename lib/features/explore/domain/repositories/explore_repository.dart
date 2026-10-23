import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/occasion_group_entity.dart';
import '../entities/template_preview_entity.dart';

/// Read-only data for guests browsing without an account.
/// Every call here must hit a `/public/*` endpoint only.
abstract class ExploreRepository {
  Future<Either<Failure, List<OccasionGroupEntity>>> getOccasionGroups();

  Future<Either<Failure, List<TemplatePreviewEntity>>> getTemplates({
    int? eventTypeId,
  });
}
