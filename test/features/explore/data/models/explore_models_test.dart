import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/explore/data/models/occasion_group_model.dart';
import 'package:maktoob/features/explore/data/models/template_preview_model.dart';

void main() {
  group('OccasionGroupModel.listFromResponse', () {
    test('parses groups with nested event types', () {
      final groups = OccasionGroupModel.listFromResponse({
        'event_types': [],
        'groups': [
          {
            'id': 1,
            'slug': 'weddings',
            'name_ar': 'أفراح',
            'name_en': 'Weddings',
            'event_types': [
              {'id': 10, 'slug': 'wedding', 'name_ar': 'زفاف', 'name_en': 'Wedding'},
              {'id': '11', 'slug': 'henna', 'name_ar': 'حنّة', 'name_en': null},
            ],
          },
        ],
      });

      expect(groups, hasLength(1));
      expect(groups.first.slug, 'weddings');
      expect(groups.first.localizedName('ar'), 'أفراح');
      expect(groups.first.localizedName('en'), 'Weddings');
      expect(groups.first.types.map((t) => t.id), [10, 11]);
      // Missing English name falls back to Arabic.
      expect(groups.first.types[1].localizedName('en'), 'حنّة');
    });

    test('drops empty groups and tolerates a data wrapper / bad shapes', () {
      expect(OccasionGroupModel.listFromResponse(null), isEmpty);
      expect(OccasionGroupModel.listFromResponse({'event_types': []}), isEmpty);
      final groups = OccasionGroupModel.listFromResponse({
        'data': {
          'groups': [
            {'id': 2, 'slug': 'empty', 'name_ar': 'فارغة', 'event_types': []},
            {
              'id': 3,
              'slug': 'births',
              'name_ar': 'مواليد',
              'event_types': [
                {'id': 5, 'name_ar': 'عقيقة'},
              ],
            },
          ],
        },
      });
      expect(groups.map((g) => g.id), [3]);
    });
  });

  group('TemplatePreviewModel.listFromResponse', () {
    test('parses the ApiResponse envelope', () {
      final templates = TemplatePreviewModel.listFromResponse({
        'success': true,
        'data': {
          'templates': [
            {
              'id': 7,
              'title': 'زفاف ذهبي',
              'image_url': 'https://cdn.test/a.png',
              'thumbnail_url': 'https://cdn.test/a_thumb.png',
              'event_type_id': 10,
            },
            {'id': 8, 'title': '', 'image_url': 'https://cdn.test/b.png'},
            {'id': 9, 'image_url': ''},
          ],
          'is_fallback': false,
        },
      });

      expect(templates, hasLength(2));
      expect(templates.first.title, 'زفاف ذهبي');
      expect(templates.first.thumbnailUrl, 'https://cdn.test/a_thumb.png');
      expect(templates.first.eventTypeId, 10);
      // Empty title becomes null; missing thumbnail falls back to the image.
      expect(templates[1].title, isNull);
      expect(templates[1].thumbnailUrl, 'https://cdn.test/b.png');
      expect(templates[1].eventTypeId, isNull);
    });

    test('returns empty on unexpected shapes', () {
      expect(TemplatePreviewModel.listFromResponse('oops'), isEmpty);
      expect(TemplatePreviewModel.listFromResponse({'data': null}), isEmpty);
    });
  });

  test('a server without groups still shows its types as one group', () {
    final groups = OccasionGroupModel.listFromResponse({
      'event_types': [
        {'id': 1, 'slug': 'wedding', 'name_ar': 'زفاف', 'name_en': 'Wedding'},
        {'id': 4, 'slug': 'graduation', 'name_ar': 'تخرج', 'name_en': 'Graduation'},
      ],
    });

    expect(groups, hasLength(1));
    expect(groups.single.slug, 'all');
    expect(groups.single.types.map((t) => t.slug), ['wedding', 'graduation']);
  });

  test('nothing at all gives an empty list (the screen shows retry)', () {
    expect(OccasionGroupModel.listFromResponse({'event_types': []}), isEmpty);
  });
}
