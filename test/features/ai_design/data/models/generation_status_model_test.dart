import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/ai_design/data/models/generation_status_model.dart';

void main() {
  group('GenerationStatusModel.fromJson', () {
    test('parses prompt_ready response with all new fields', () {
      final json = {
        'data': {
          'status': 'prompt_ready',
          'image_id': 42,
          'prompt_text': 'A luxurious wedding scene',
          'prompt_version': '2.4',
          'improvement_suggestions': [
            {'icon': 'palette', 'text': 'Add pastel colors'},
            {'icon': 'camera', 'text': 'Wider angle'},
          ],
        },
      };

      final result = GenerationStatusModel.fromJson(json);

      expect(result.isPromptReady, isTrue);
      expect(result.imageId, 42);
      expect(result.promptText, 'A luxurious wedding scene');
      expect(result.promptVersion, '2.4');
      expect(result.improvementSuggestions, hasLength(2));
      expect(result.improvementSuggestions.first.icon, 'palette');
      expect(result.improvementSuggestions.first.text, 'Add pastel colors');
      expect(result.generationTimeMs, isNull);
    });

    test('parses completed response with generation_time_ms', () {
      final json = {
        'data': {
          'status': 'completed',
          'image_id': 7,
          'image_url': 'https://example.com/img.png',
          'provider': 'openai',
          'model': 'DALL-E 3 Turbo',
          'generation_time_ms': 4200,
        },
      };

      final result = GenerationStatusModel.fromJson(json);

      expect(result.isCompleted, isTrue);
      expect(result.imageUrl, 'https://example.com/img.png');
      expect(result.provider, 'openai');
      expect(result.model, 'DALL-E 3 Turbo');
      expect(result.generationTimeMs, 4200);
    });

    test('defaults gracefully when new fields are absent', () {
      final json = {
        'data': {
          'status': 'prompt_ready',
          'image_id': 1,
          'prompt_text': 'X',
        },
      };

      final result = GenerationStatusModel.fromJson(json);

      // Backend rolling out can omit these — UI must not blow up.
      expect(result.promptVersion, isNull);
      expect(result.improvementSuggestions, isEmpty);
      expect(result.generationTimeMs, isNull);
    });

    test('accepts unwrapped payload (no data envelope)', () {
      // Some endpoints may return the payload at the top level.
      final result = GenerationStatusModel.fromJson({
        'status': 'failed',
        'image_id': 9,
        'error': 'timeout',
      });

      expect(result.isFailed, isTrue);
      expect(result.error, 'timeout');
    });

    test('skips malformed suggestion entries', () {
      final result = GenerationStatusModel.fromJson({
        'data': {
          'status': 'prompt_ready',
          'image_id': 1,
          'improvement_suggestions': [
            {'icon': 'palette', 'text': 'ok'},
            'not-a-map',
            42,
          ],
        },
      });

      expect(result.improvementSuggestions, hasLength(1));
      expect(result.improvementSuggestions.first.text, 'ok');
    });

    test('parses generation_time_ms from String or num', () {
      final fromInt = GenerationStatusModel.fromJson({
        'data': {'status': 'completed', 'image_id': 1, 'generation_time_ms': 3000},
      });
      final fromDouble = GenerationStatusModel.fromJson({
        'data': {'status': 'completed', 'image_id': 1, 'generation_time_ms': 3000.7},
      });

      expect(fromInt.generationTimeMs, 3000);
      expect(fromDouble.generationTimeMs, 3000);
    });
  });

  group('ImprovementSuggestion.fromJson', () {
    test('falls back to auto_awesome when icon missing', () {
      final s = ImprovementSuggestion.fromJson({'text': 'Add warmth'});
      expect(s.icon, 'auto_awesome');
      expect(s.text, 'Add warmth');
    });
  });
}
