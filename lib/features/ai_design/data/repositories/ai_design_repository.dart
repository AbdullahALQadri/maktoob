import '../../../../core/api/event_wizard_api_service.dart';
import '../models/ai_form_field_model.dart';
import '../models/ai_image_model.dart';
import '../models/generation_status_model.dart';

class AiDesignRepository {
  final EventWizardApiService _api;
  const AiDesignRepository(this._api);

  Future<List<AiImageModel>> getGalleryImages(int eventTypeId) async {
    final res = await _api.getAiGalleryImages(eventTypeId: eventTypeId);
    final data  = res['data'] as Map<String, dynamic>? ?? {};
    final list  = data['images'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AiImageModel.fromJson)
        .toList();
  }

  Future<List<AiFormFieldModel>> getFormFields(int eventTypeId) async {
    final res = await _api.getAiFormFields(eventTypeId);
    final data   = res['data'] as Map<String, dynamic>? ?? {};
    final fields = data['fields'] as List<dynamic>? ?? [];
    return fields
        .whereType<Map<String, dynamic>>()
        .map(AiFormFieldModel.fromJson)
        .toList();
  }

  Future<int> generatePrompt(
    int eventId, {
    String? basePrompt,
    String? freeformPrompt,
    required int eventTypeId,
    required Map<String, String> formValues,
    String? customPrompt,
  }) async {
    final res = await _api.generatePrompt(
      eventId,
      basePrompt:     basePrompt,
      freeformPrompt: freeformPrompt,
      eventTypeId:    eventTypeId,
      formValues:     formValues,
      customPrompt:   customPrompt,
    );
    final data    = res['data'] as Map<String, dynamic>? ?? {};
    final imageId = data['image_id'];
    if (imageId == null) throw Exception('generate-prompt returned no image_id');
    return imageId as int;
  }

  Future<GenerationStatusModel> getStatus(int eventId, int imageId) async {
    final res = await _api.getGenerationStatus(eventId, imageId);
    return GenerationStatusModel.fromJson(res);
  }

  Future<int> confirmGenerate(
    int eventId, {
    required int imageId,
    required String promptText,
  }) async {
    final res = await _api.confirmGenerate(
      eventId,
      imageId:    imageId,
      promptText: promptText,
    );
    final data      = res['data'] as Map<String, dynamic>? ?? {};
    final returnedId = data['image_id'];
    if (returnedId == null) throw Exception('confirm-generate returned no image_id');
    return returnedId as int;
  }

  Future<void> saveImageToEvent(int eventId, int imageId) async {
    await _api.saveAiImageToEvent(eventId, imageId: imageId);
  }
}
