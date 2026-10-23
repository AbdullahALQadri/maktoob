import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/api/api_consumer.dart';
import 'package:maktoob/core/api/dio_consumer.dart';
import 'package:maktoob/core/api/event_wizard_api_service.dart';
import 'package:maktoob/core/error/exceptions.dart';
import 'package:maktoob/core/error/free_trial_refusal.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_state.dart';

typedef _Handler = dynamic Function(String method, String path);

/// Answers every call through [handler]; throws whatever it throws.
class _FakeApi implements ApiConsumer {
  final _Handler handler;
  final calls = <String>[];

  _FakeApi(this.handler);

  dynamic _call(String method, String path) {
    calls.add('$method $path');
    return handler(method, path);
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async => _call('GET', path);

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async =>
      _call('POST', path);

  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async =>
      _call('PUT', path);

  @override
  Future<dynamic> delete(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async =>
      _call('DELETE', path);

  @override
  Future<dynamic> postWithImage(String path,
          {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async =>
      _call('POST', path);

  @override
  Future<dynamic> postCreateService(String path,
          {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async =>
      _call('POST', path);

  @override
  Future<dynamic> postRegister(String path,
          {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async =>
      _call('POST', path);
}

const _freeTrialAr = 'استخدمت تجربتك المجانية من قبل على هذا الرقم. اختر باقة للمتابعة.';

final _eventTypes = {
  'data': {
    'event_types': [
      {'id': 3, 'slug': 'wedding', 'name_ar': 'زفاف', 'name_en': 'Wedding', 'group_id': 1},
      {'id': 5, 'slug': 'graduation', 'name_ar': 'تخرج', 'name_en': 'Graduation', 'group_id': 2},
    ],
  },
};

final _fields = {
  'data': {
    'fields': [
      {'field_key': 'hall_type', 'label_ar': 'نوع القاعة', 'label_en': 'Hall type', 'field_type': 'text'},
    ],
  },
};

InvitationCubit _cubit(_FakeApi api) =>
    InvitationCubit(apiService: EventWizardApiService(apiConsumer: api));

/// Wizard save with a free package that fails at the final `save` step.
Future<InvitationCubit> _saveFailingWith(Object error) async {
  final api = _FakeApi((method, path) {
    if (path.endsWith('/save')) throw error;
    return {'data': {'event_id': 9}};
  });
  final cubit = _cubit(api);
  cubit.selectPackage(const PackageModel(id: 1, name: 'Free', nameAr: 'مجانية', price: 0));
  await cubit.saveAndSend(openWhatsApp: false);
  return cubit;
}

void main() {
  group('free-trial refusal detection', () {
    test('matches only the 422 errors.status free-trial message or blocker', () {
      expect(isFreeTrialRefusal(const ValidationException(errors: {'status': [_freeTrialAr]})), isTrue);
      expect(
        isFreeTrialRefusal(const ValidationException(errors: {
          'status': ['This phone number has already used its free trial. Choose a package to continue.'],
        })),
        isTrue,
      );
      expect(isFreeTrialRefusal(const ValidationException(blockers: ['free_trial_used'])), isTrue);

      expect(
        isFreeTrialRefusal(const ValidationException(errors: {
          'status': ['A completed or cancelled event cannot be activated.'],
        })),
        isFalse,
      );
      expect(isFreeTrialRefusal(const ValidationException(errors: {'title': [_freeTrialAr]})), isFalse);
      expect(isFreeTrialRefusal(const FetchDataException()), isFalse);
      expect(isFreeTrialRefusal(Exception('boom')), isFalse);
    });

    test('DioConsumer parses Laravel errors into a typed map', () {
      expect(
        DioConsumer.parseValidationErrors({
          'status': [_freeTrialAr],
          'title': 'required',
        }),
        {
          'status': [_freeTrialAr],
          'title': ['required'],
        },
      );
      expect(DioConsumer.parseValidationErrors(null), isEmpty);
    });

    test('free package + free-trial 422 flags the "choose a package" dialog', () async {
      final cubit = await _saveFailingWith(
        const ValidationException(message: 'x', errors: {'status': [_freeTrialAr]}),
      );
      expect(cubit.state.saveErrorIsFreeTrial, isTrue);
      expect(cubit.state.saveError, _freeTrialAr);
      await cubit.close();
    });

    test('free package + other errors stay normal (retryable) errors', () async {
      for (final error in [
        const FetchDataException(),
        const ValidationException(errors: {
          'status': ['A completed or cancelled event cannot be activated.'],
        }),
      ]) {
        final cubit = await _saveFailingWith(error);
        expect(cubit.state.saveError, isNotNull);
        expect(cubit.state.saveErrorIsFreeTrial, isFalse, reason: '$error');
        expect(cubit.state.isSaving, isFalse);
        await cubit.close();
      }
    });
  });

  group('draft restore', () {
    test('restores event type, saved form values and loads the type fields', () async {
      final api = _FakeApi((method, path) {
        if (path == '/event-wizard/event-types') return _eventTypes;
        if (path == '/event-wizard/12/state') {
          return {
            'data': {
              'event': {
                'id': 12,
                'title': 'زفاف أحمد',
                'description': 'حفل',
                'event_type_id': 3,
                'event_type': {'id': 3, 'name_ar': 'زفاف', 'name_en': 'Wedding'},
                'event_type_form_values': {'hall_type': 'indoor'},
              },
            },
          };
        }
        if (path == '/event-wizard/ai-form-fields/3') return _fields;
        return {'data': {}};
      });
      final cubit = _cubit(api);

      await cubit.initializeWizard(draftEventId: 12);

      expect(cubit.state.draftEventId, 12);
      expect(cubit.state.eventName, 'زفاف أحمد');
      expect(cubit.state.selectedEventType?.id, 3);
      expect(cubit.state.eventTypeFormData, {'hall_type': 'indoor'});
      expect(cubit.state.eventTypeFormFields.map((f) => f.key), ['hall_type']);
      await cubit.close();
    });

    test('tolerates an empty form-values array and no event type', () async {
      final api = _FakeApi((method, path) {
        if (path == '/event-wizard/event-types') return _eventTypes;
        if (path == '/event-wizard/7/state') {
          return {
            'data': {
              'event': {'id': 7, 'title': 'x', 'event_type_id': null, 'event_type_form_values': []},
            },
          };
        }
        return {'data': {}};
      });
      final cubit = _cubit(api);

      await cubit.initializeWizard(draftEventId: 7);

      expect(cubit.state.selectedEventType, isNull);
      expect(cubit.state.eventTypeFormData, isEmpty);
      expect(cubit.state.errorMessage, isNull);
      await cubit.close();
    });
  });

  group('explore preselection', () {
    test('selects the occasion type and the tapped design', () async {
      final api = _FakeApi((method, path) {
        if (path == '/event-wizard/event-types') return _eventTypes;
        // Designs come from the public gallery (there is no wizard route).
        if (path == '/public/templates') {
          return {
            'data': {
              'templates': [
                {'id': 40, 'title': 'A'},
                {'id': 41, 'title': 'B'},
              ],
            },
          };
        }
        return {'data': {}};
      });
      final cubit = _cubit(api);
      await cubit.initializeWizard();

      await cubit.applyPreselection(eventTypeId: 5, templateId: 41);

      expect(cubit.state.selectedEventType?.id, 5);
      expect(cubit.state.selectedTemplate?.id, 41);
      await cubit.close();
    });

    test('ignores an unknown type', () async {
      final api = _FakeApi((method, path) => path == '/event-wizard/event-types' ? _eventTypes : {'data': {}});
      final cubit = _cubit(api);
      await cubit.initializeWizard();

      await cubit.applyPreselection(eventTypeId: 999, templateId: 1);

      expect(cubit.state.selectedEventType, isNull);
      await cubit.close();
    });
  });
}
