import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_state.dart';

void main() {
  group('EventTypeModel / EventTypeGroupModel', () {
    test('parses group_id and is_custom from the event-types payload', () {
      final t = EventTypeModel.fromJson({
        'id': 3,
        'slug': 'wedding',
        'name_ar': 'زفاف',
        'name_en': 'Wedding',
        'group_id': '1',
        'is_custom': 0,
      });
      expect(t.groupId, 1);
      expect(t.isClientCustom, isFalse);
      expect(t.nameAr, 'زفاف');

      final custom = EventTypeModel.fromJson({
        'id': 99,
        'name_ar': 'حفلة الحي',
        'group_id': null,
        'is_custom': true,
      });
      expect(custom.groupId, isNull);
      expect(custom.isClientCustom, isTrue);
      expect(custom.name, 'حفلة الحي');
    });

    test('parses a group', () {
      final g = EventTypeGroupModel.fromJson({
        'id': 6,
        'slug': 'other',
        'name_ar': 'أخرى',
        'name_en': 'Other',
        'icon': 'fa-star',
        'color': '#999',
      });
      expect(g.id, 6);
      expect(g.isOther, isTrue);
      expect(g.nameEn, 'Other');
    });
  });

  group('EventTypeFormField', () {
    test('parses backend field shape with option maps', () {
      final f = EventTypeFormField.fromJson({
        'field_key': 'hall_type',
        'label_ar': 'نوع القاعة',
        'label_en': 'Hall type',
        'placeholder_ar': 'اختر',
        'placeholder_en': 'Choose',
        'field_type': 'select',
        'options': [
          {'value': 'indoor', 'label_ar': 'داخلية', 'label_en': 'Indoor'},
          'outdoor',
        ],
        'is_required': 1,
        'sort_order': 2,
      });
      expect(f.key, 'hall_type');
      expect(f.type, 'select');
      expect(f.isRequired, isTrue);
      expect(f.localizedLabel(false), 'نوع القاعة');
      expect(f.localizedLabel(true), 'Hall type');
      expect(f.localizedHint(false), 'اختر');
      expect(f.options.length, 2);
      expect(f.options.first.labelAr, 'داخلية');
      expect(f.options.last.value, 'outdoor');
      expect(f.sortOrder, 2);
    });

    test('listFromJson drops keyless fields and sorts by sort_order', () {
      final list = EventTypeFormField.listFromJson([
        {'field_key': 'b', 'label_ar': 'ب', 'sort_order': 2},
        {'label_ar': 'no key'},
        {'field_key': 'a', 'label_ar': 'أ', 'sort_order': 1},
      ]);
      expect(list.map((f) => f.key), ['a', 'b']);
      expect(list.first.type, 'text');
      expect(list.first.isRequired, isFalse);
      expect(EventTypeFormField.listFromJson(null), isEmpty);
    });
  });

  test('missingRequiredFormFields tracks required values through the cubit', () {
    final cubit = InvitationCubit();
    cubit.setEventTypeFormFields(const [
      EventTypeFormField(key: 'groom_name', label: 'Groom', labelAr: 'العريس', type: 'text', isRequired: true),
      EventTypeFormField(key: 'note', label: 'Note', labelAr: 'ملاحظة', type: 'textarea'),
    ]);
    expect(cubit.state.missingRequiredFormFields.map((f) => f.key), ['groom_name']);

    cubit.updateEventTypeFormField('groom_name', '   ');
    expect(cubit.state.missingRequiredFormFields, isNotEmpty);

    cubit.updateEventTypeFormField('groom_name', 'أحمد');
    expect(cubit.state.missingRequiredFormFields, isEmpty);
    expect(cubit.state.eventTypeFormData, {'groom_name': 'أحمد'});
    cubit.close();
  });
}
