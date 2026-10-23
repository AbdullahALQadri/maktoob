import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/config/locale/app_localizations_setup.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/core/services/pending_wizard_intent_service.dart';
import 'package:maktoob/features/authentication/domain/repositories/auth_repository.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:maktoob/features/authentication/presentation/cubit/auth_state.dart';
import 'package:maktoob/features/authentication/presentation/screens/login_screen.dart';
import 'package:maktoob/features/authentication/presentation/screens/register_screen.dart';
import 'package:maktoob/features/authentication/presentation/widgets/auth_wrapper.dart';
import 'package:maktoob/features/explore/domain/entities/occasion_group_entity.dart';
import 'package:maktoob/features/explore/domain/entities/template_preview_entity.dart';
import 'package:maktoob/features/explore/domain/repositories/explore_repository.dart';
import 'package:maktoob/features/explore/domain/usecases/get_occasion_groups_usecase.dart';
import 'package:maktoob/features/explore/domain/usecases/get_public_templates_usecase.dart';
import 'package:maktoob/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:maktoob/features/explore/presentation/screens/explore_screen.dart';
import 'package:maktoob/features/explore/presentation/widgets/widgets.dart';
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
      const Right([
        TemplatePreviewEntity(id: 77, imageUrl: '', thumbnailUrl: '', eventTypeId: 10),
      ]);
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

  Future<void> pumpApp(WidgetTester tester, AuthCubit cubit, PendingWizardIntentService intents) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(BlocProvider<AuthCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          home: AuthWrapper(skipSplash: true, pendingIntents: intents),
        ),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a design remembers it and opens sign-up', (tester) async {
    final cubit = _SignedOutAuthCubit();
    final intents = PendingWizardIntentService();
    await pumpApp(tester, cubit, intents);

    // The tile sits under the sticky bottom actions in the 800x600 test
    // view; invoke its tap directly.
    tester.widget<TemplatePreviewTile>(find.byType(TemplatePreviewTile)).onTap();
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    final intent = intents.consume();
    expect(intent?.eventTypeId, 10);
    expect(intent?.templateId, 77);

    await cubit.close();
  });

  testWidgets('Android back from login opened via Explore returns to Explore', (tester) async {
    final cubit = _SignedOutAuthCubit();
    await pumpApp(tester, cubit, PendingWizardIntentService());

    await tester.tap(find.text('عندي حساب — تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ExploreScreen), findsOneWidget);

    await cubit.close();
  });
}
