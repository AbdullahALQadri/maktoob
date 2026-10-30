// Layout sweep: every screen at phone, large-phone, tablet sizes and with
// enlarged system text, collecting Flutter overflow errors.
//
// Opt-in, because it needs recorded API responses (real data from a local
// backend): LAYOUT_FIXTURES=/path/to/fixtures.json flutter test test/layout
// The fixtures map an API path to {status, body}.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/config/routes/app_routes.dart';
import 'package:maktoob/config/themes/app_theme.dart';
import 'package:maktoob/core/api/api_consumer.dart';
import 'package:maktoob/core/error/exceptions.dart';
import 'package:maktoob/core/network/network_info.dart';
import 'package:maktoob/core/services/fcm_service.dart';
import 'package:maktoob/core/widgets/scaffold/app_content_width.dart';
import 'package:maktoob/features/ai_design/data/repositories/ai_design_repository.dart';
import 'package:maktoob/features/ai_design/presentation/cubit/ai_design_cubit.dart';
import 'package:maktoob/features/ai_design/presentation/pages/ai_design_page.dart';
import 'package:maktoob/features/ai_design/presentation/pages/image_result_page.dart';
import 'package:maktoob/features/ai_design/presentation/pages/prompt_review_page.dart';
import 'package:maktoob/features/authentication/domain/entities/user_entity.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:maktoob/features/authentication/presentation/screens/forgot_password_otp_screen.dart';
import 'package:maktoob/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:maktoob/features/authentication/presentation/screens/login_screen.dart';
import 'package:maktoob/features/authentication/presentation/screens/register_screen.dart';
import 'package:maktoob/features/authentication/presentation/screens/reset_password_screen.dart';
import 'package:maktoob/features/authentication/presentation/screens/terms_acceptance_screen.dart';
import 'package:maktoob/features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'package:maktoob/features/events/presentation/cubit/events_list/events_list_cubit.dart';
import 'package:maktoob/features/events/presentation/screens/event_details_screen.dart';
import 'package:maktoob/features/explore/presentation/screens/explore_screen.dart';
import 'package:maktoob/features/home/presentation/cubit/home_cubit.dart';
import 'package:maktoob/features/home/presentation/screens/home_screen.dart';
import 'package:maktoob/features/institution/presentation/cubit/institution_cubit.dart';
import 'package:maktoob/features/institution/presentation/screens/institution_credits_screen.dart';
import 'package:maktoob/features/institution/presentation/screens/institution_profile_form_screen.dart';
import 'package:maktoob/features/institution/presentation/screens/institution_screen.dart';
import 'package:maktoob/features/institution/presentation/screens/institution_team_screen.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';
import 'package:maktoob/features/invitation/presentation/screens/invitation_wizard_screen.dart';
import 'package:maktoob/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:maktoob/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:maktoob/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:maktoob/features/payment/presentation/screens/payment_upload_screen.dart';
import 'package:maktoob/features/scanner/presentation/cubit/scanner_cubit.dart';
import 'package:maktoob/features/scanner/presentation/screens/scanner_events_screen.dart';
import 'package:maktoob/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:maktoob/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:maktoob/features/settings/presentation/screens/change_password_screen.dart';
import 'package:maktoob/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:maktoob/features/settings/presentation/screens/profile_screen.dart';
import 'package:maktoob/features/settings/presentation/screens/settings_screen.dart';
import 'package:maktoob/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

const _longArabic =
    'حفل زفاف عائلة الاختبار الطويل جداً للتأكد من التفاف النص في كل مكان';

/// Serves recorded responses; writes succeed with an empty body.
class _FixtureApi implements ApiConsumer {
  _FixtureApi(this.fixtures);
  final Map<String, dynamic> fixtures;
  final misses = <String>{};

  dynamic _serve(String path, Map<String, dynamic>? query) {
    final withQuery = query == null || query.isEmpty
        ? path
        : '$path?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final hit = fixtures[withQuery] ?? fixtures[path];
    if (hit == null) {
      misses.add(withQuery);
      return {'success': true, 'data': <dynamic>[]};
    }
    final status = hit['status'] as int;
    final body = hit['body'];
    if (status >= 400) {
      final message = body is Map ? body['message']?.toString() : null;
      if (status == 404) throw NotFoundException(message: message);
      throw ServerException(message: message);
    }
    return jsonDecode(jsonEncode(body));
  }

  /// LAYOUT_LOADING=1: requests never answer, so screens stay on skeletons.
  final bool stall = Platform.environment['LAYOUT_LOADING'] == '1';

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) =>
      stall
      ? Completer<dynamic>().future
      : Future.value(_serve(path, queryParameters));

  dynamic _ok() => {'success': true, 'data': <String, dynamic>{}};

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async => _ok();
  @override
  Future<dynamic> postWithImage(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    dynamic params,
  }) async => _ok();
  @override
  Future<dynamic> postCreateService(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    dynamic params,
  }) async => _ok();
  @override
  Future<dynamic> postRegister(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    dynamic params,
  }) async => _ok();
  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async => _ok();
  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async => _ok();
}

