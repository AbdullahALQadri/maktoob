import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/features/authentication/domain/repositories/auth_repository.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_state.dart';
import 'package:maktoob/features/authentication/presentation/screens/login_screen.dart';
import 'package:maktoob/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:maktoob/features/explore/domain/entities/occasion_group_entity.dart';
import 'package:maktoob/features/explore/domain/entities/template_preview_entity.dart';
import 'package:maktoob/features/explore/domain/repositories/explore_repository.dart';
import 'package:maktoob/features/explore/domain/usecases/get_occasion_groups_usecase.dart';
import 'package:maktoob/features/explore/domain/usecases/get_public_templates_usecase.dart';
import 'package:maktoob/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:maktoob/features/explore/presentation/screens/explore_screen.dart';
import 'package:maktoob/injection_container.dart' as di;

class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SignedOutAuthCubit extends AuthCubit {
  _SignedOutAuthCubit() : super(authRepository: _UnusedAuthRepository()) {
    emit(const AuthUnauthenticated());
  }
}

class _FakeExploreRepository implements ExploreRepository {
  @override
  Future<Either<Failure, List<OccasionGroupEntity>>> getOccasionGroups() async =>
      const Right([
        OccasionGroupEntity(
          id: 1,
          slug: 'weddings',
          nameAr: 'أفراح',
          nameEn: 'Weddings',
          types: [
            OccasionTypeEntity(id: 10, slug: 'wedding', nameAr: 'زفاف', nameEn: 'Wedding'),
          ],
        ),
      ]);

  @override
  Future<Either<Failure, List<TemplatePreviewEntity>>> getTemplates({
    int? eventTypeId,
  }) async =>
      const Right([]);
}

void main() {
  setUp(() async {
    await di.sl.reset();
    final repo = _FakeExploreRepository();
    di.sl.registerFactory<ExploreCubit>(
      () => ExploreCubit(
        getOccasionGroupsUseCase: GetOccasionGroupsUseCase(repo),
        getPublicTemplatesUseCase: GetPublicTemplatesUseCase(repo),
      ),
    );
  });

  tearDown(() => di.sl.reset());

  Widget app(AuthCubit cubit) => BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: AuthWrapper(skipSplash: true),
        ),
      );

  // The lang JSON is large enough that rootBundle decodes it off the fake
  // clock, so let real async work finish before settling.
  Future<void> pumpApp(WidgetTester tester, AuthCubit cubit) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(app(cubit));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('signed-out users land on the explore home, not login',
      (tester) async {
    final cubit = _SignedOutAuthCubit();
    await pumpApp(tester, cubit);

    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('ابدأ دعوتك مجاناً'), findsOneWidget);
    expect(find.text('أفراح'), findsOneWidget);
    expect(find.text('زفاف'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('"I have an account" opens login, "browse first" returns',
      (tester) async {
    final cubit = _SignedOutAuthCubit();
    await pumpApp(tester, cubit);

    await tester.tap(find.text('عندي حساب — تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.ensureVisible(find.text('تصفّح أولاً'));
    await tester.tap(find.text('تصفّح أولاً'));
    await tester.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);

    await cubit.close();
  });
}
