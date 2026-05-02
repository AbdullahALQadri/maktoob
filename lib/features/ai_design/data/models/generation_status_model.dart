class GenerationStatusModel {
  final String status; // processing | prompt_ready | completed | failed | not_found
  final int imageId;
  final String? promptText;  // set when status = prompt_ready
  final String? imageUrl;    // set when status = completed (Cloudinary CDN)
  final String? provider;
  final String? model;
  final String? error;

  const GenerationStatusModel({
    required this.status,
    required this.imageId,
    this.promptText,
    this.imageUrl,
    this.provider,
    this.model,
    this.error,
  });

  factory GenerationStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return GenerationStatusModel(
      status:     (data['status'] as String?) ?? 'processing',
      imageId:    (data['image_id'] as int?) ?? 0,
      promptText: data['prompt_text'] as String?,
      imageUrl:   data['image_url']   as String?,
      provider:   data['provider']    as String?,
      model:      data['model']       as String?,
      error:      data['error']       as String?,
    );
  }

  bool get isProcessing  => status == 'processing';
  bool get isPromptReady => status == 'prompt_ready';
  bool get isCompleted   => status == 'completed';
  bool get isFailed      => status == 'failed' || status == 'not_found';
}
