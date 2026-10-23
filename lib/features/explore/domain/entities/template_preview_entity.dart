import 'package:equatable/equatable.dart';

/// A ready-made starter design shown in the public gallery.
class TemplatePreviewEntity extends Equatable {
  final int id;
  final String? title;
  final String imageUrl;
  final String thumbnailUrl;
  final int? eventTypeId;

  const TemplatePreviewEntity({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    this.title,
    this.eventTypeId,
  });

  @override
  List<Object?> get props => [id, title, imageUrl, thumbnailUrl, eventTypeId];
}
