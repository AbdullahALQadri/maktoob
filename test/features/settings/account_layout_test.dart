import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/widgets/page/page_kit.dart';
import 'package:maktoob/features/authentication/domain/entities/user_entity.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_state.dart';
import 'package:maktoob/features/identity/domain/entities/identity_entities.dart';
import 'package:maktoob/features/settings/presentation/cubit/profile_cubit.dart';
import 'package:maktoob/features/settings/presentation/cubit/profile_state.dart';
import 'package:maktoob/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:maktoob/features/settings/presentation/cubit/settings_state.dart';
import 'package:maktoob/features/settings/presentation/screens/change_password_screen.dart';
import 'package:maktoob/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:maktoob/features/settings/presentation/screens/profile_screen.dart';
import 'package:maktoob/features/settings/presentation/screens/settings_screen.dart';

const _user = UserEntity(
  id: 7,
  name: 'عبد الرحمن محمد عبد الله أبو شمالة',
  email: 'abdulrahman.abushamala@example-organization.org',
  phone: '+970599123456',
  companyName: 'جمعية النور الخيرية للتنمية المجتمعية',
  isVerified: true,
  userType: UserType.institution,
  identity: IdentityStateEntity(status: IdentityStatus.verified),
);

/// The session, as the screens read it: someone is signed in.
class _Auth extends Cubit<AuthState> implements AuthCubit {
  _Auth() : super(const AuthAuthenticated(_user));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Profile extends Cubit<ProfileState> implements ProfileCubit {
  _Profile() : super(const ProfileLoaded(user: _user));

  @override
  Future<void> loadProfile() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Settings extends Cubit<SettingsState> implements SettingsCubit {
  _Settings() : super(const SettingsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

const _viewports = <(String, Size, double)>[
  ('small phone', Size(320, 568), 1.0),
  ('phone, very large text', Size(390, 844), 2.0),
  ('tablet', Size(768, 1024), 1.0),
  ('desktop', Size(1280, 800), 1.0),
];

void main() {
  final screens = <String, Widget Function()>{
    'my account': () => const SettingsScreen(),
    'profile': () => const ProfileScreen(),
    'edit profile': () => const EditProfileScreen(user: _user),
    'change password': () => const ChangePasswordScreen(phone: '+970599123456'),
    'forced password': () => const ChangePasswordScreen(phone: '+970599123456', forced: true),
  };

  for (final locale in const [Locale('ar'), Locale('en')]) {
    for (final (name, size, textScale) in _viewports) {
      for (final entry in screens.entries) {
        for (final brightness in Brightness.values) {
          testWidgets('${locale.languageCode}, ${brightness.name}: ${entry.key}, $name', (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = textScale;
            addTearDown(tester.view.reset);
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

            final auth = _Auth();
            final profile = _Profile();
            final settings = _Settings();
            addTearDown(auth.close);
            addTearDown(profile.close);
            addTearDown(settings.close);

            await tester.runAsync(() async {
              await tester.pumpWidget(MultiBlocProvider(
                providers: [
                  BlocProvider<AuthCubit>.value(value: auth),
                  BlocProvider<ProfileCubit>.value(value: profile),
                  BlocProvider<SettingsCubit>.value(value: settings),
                ],
                child: MaterialApp(
                  locale: locale,
                  theme: ThemeData(brightness: brightness),
                  supportedLocales: AppLocalizationsSetup.supportedLocales,
                  localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
                  home: entry.value(),
                ),
              ));
              await Future<void>.delayed(const Duration(milliseconds: 200));
            });
            await tester.pump();

            expect(tester.takeException(), isNull);
            expect(find.byType(PageBody), findsOneWidget);
          });
        }
      }
    }
  }

  testWidgets('my account shows who is signed in and leads to every part of the account', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = _Auth();
    final settings = _Settings();
    addTearDown(auth.close);
    addTearDown(settings.close);

    await tester.runAsync(() async {
      await tester.pumpWidget(MultiBlocProvider(
        providers: [BlocProvider<AuthCubit>.value(value: auth), BlocProvider<SettingsCubit>.value(value: settings)],
        child: const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: SettingsScreen(),
        ),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(find.byKey(const Key('account_summary')), findsOneWidget);
    expect(find.text('+970599123456'), findsOneWidget);
    for (final key in ['settings_my_payments_tile', 'settings_guest_groups_tile', 'settings_institution_tile', 'settings_offline_queue_tile', 'language_ar', 'language_en']) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
  });
}
