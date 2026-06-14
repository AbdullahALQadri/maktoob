/// Suggestion chip returned alongside a ready prompt to nudge the user
/// toward a better generation result.
class ImprovementSuggestion {
  final String icon; // material icon name e.g. "palette", "camera"
  final String text;

  const ImprovementSuggestion({required this.icon, required this.text});

  factory ImprovementSuggestion.fromJson(Map<String, dynamic> json) {
    return ImprovementSuggestion(
      icon: (json['icon'] as String?) ?? 'auto_awesome',
      text: (json['text'] as String?) ?? '',
    );
  }
}

class GenerationStatusModel {
  final String status; // processing | prompt_ready | completed | failed | not_found
  final int imageId;
  final String? promptText;  // set when status = prompt_ready
  final String? imageUrl;    // set when status = completed (Cloudinary CDN)
  final String? provider;
  final String? model;
  final String? error;

  /// Version label for the current prompt (e.g. "1.0", "2.4").
  /// Increments each time the prompt is regenerated. Optional — backend may
  /// return null on early rollouts; UI falls back to "1.0".
  final String? promptVersion;

  /// Suggestions shown on the prompt review screen. Returned with
  /// `prompt_ready`. Empty when the backend has none.
  final List<ImprovementSuggestion> improvementSuggestions;

  /// Total wall-clock time the generation took (set with `completed`).
  final int? generationTimeMs;

  const GenerationStatusModel({
    required this.status,
    required this.imageId,
    this.promptText,
    this.imageUrl,
    this.provider,
    this.model,
    this.error,
    this.promptVersion,
    this.improvementSuggestions = const [],
    this.generationTimeMs,
  });

  factory GenerationStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final rawSuggestions = data['improvement_suggestions'] as List?;
    return GenerationStatusModel(
      status:     (data['status'] as String?) ?? 'processing',
      imageId:    (data['image_id'] as int?) ?? 0,
      promptText: data['prompt_text'] as String?,
      imageUrl:   data['image_url']   as String?,
      provider:   data['provider']    as String?,
      model:      data['model']       as String?,
      error:      data['error']       as String?,
      promptVersion: data['prompt_version'] as String?,
      improvementSuggestions: rawSuggestions == null
          ? const []
          : rawSuggestions
              .whereType<Map<String, dynamic>>()
              .map(ImprovementSuggestion.fromJson)
              .toList(),
      generationTimeMs: (data['generation_time_ms'] as num?)?.toInt(),
    );
  }

  bool get isProcessing  => status == 'processing';
  bool get isPromptReady => status == 'prompt_ready';
  bool get isCompleted   => status == 'completed';
  bool get isFailed      => status == 'failed' || status == 'not_found';
}