class _Online implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Viewport {
  const _Viewport(this.name, this.size, {this.textScale = 1.0});
  final String name;
  final Size size;
  final double textScale;
}

const _viewports = [
  _Viewport('320x568', Size(320, 568)),
  _Viewport('360x740', Size(360, 740)),
  _Viewport('412x915', Size(412, 915)),
  _Viewport('768x1024', Size(768, 1024)),
  _Viewport('1024x768', Size(1024, 768)),
  _Viewport('360x740@1.3', Size(360, 740), textScale: 1.3),
];

typedef _Screen = Widget Function();

Widget _ai(Widget page) => BlocProvider(
  create: (_) => AiDesignCubit(
    repository: di.sl<AiDesignRepository>(),
    fcmService: di.sl<FcmService>(),
    eventId: 25,
    eventTypeId: 1,
    initialEventTitle: _longArabic,
  ),
  child: page,
);

void main() {
  final fixturesPath = Platform.environment['LAYOUT_FIXTURES'];
  if (fixturesPath == null || !File(fixturesPath).existsSync()) {
    test('layout sweep (set LAYOUT_FIXTURES to run)', () {}, skip: true);
    return;
  }
  final fixtures =
      jsonDecode(File(fixturesPath).readAsStringSync()) as Map<String, dynamic>;
  late _FixtureApi api;
  late UserEntity user;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final tmp = Directory.systemTemp.createTempSync('mk_layout');
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tmp.path,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async {
        final key = (call.arguments as Map?)?['key'];
        return switch (call.method) {
          'read' => key == 'auth_token' ? 'layout-test-token' : null,
          'readAll' => <String, String>{'auth_token': 'layout-test-token'},
          'containsKey' => key == 'auth_token',
          _ => null,
        };
      },
    );
    SharedPreferences.setMockInitialValues({});

    // Real Tajawal: the test default font draws every glyph 1em wide, which
    // makes Arabic text far wider than on a device and invents overflows.
    final tajawal = FontLoader('Tajawal');
    for (final w in ['Light', 'Regular', 'Medium', 'Bold', 'ExtraBold']) {
      tajawal.addFont(rootBundle.load('assets/fonts/Tajawal-$w.ttf'));
    }
    await tajawal.load();

    await di.sl.reset();
    await di.init(pushAvailable: false);
    api = _FixtureApi(fixtures);
    di.sl
      ..unregister<ApiConsumer>()
      ..registerLazySingleton<ApiConsumer>(() => api)
      ..unregister<NetworkInfo>()
      ..registerLazySingleton<NetworkInfo>(() => _Online());

    final profile = fixtures['/auth/profile']['body'] as Map<String, dynamic>;
    final c =
        (profile['client'] ?? profile['data']?['client'] ?? profile['data'])
            as Map<String, dynamic>;
    user = UserEntity(
      id: c['id'] as int,
      name: c['name'] as String,
      email: (c['email'] ?? '') as String,
    );
  });

  final screens = <String, _Screen>{
    'login': () => const LoginScreen(),
    'register': () => const RegisterScreen(),
    'forgot_password': () => const ForgotPasswordScreen(),
    'forgot_password_otp': () => ForgotPasswordOtpScreen(
      phone: '+970599123456',
      onBack: () {},
      onVerified: (_) {},
    ),
    'reset_password': () => ResetPasswordScreen(
      phone: '+970599123456',
      code: '123456',
      onBack: () {},
      onSuccess: () {},
    ),
    'terms_acceptance': () => const TermsAcceptanceScreen(),
    'explore': () => ExploreScreen(onStartTap: () {}, onLoginTap: () {}),
    'home': () => const HomeScreen(),
    'event_details_active': () =>
        EventDetailsScreen(eventId: '27', onBack: () {}),
    'event_details_draft': () =>
        EventDetailsScreen(eventId: '25', onBack: () {}),
    'event_details_pending': () =>
        EventDetailsScreen(eventId: '26', onBack: () {}),
    'notifications': () => BlocProvider(
      create: (_) => di.sl<NotificationsCubit>()..load(),
      child: const NotificationsScreen(),
    ),
    'scanner_events': () => const ScannerEventsScreen(),
    'payment_upload': () => BlocProvider<PaymentCubit>(
      create: (_) => di.sl<PaymentCubit>(),
      child: const PaymentUploadScreen(
        eventId: '26',
        amount: 1250,
        eventTitle: _longArabic,
      ),
    ),
    'wizard_new': () => const InvitationWizardScreen(),
    'wizard_draft': () => const InvitationWizardScreen(draftEventId: 25),
    // Same cubits the app's routes / parent screens provide.
    'ai_design': () => _ai(
      const AiDesignPage(eventId: 25, eventTypeId: 1, eventTitle: _longArabic),
    ),
    'prompt_review': () => _ai(
      const PromptReviewPage(
        imageId: 1,
        promptText: '$_longArabic $_longArabic $_longArabic',
      ),
    ),
    'image_result': () => _ai(
      const ImageResultPage(imageId: 1, imageUrl: '', styleTitle: _longArabic),
    ),
    'institution': () => BlocProvider(
      create: (_) => di.sl<InstitutionCubit>()..load(),
      child: const InstitutionScreen(),
    ),
    'institution_form': () => BlocProvider(
      create: (_) => di.sl<InstitutionCubit>(),
      child: const InstitutionProfileFormScreen(),
    ),
    'institution_team': () => BlocProvider(
      create: (_) => di.sl<InstitutionTeamCubit>()..load(),
      child: const InstitutionTeamScreen(),
    ),
    'institution_credits': () => BlocProvider(
      create: (_) => di.sl<InstitutionCreditsCubit>()..load(),
      child: const InstitutionCreditsScreen(),
    ),
    'profile': () => BlocProvider(
      create: (_) => di.sl<ProfileCubit>(),
      child: const ProfileScreen(),
    ),
    'edit_profile': () => BlocProvider(
      create: (_) => di.sl<ProfileCubit>(),
      child: EditProfileScreen(user: user),
    ),
    'change_password': () => const ChangePasswordScreen(phone: '+970599123456'),
    'change_password_forced': () =>
        const ChangePasswordScreen(phone: '+970599123456', forced: true),
    'settings': () => const SettingsScreen(),
  };

  Widget shell(Widget screen) => MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(create: (_) => di.sl<SettingsCubit>()),
      // A fresh one per screen: the app's singleton is closed with the
      // first screen's provider and would refuse new states afterwards.
      BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(authRepository: di.sl())..checkAuthStatus(),
      ),
      BlocProvider<HomeCubit>(create: (_) => di.sl<HomeCubit>()),
      BlocProvider<EventsListCubit>(create: (_) => di.sl<EventsListCubit>()),
      BlocProvider<EventDetailsCubit>(
        create: (_) => di.sl<EventDetailsCubit>(),
      ),
      BlocProvider<ScannerCubit>(create: (_) => di.sl<ScannerCubit>()),
      BlocProvider<PaymentCubit>(create: (_) => di.sl<PaymentCubit>()),
      BlocProvider<InvitationCubit>(create: (_) => di.sl<InvitationCubit>()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Same builder chain as app.dart (minus the network banner).
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: AppContentWidth(child: child!),
      ),
      home: screen,
    ),
  );

  final report = <String>[];
  tearDownAll(() {
    final out = File(
      Platform.environment['LAYOUT_REPORT'] ?? 'layout_report.txt',
    );
    out.writeAsStringSync(
      '${report.join('\n')}\n\nAPI paths with no fixture:\n${api.misses.join('\n')}\n',
    );
  });

  for (final entry in screens.entries) {
    for (final vp in _viewports) {
      testWidgets('${entry.key} @ ${vp.name}', (tester) async {
        tester.view.physicalSize = vp.size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = vp.textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final problems = <String>[];
        final original = FlutterError.onError;
        FlutterError.onError = (details) {
          final text = details.toString();
          // A request finishing after the harness closed the screen.
          if (text.contains('Cannot emit new states after calling close')) {
            return;
          }
          final where = RegExp(r'(lib/[\w/]+\.dart):(\d+)').firstMatch(text);
          final head = details.exceptionAsString().split('\n').first;
          problems.add(
            '$head${where != null ? '  <- ${where.group(1)}:${where.group(2)}' : ''}',
          );
        };
        try {
          await tester.runAsync(() async {
            await tester.pumpWidget(shell(entry.value()));
            await Future<void>.delayed(const Duration(milliseconds: 400));
          });
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 300));
          }
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 200)),
          );
          await tester.pump(const Duration(milliseconds: 300));
          final pending = tester.takeException();
          if (pending != null) {
            problems.add('exception: ${pending.toString().split('\n').first}');
          }
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds: 20));
        } finally {
          FlutterError.onError = original;
        }

        final unique = problems.toSet().toList();
        report.add(
          '${unique.isEmpty ? 'OK  ' : 'FAIL'} ${entry.key} @ ${vp.name}'
          '${unique.map((p) => '\n       $p').join()}',
        );
      });
    }
  }
}
