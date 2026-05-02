import 'package:equatable/equatable.dart';

class AiImageModel extends Equatable {
  final int id;
  final String title;
  final String imageUrl;
  final String prompt; // internal base_prompt — NEVER shown to user

  const AiImageModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.prompt,
  });

  factory AiImageModel.fromJson(Map<String, dynamic> json) => AiImageModel(
        id:       json['id'] as int,
        title:    (json['title'] as String?) ?? '',
        imageUrl: (json['image_url'] as String?) ?? '',
        prompt:   (json['prompt'] as String?) ?? '',
      );

  @override
  List<Object?> get props => [id, title, imageUrl, prompt];
}
