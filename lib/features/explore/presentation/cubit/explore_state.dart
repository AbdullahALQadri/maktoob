import 'package:equatable/equatable.dart';

import '../../domain/entities/occasion_group_entity.dart';
import '../../domain/entities/template_preview_entity.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class ExploreLoaded extends ExploreState {
  final List<OccasionGroupEntity> groups;
  final int? selectedGroupId;
  final int? selectedTypeId;
  final List<TemplatePreviewEntity> templates;
  final bool templatesLoading;

  const ExploreLoaded({
    required this.groups,
    this.selectedGroupId,
    this.selectedTypeId,
    this.templates = const [],
    this.templatesLoading = false,
  });

  OccasionGroupEntity? get selectedGroup {
    for (final g in groups) {
      if (g.id == selectedGroupId) return g;
    }
    return null;
  }

  ExploreLoaded copyWith({
    int? selectedGroupId,
    int? selectedTypeId,
    List<TemplatePreviewEntity>? templates,
    bool? templatesLoading,
  }) {
    return ExploreLoaded(
      groups: groups,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      selectedTypeId: selectedTypeId ?? this.selectedTypeId,
      templates: templates ?? this.templates,
      templatesLoading: templatesLoading ?? this.templatesLoading,
    );
  }

  @override
  List<Object?> get props =>
      [groups, selectedGroupId, selectedTypeId, templates, templatesLoading];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}
