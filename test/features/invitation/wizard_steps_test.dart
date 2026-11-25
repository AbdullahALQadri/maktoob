import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/api/api_consumer.dart';
import 'package:maktoob/core/api/event_wizard_api_service.dart';
import 'package:maktoob/features/invitation/data/repositories/event_wizard_repository_impl.dart';
import 'package:maktoob/features/invitation/data/models/invitation_draft_model.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_state.dart';
import 'package:maktoob/features/invitation/presentation/screens/steps/checkout_step.dart';
import 'package:maktoob/features/invitation/presentation/screens/steps/design_step.dart';
import 'package:maktoob/features/invitation/presentation/screens/steps/details_step.dart';
import 'package:maktoob/features/invitation/presentation/screens/steps/guests_step.dart';
import 'package:maktoob/features/invitation/presentation/screens/steps/settings_step.dart';
import 'package:maktoob/features/invitation/presentation/widgets/wizard_step_bar.dart';

/// Records every call with its body and answers like the wizard API.
class _FakeApi implements ApiConsumer {
  final calls = <String>[];
  final bodies = <String, Map<String, dynamic>?>{};

  dynamic _call(String method, String path, [Map<String, dynamic>? body]) {
    calls.add('$method $path');
    bodies['$method $path'] = body;
    if (path.endsWith('/state')) {
      return {
        'data': {
          'event': {
            'id': 9,
            'title': 'زفاف أحمد وليلى',
            'event_date': '2027-05-01 19:00:00',
            'default_delivery_method': 'email',
            'require_response': false,
            'final_ai_image': {'image_url': 'https://example.test/design.png'},
          },
        },
      };
    }
    if (path.endsWith('/services') && method == 'GET') return {'data': {'services': []}};
    if (path.endsWith('/packages')) return {'data': {'packages': []}};
    return {'data': {'event_id': 9, 'event_types': []}};
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async => _call('GET', path);

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async =>
      _call('POST', path, body);

  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async =>
      _call('PUT', path, body);

  @override
  Future<dynamic> delete(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async =>
      _call('DELETE', path, body);

  @override
  Future<dynamic> postWithImage(String path,
          {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async =>
      _call('POST', path, body);

  @override
  Future<dynamic> postCreateService(String path,
          {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async =>
      _call('POST', path, body);

  @override
  Future<dynamic> postRegister(String path,
          {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async =>
      _call('POST', path, body);
}

InvitationCubit _cubit(_FakeApi api) => InvitationCubit(repository: EventWizardRepositoryImpl(EventWizardApiService(apiConsumer: api)));

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('phone, very large text', Size(390, 844), 2.0),
  ('tablet', Size(768, 1024), 1.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  group('the five screens, saved one by one', () {
    test('each step saves its own part, then moves on', () async {
      final api = _FakeApi();
      final cubit = _cubit(api);
      expect(cubit.state.currentStep, InvitationStep.details);

      cubit.updateEventDescription('يسعدنا حضوركم');
      await cubit.createDraftAndSaveDetails();
      expect(cubit.state.currentStep, InvitationStep.guests);
      expect(api.bodies['PUT /event-wizard/9/details']?['description'], 'يسعدنا حضوركم');

      cubit.addManualGuest(const GuestInfoModel(name: 'سارة', phone: '0599123456'));
      await cubit.saveGuestsAndProceed();
      expect(cubit.state.currentStep, InvitationStep.design);
      expect((api.bodies['POST /event-wizard/9/guests/manual']?['guests'] as List).length, 1);

      cubit.nextStep();
      cubit
        ..setDeliveryMethod('email')
        ..setRequireResponse(false)
        ..updatePartnerWithGuests(2);
      await cubit.saveSettingsAndProceed();
      expect(cubit.state.currentStep, InvitationStep.checkout);
      final config = api.bodies['PUT /event-wizard/9/invitation-config']!;
      expect(config['default_delivery_method'], 'email');
      expect(config['require_response'], false);
      expect(config['max_companions'], 2);

      cubit.nextStep(); // the last screen: nowhere further
      expect(cubit.state.currentStep, InvitationStep.checkout);
      cubit.previousStep();
      expect(cubit.state.currentStep, InvitationStep.settings);
    });

    test('a resumed draft brings back its design and its settings', () async {
      final cubit = _cubit(_FakeApi());
      await cubit.initializeWizard(draftEventId: 9);
      expect(cubit.state.generatedImageUrl, 'https://example.test/design.png');
      expect(cubit.state.deliveryMethod, 'email');
      expect(cubit.state.requireResponse, false);
    });

    test('a failed save keeps the host on the step and reports it', () async {
      final cubit = InvitationCubit(repository: EventWizardRepositoryImpl(EventWizardApiService(apiConsumer: _Failing())));
      cubit.emit(cubit.state.copyWith(draftEventId: 9, currentStep: InvitationStep.guests));
      await cubit.saveGuestsAndProceed();
      expect(cubit.state.currentStep, InvitationStep.guests);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('layout', () {
    final steps = <InvitationStep, Widget Function()>{
      InvitationStep.details: () => const DetailsStep(),
      InvitationStep.guests: () => const GuestsStep(),
      InvitationStep.design: () => const DesignStep(),
      InvitationStep.settings: () => const SettingsStep(),
      InvitationStep.checkout: () => const CheckoutStep(),
    };

    for (final locale in const [Locale('ar'), Locale('en')]) {
      for (final (name, size, textScale) in _viewports) {
        for (final entry in steps.entries) {
          testWidgets('${locale.languageCode}: ${entry.key.name}, $name', (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = textScale;
            addTearDown(tester.view.reset);
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

            final cubit = _cubit(_FakeApi());
            addTearDown(cubit.close);
            cubit.emit(cubit.state.copyWith(draftEventId: 9, currentStep: entry.key));

            await tester.runAsync(() async {
              await tester.pumpWidget(MaterialApp(
                locale: locale,
                supportedLocales: AppLocalizationsSetup.supportedLocales,
                localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
                home: BlocProvider.value(value: cubit, child: entry.value()),
              ));
              await Future<void>.delayed(const Duration(milliseconds: 200));
            });
            await tester.pump(const Duration(milliseconds: 300));

            expect(tester.takeException(), isNull);
            expect(find.byType(WizardStepBar), findsOneWidget);
          });
        }
      }
    }
  });
}

class _Failing extends _FakeApi {
  @override
  dynamic _call(String method, String path, [Map<String, dynamic>? body]) => throw Exception('offline');
}
