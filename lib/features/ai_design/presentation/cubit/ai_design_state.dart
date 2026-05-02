import 'package:equatable/equatable.dart';
import '../../data/models/ai_form_field_model.dart';
import '../../data/models/ai_image_model.dart';

abstract class AiDesignState extends Equatable {
  const AiDesignState();
  @override
  List<Object?> get props => [];
}

class AiDesignInitial extends AiDesignState {
  const AiDesignInitial();
}

/// Loading gallery images or form fields
class AiDesignLoading extends AiDesignState {
  const AiDesignLoading();
}

/// Main idle state for Page 1
class AiDesignReady extends AiDesignState {
  final List<AiImageModel> galleryImages;
  final List<AiFormFieldModel> formFields;
  final int? selectedImageId;
  final String? selectedBasePrompt; // internal — never shown to user
  final String freeformPromptText;
  final Map<String, String> formValues;
  final String? customPrompt;
  final int activeTab; // 0 = gallery, 1 = freeform
  final bool isGenerating;
  final String? generationError;

  const AiDesignReady({
    required this.galleryImages,
    required this.formFields,
    this.selectedImageId,
    this.selectedBasePrompt,
    this.freeformPromptText = '',
    this.formValues = const {},
    this.customPrompt,
    this.activeTab = 0,
    this.isGenerating = false,
    this.generationError,
  });

  AiDesignReady copyWith({
    List<AiImageModel>? galleryImages,
    List<AiFormFieldModel>? formFields,
    int? selectedImageId,
    String? selectedBasePrompt,
    String? freeformPromptText,
    Map<String, String>? formValues,
    String? customPrompt,
    int? activeTab,
    bool? isGenerating,
    String? generationError,
    bool clearSelectedImage = false,
    bool clearFreeformPrompt = false,
    bool clearError = false,
  }) {
    return AiDesignReady(
      galleryImages:       galleryImages       ?? this.galleryImages,
      formFields:          formFields          ?? this.formFields,
      selectedImageId:     clearSelectedImage  ? null : (selectedImageId    ?? this.selectedImageId),
      selectedBasePrompt:  clearSelectedImage  ? null : (selectedBasePrompt ?? this.selectedBasePrompt),
      freeformPromptText:  clearFreeformPrompt ? ''   : (freeformPromptText ?? this.freeformPromptText),
      formValues:          formValues          ?? this.formValues,
      customPrompt:        customPrompt        ?? this.customPrompt,
      activeTab:           activeTab           ?? this.activeTab,
      isGenerating:        isGenerating        ?? this.isGenerating,
      generationError:     clearError          ? null : (generationError    ?? this.generationError),
    );
  }

  @override
  List<Object?> get props => [
    galleryImages, formFields,
    selectedImageId, selectedBasePrompt,
    freeformPromptText, formValues, customPrompt,
    activeTab, isGenerating, generationError,
  ];
}

/// Navigate to Page 2 — prompt ready for review
class AiPromptReady extends AiDesignState {
  final int imageId;
  final String promptText;
  const AiPromptReady({required this.imageId, required this.promptText});

  @override
  List<Object?> get props => [imageId, promptText];
}

/// Page 2 overlay — image is being generated
class AiImageGenerating extends AiDesignState {
  final int imageId;
  final String promptText;
  const AiImageGenerating({required this.imageId, required this.promptText});

  @override
  List<Object?> get props => [imageId, promptText];
}

/// Navigate to Page 3 — image ready
class AiImageCompleted extends AiDesignState {
  final int imageId;
  final String imageUrl;
  final String? provider;
  final String? model;
  const AiImageCompleted({
    required this.imageId,
    required this.imageUrl,
    this.provider,
    this.model,
  });

  @override
  List<Object?> get props => [imageId, imageUrl];
}

/// Error shown in-page (not a dialog)
class AiDesignError extends AiDesignState {
  final String message;
  const AiDesignError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Image saved to event — carries URL so Page 2 can show preview
class AiImageSaved extends AiDesignState {
  final String imageUrl;
  const AiImageSaved(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}
