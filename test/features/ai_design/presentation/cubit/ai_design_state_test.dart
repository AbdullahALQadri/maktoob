import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/ai_design/data/models/ai_image_model.dart';
import 'package:maktoob/features/ai_design/presentation/cubit/ai_design_state.dart';

void main() {
  const galleryImages = [
    AiImageModel(id: 1, title: 'Kinetic', imageUrl: 'a', prompt: ''),
    AiImageModel(id: 2, title: 'Minimal', imageUrl: 'b', prompt: ''),
  ];

  group('AiDesignReady.copyWith', () {
    test('selectedMoodTags can be replaced with a new list', () {
      const initial = AiDesignReady(
        galleryImages: galleryImages,
        formFields: [],
      );

      final next = initial.copyWith(selectedMoodTags: const ['formal']);

      expect(initial.selectedMoodTags, isEmpty);
      expect(next.selectedMoodTags, ['formal']);
    });

    test('selectedMoodTags persists through unrelated copyWith calls', () {
      const initial = AiDesignReady(
        galleryImages: galleryImages,
        formFields: [],
        selectedMoodTags: ['festive'],
      );

      final next = initial.copyWith(activeTab: 1);

      expect(next.selectedMoodTags, ['festive']);
      expect(next.activeTab, 1);
    });
  });

  group('AiDesignReady.selectedImageTitle', () {
    test('returns the matching image title when an id is selected', () {
      const state = AiDesignReady(
        galleryImages: galleryImages,
        formFields: [],
        selectedImageId: 2,
      );
      expect(state.selectedImageTitle, 'Minimal');
    });

    test('is null when no image is selected', () {
      const state = AiDesignReady(galleryImages: galleryImages, formFields: []);
      expect(state.selectedImageTitle, isNull);
    });

    test('is null when the selected id is not in the gallery', () {
      const state = AiDesignReady(
        galleryImages: galleryImages,
        formFields: [],
        selectedImageId: 999,
      );
      expect(state.selectedImageTitle, isNull);
    });
  });

  group('AiPromptReady props', () {
    test('carries prompt_version + suggestions + style title', () {
      const state = AiPromptReady(
        imageId: 1,
        promptText: 'p',
        promptVersion: '1.3',
        styleTitle: 'Kinetic',
      );
      expect(state.promptVersion, '1.3');
      expect(state.styleTitle, 'Kinetic');
    });
  });
}
